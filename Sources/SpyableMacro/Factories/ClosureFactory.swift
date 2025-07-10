import SwiftSyntax
import SwiftSyntaxBuilder

/// The `ClosureFactory` is designed to generate a representation of a Swift
/// variable declaration for a closure, as well as the invocation of this closure.
///
/// The generated variable represents a closure that corresponds to a given function
/// signature. The name of the variable is constructed by appending the word "Closure"
/// to the `variablePrefix` parameter.
///
/// The factory also generates a call expression that executes the closure using the names
/// of the parameters from the function signature.
///
/// The following code:
/// ```swift
/// var fooClosure: ((inout String, Int) async throws -> Data)?
///
/// try await fooClosure!(&text, count)
/// ```
/// would be generated for a function like this:
/// ```swift
/// func foo(text: inout String, count: Int) async throws -> Data
/// ```
/// and an argument `variablePrefix` equal to `foo`.
///
/// - Note: The `ClosureFactory` is useful in scenarios where you need to mock the
///         behavior of a function, particularly for testing purposes. You can use it to define
///         the behavior of the function under different conditions, and validate that your code
///         interacts correctly with the function.
struct ClosureFactory {
  func variableDeclaration(
    variablePrefix: String,
    protocolFunctionDeclaration: FunctionDeclSyntax
  ) -> VariableDeclSyntax {
    let functionSignature = protocolFunctionDeclaration.signature
    let genericTypes = protocolFunctionDeclaration.genericTypes
    let returnClause = returnClause(protocolFunctionDeclaration: protocolFunctionDeclaration)

    #if canImport(SwiftSyntax600)
      let effectSpecifiers = TypeEffectSpecifiersSyntax(
        asyncSpecifier: functionSignature.effectSpecifiers?.asyncSpecifier,
        throwsClause: functionSignature.effectSpecifiers?.throwsClause
      )
    #else
      let effectSpecifiers = TypeEffectSpecifiersSyntax(
        asyncSpecifier: functionSignature.effectSpecifiers?.asyncSpecifier,
        throwsSpecifier: functionSignature.effectSpecifiers?.throwsSpecifier
      )
    #endif

    let elements = TupleTypeElementListSyntax {
      TupleTypeElementSyntax(
        type: FunctionTypeSyntax(
          parameters: TupleTypeElementListSyntax {
            for parameter in functionSignature.parameterClause.parameters {
              TupleTypeElementSyntax(
                type: parameter.type.erasingGenericTypes(genericTypes)
              )
            }
          },
          effectSpecifiers: effectSpecifiers,
          returnClause: returnClause
        )
      )
    }

    return VariableDeclSyntax(
      leadingTrivia: [],
      bindingSpecifier: .keyword(.var),
      bindings: PatternBindingListSyntax([
        PatternBindingSyntax(
          pattern: IdentifierPatternSyntax(
            identifier: variableIdentifier(variablePrefix: variablePrefix)),
          typeAnnotation: TypeAnnotationSyntax(
            type: OptionalTypeSyntax(
              wrappedType: TupleTypeSyntax(elements: elements)
            )
          )
        )
      ])
    )
  }

  private func returnClause(
    protocolFunctionDeclaration: FunctionDeclSyntax
  ) -> ReturnClauseSyntax {
    let functionSignature = protocolFunctionDeclaration.signature
    let genericTypes = protocolFunctionDeclaration.genericTypes

    if let functionReturnClause = functionSignature.returnClause {
      /*
       func f() -> String!
       */
      if let implicitlyUnwrappedType = functionReturnClause.type.as(
        ImplicitlyUnwrappedOptionalTypeSyntax.self)
      {
        /*
         `() -> String!` is not a valid code
         so we have to convert it to `() -> String?
         */
        return ReturnClauseSyntax(
          type: OptionalTypeSyntax(wrappedType: implicitlyUnwrappedType.wrappedType).with(
            \.trailingTrivia, [])
        )
        /*
         func f() -> Any
         func f() -> Any?
         */
      } else {
        return ReturnClauseSyntax(
          type: functionReturnClause.type.erasingGenericTypes(genericTypes).with(
            \.trailingTrivia, [])
        )
      }
      /*
       func f()
       */
    } else {
      return ReturnClauseSyntax(
        type: IdentifierTypeSyntax(
          name: .identifier("Void")
        )
      )
    }
  }

  func callExpression(
    variablePrefix: String,
    protocolFunctionDeclaration: FunctionDeclSyntax
  ) -> ExprSyntaxProtocol {
    let functionSignature = protocolFunctionDeclaration.signature
    let calledExpression: ExprSyntaxProtocol

    if functionSignature.returnClause == nil {
      calledExpression = OptionalChainingExprSyntax(
        expression: DeclReferenceExprSyntax(
          baseName: variableIdentifier(variablePrefix: variablePrefix)
        )
      )
    } else {
      calledExpression = ForceUnwrapExprSyntax(
        expression: DeclReferenceExprSyntax(
          baseName: variableIdentifier(variablePrefix: variablePrefix)
        )
      )
    }

    let arguments = LabeledExprListSyntax {
      for parameter in functionSignature.parameterClause.parameters {
        let baseName = parameter.secondName ?? parameter.firstName

        if parameter.isInoutParameter {
          LabeledExprSyntax(
            expression: InOutExprSyntax(
              expression: DeclReferenceExprSyntax(baseName: baseName)
            )
          )
        } else {
          let trailingTrivia: Trivia? = parameter.usesAutoclosure ? "()" : nil

          LabeledExprSyntax(
            expression: DeclReferenceExprSyntax(baseName: baseName), trailingTrivia: trailingTrivia)
        }
      }
    }

    var expression: ExprSyntaxProtocol = FunctionCallExprSyntax(
      calledExpression: calledExpression,
      leftParen: .leftParenToken(),
      arguments: arguments,
      rightParen: .rightParenToken()
    )

    if functionSignature.effectSpecifiers?.asyncSpecifier != nil {
      expression = AwaitExprSyntax(expression: expression)
    }

    #if canImport(SwiftSyntax600)
      let throwsSpecifier = functionSignature.effectSpecifiers?.throwsClause?.throwsSpecifier
    #else
      let throwsSpecifier = functionSignature.effectSpecifiers?.throwsSpecifier
    #endif

    if throwsSpecifier != nil {
      expression = TryExprSyntax(expression: expression)
    }

    if let forceCastType = protocolFunctionDeclaration.forceCastType {
      expression = AsExprSyntax(
        expression: expression,
        questionOrExclamationMark: .exclamationMarkToken(trailingTrivia: .space),
        type: forceCastType
      )
    }

    return expression
  }

  private func variableIdentifier(variablePrefix: String) -> TokenSyntax {
    TokenSyntax.identifier(variablePrefix + "Closure")
  }
}

extension FunctionParameterListSyntax.Element {
  fileprivate var isInoutParameter: Bool {
    // Check if the type contains 'inout' anywhere in its description
    // This works regardless of SwiftSyntax version and handles cases like "isolated inout"
    let typeDescription = self.type.description.trimmingCharacters(in: .whitespacesAndNewlines)
    return typeDescription.contains(TokenSyntax.keyword(.inout).text)
  }
}
