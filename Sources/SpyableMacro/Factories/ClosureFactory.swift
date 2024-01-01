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
    functionSignature: FunctionSignatureSyntax
  ) throws -> VariableDeclSyntax {
    let elements = TupleTypeElementListSyntax {
      TupleTypeElementSyntax(
        type: FunctionTypeSyntax(
          parameters: TupleTypeElementListSyntax {
            for parameter in functionSignature.parameterClause.parameters {
              TupleTypeElementSyntax(type: parameter.type)
            }
          },
          effectSpecifiers: TypeEffectSpecifiersSyntax(
            asyncSpecifier: functionSignature.effectSpecifiers?.asyncSpecifier,
            throwsSpecifier: functionSignature.effectSpecifiers?.throwsSpecifier
          ),
          returnClause: functionSignature.returnClause
            ?? ReturnClauseSyntax(
              type: IdentifierTypeSyntax(
                name: .identifier("Void")
              )
            )
        )
      )
    }

    return try VariableDeclSyntax(
      """
      var \(variableIdentifier(variablePrefix: variablePrefix)): (\(elements))?
      """
    )
  }

  func callExpression(
    variablePrefix: String,
    functionSignature: FunctionSignatureSyntax
  ) -> ExprSyntaxProtocol {
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

    if functionSignature.effectSpecifiers?.throwsSpecifier != nil {
      expression = TryExprSyntax(expression: expression)
    }

    return expression
  }

  private func variableIdentifier(variablePrefix: String) -> TokenSyntax {
    TokenSyntax.identifier(variablePrefix + "Closure")
  }
}

extension FunctionParameterListSyntax.Element {
  fileprivate var isInoutParameter: Bool {
    if let attributedType = self.type.as(AttributedTypeSyntax.self),
      attributedType.specifier?.text == TokenSyntax.keyword(.inout).text
    {
      return true
    } else {
      return false
    }
  }
}
