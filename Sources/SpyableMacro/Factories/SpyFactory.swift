import SwiftSyntax
import SwiftSyntaxBuilder

/// `SpyFactory` is a factory that creates a test spy for a given protocol. A spy is a type of test double
/// that captures method and property interactions for later verification. The `SpyFactory` creates a new
/// class that implements the given protocol and keeps track of interactions with its properties and methods.
///
/// The `SpyFactory` utilizes several other factories, each with its own responsibilities:
///
/// - `VariablePrefixFactory`: It creates unique prefixes for variable names based on the function
///   signatures. This helps to avoid naming conflicts when creating the spy class.
///
/// - `VariablesImplementationFactory`: It is responsible for generating the actual variable declarations
///   within the spy class. It creates declarations for properties found in the protocol.
///
/// - `CallsCountFactory`, `CalledFactory`, `ReceivedArgumentsFactory`, `ReceivedInvocationsFactory`:
///   These factories produce variables that keep track of how many times a method was called, whether it was called,
///   the arguments it was last called with, and all invocations with their arguments respectively.
///
/// - `ThrowableErrorFactory`: It creates a variable for storing a throwing error for a stubbed method.
///
/// - `ReturnValueFactory`: It creates a variable for storing a return value for a stubbed method.
///
/// - `ClosureFactory`: It creates a closure variable for every method in the protocol, allowing the spy to
///   define custom behavior for each method.
///
/// - `FunctionImplementationFactory`: It generates function declarations for the spy class, each function will
///   manipulate the corresponding variables (calls count, received arguments etc.) and then call the respective
///   closure if it exists.
///
/// The `SpyFactory` generates the spy class by first iterating over each property in the protocol and creating
/// corresponding variable declarations using the `VariablesImplementationFactory`.
///
/// Next, it iterates over each method in the protocol. For each method, it uses the `VariablePrefixFactory` to
/// create a unique prefix for that method. Then, it uses other factories to generate a set of variables for that
/// method and a method implementation using the `FunctionImplementationFactory`.
///
/// The result is a spy class that implements the same interface as the protocol and keeps track of interactions
/// with its methods and properties.
///
/// For example, given a protocol:
/// ```swift
/// protocol ServiceProtocol {
///     var data: Data { get }
///     func fetch(text: String, count: Int) async throws -> Decimal
/// }
/// ```
/// the factory generates:
/// ```swift
/// class ServiceProtocolSpy: ServiceProtocol {
///     var data: Data {
///         get { underlyingData }
///         set { underlyingData = newValue }
///     }
///     var underlyingData: Data!
///
///     var fetchTextCountCallsCount = 0
///     var fetchTextCountCalled: Bool {
///         return fetchTextCountCallsCount > 0
///     }
///     var fetchTextCountReceivedArguments: (text: String, count: Int)?
///     var fetchTextCountReceivedInvocations: [(text: String, count: Int)] = []
///     var fetchTextCountThrowableError: (any Error)?
///     var fetchTextCountReturnValue: Decimal!
///     var fetchTextCountClosure: ((String, Int) async throws -> Decimal)?
///
///     func fetch(text: String, count: Int) async throws -> Decimal {
///         fetchTextCountCallsCount += 1
///         fetchTextCountReceivedArguments = (text, count)
///         fetchTextCountReceivedInvocations.append((text, count))
///         if let fetchTextCountThrowableError {
///             throw fetchTextCountThrowableError
///         }
///         if fetchTextCountClosure != nil {
///             return try await fetchTextCountClosure!(text, count)
///         } else {
///             return fetchTextCountReturnValue
///         }
///     }
/// }
/// ```
struct SpyFactory {
  private let associatedtypeFactory = AssociatedtypeFactory()
  private let variablePrefixFactory = VariablePrefixFactory()
  private let variablesImplementationFactory = VariablesImplementationFactory()
  private let callsCountFactory = CallsCountFactory()
  private let calledFactory = CalledFactory()
  private let receivedArgumentsFactory = ReceivedArgumentsFactory()
  private let receivedInvocationsFactory = ReceivedInvocationsFactory()
  private let throwableErrorFactory = ThrowableErrorFactory()
  private let returnValueFactory = ReturnValueFactory()
  private let closureFactory = ClosureFactory()
  private let functionImplementationFactory = FunctionImplementationFactory()

  func classDeclaration(
    for protocolDeclaration: ProtocolDeclSyntax,
    inheritedType: String? = nil
  ) throws -> ClassDeclSyntax {
    let identifier = TokenSyntax.identifier(protocolDeclaration.name.text + "Spy")

    let assosciatedtypeDeclarations = protocolDeclaration.memberBlock.members.compactMap {
      $0.decl.as(AssociatedTypeDeclSyntax.self)
    }
    let genericParameterClause = associatedtypeFactory.constructGenericParameterClause(
      associatedtypeDeclList: assosciatedtypeDeclarations)

    let variableDeclarations = protocolDeclaration.memberBlock.members
      .compactMap { $0.decl.as(VariableDeclSyntax.self)?.removingLeadingSpaces }

    let functionDeclarations = protocolDeclaration.memberBlock.members
      .compactMap { $0.decl.as(FunctionDeclSyntax.self)?.removingLeadingSpaces }

    // Create a polymorphism detector that computes prefixes lazily
    let polymorphismDetector = PolymorphismDetector(
      functions: functionDeclarations,
      prefixFactory: variablePrefixFactory
    )

    return try ClassDeclSyntax(
      name: identifier,
      genericParameterClause: genericParameterClause,
      inheritanceClause: InheritanceClauseSyntax {
        // Add inherited type first if present
        if let inheritedType {
          InheritedTypeSyntax(
            type: TypeSyntax(stringLiteral: inheritedType)
          )
        }

        // Add the main protocol
        InheritedTypeSyntax(
          type: TypeSyntax(stringLiteral: protocolDeclaration.name.text)
        )
        InheritedTypeSyntax(
          type: TypeSyntax(stringLiteral: "@unchecked Sendable")
        )
      },
      memberBlockBuilder: {
        let initOverrideKeyword: DeclModifierListSyntax = inheritedType != nil ? [DeclModifierSyntax(name: .keyword(.override))] : []

        InitializerDeclSyntax(
          modifiers: initOverrideKeyword,
          signature: FunctionSignatureSyntax(
            parameterClause: FunctionParameterClauseSyntax(parameters: [])
          ),
          bodyBuilder: {}
        )

        for variableDeclaration in variableDeclarations {
          try variablesImplementationFactory.variablesDeclarations(
            protocolVariableDeclaration: variableDeclaration
          )
        }

        for functionDeclaration in functionDeclarations {
          let variablePrefix = polymorphismDetector.getVariablePrefix(for: functionDeclaration)
          let genericTypes = functionDeclaration.genericTypes
          let parameterList = parameterList(
            protocolFunctionDeclaration: functionDeclaration, genericTypes: genericTypes)

          try callsCountFactory.variableDeclaration(variablePrefix: variablePrefix)
          try calledFactory.variableDeclaration(variablePrefix: variablePrefix)

          if parameterList.supportsParameterTracking {
            try receivedArgumentsFactory.variableDeclaration(
              variablePrefix: variablePrefix,
              parameterList: parameterList
            )
            try receivedInvocationsFactory.variableDeclaration(
              variablePrefix: variablePrefix,
              parameterList: parameterList
            )
          }

          #if canImport(SwiftSyntax600)
            let throwsSpecifier = functionDeclaration.signature.effectSpecifiers?.throwsClause?
              .throwsSpecifier
          #else
            let throwsSpecifier = functionDeclaration.signature.effectSpecifiers?.throwsSpecifier
          #endif

          if throwsSpecifier != nil {
            try throwableErrorFactory.variableDeclaration(variablePrefix: variablePrefix)
          }

          if let returnType = functionDeclaration.signature.returnClause?.type {
            let genericTypeErasedReturnType = returnType.erasingGenericTypes(genericTypes)
            returnValueFactory.variableDeclaration(
              variablePrefix: variablePrefix,
              functionReturnType: genericTypeErasedReturnType
            )
          }

          closureFactory.variableDeclaration(
            variablePrefix: variablePrefix,
            protocolFunctionDeclaration: functionDeclaration
          )

          functionImplementationFactory.declaration(
            variablePrefix: variablePrefix,
            protocolFunctionDeclaration: functionDeclaration
          )
        }
      }
    )
  }
}

private func parameterList(
  protocolFunctionDeclaration: FunctionDeclSyntax,
  genericTypes: Set<String>
) -> FunctionParameterListSyntax {
  let functionSignatureParameters = protocolFunctionDeclaration.signature.parameterClause.parameters
  return if genericTypes.isEmpty {
    functionSignatureParameters
  } else {
    FunctionParameterListSyntax {
      for parameter in functionSignatureParameters {
        parameter.with(\.type, parameter.type.erasingGenericTypes(genericTypes))
      }
    }
  }
}

/// Optimized polymorphism detector that lazily computes variable prefixes
/// only when polymorphism is detected, avoiding expensive dictionary creation
/// for protocols with unique method signatures
private final class PolymorphismDetector {
  private let functions: [FunctionDeclSyntax]
  private let prefixFactory: VariablePrefixFactory

  // Lazy properties for performance optimization - only computed when needed
  private lazy var prefixCounts: [String: Int] = {
    Dictionary(grouping: functions, by: { prefixFactory.text(for: $0) })
      .mapValues { $0.count }
  }()

  init(functions: [FunctionDeclSyntax], prefixFactory: VariablePrefixFactory) {
    self.functions = functions
    self.prefixFactory = prefixFactory
  }

  func getVariablePrefix(for function: FunctionDeclSyntax) -> String {
    // Early exit optimization: if only one function, no polymorphism possible
    guard functions.count > 1 else {
      return prefixFactory.text(for: function)
    }

    // Compute base prefix
    let basePrefix = prefixFactory.text(for: function)

    // Check if descriptive prefix needed - this triggers lazy evaluation
    let shouldBeDescriptive = (prefixCounts[basePrefix] ?? 0) > 1

    if shouldBeDescriptive {
      return prefixFactory.text(for: function, descriptive: true)
    } else {
      return basePrefix
    }
  }
}

extension SyntaxProtocol {
  /// - Returns: `self` with leading space `Trivia` removed.
  fileprivate var removingLeadingSpaces: Self {
    with(
      \.leadingTrivia,
      Trivia(
        pieces:
          leadingTrivia
          .filter {
            if case .spaces = $0 {
              false
            } else {
              true
            }
          }
      )
    )
  }
}
