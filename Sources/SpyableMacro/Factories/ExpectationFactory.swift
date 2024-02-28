import SwiftSyntax
import SwiftSyntaxBuilder

/// The `ExpectationFactory` is designed to generate a representation of a Swift
/// variable declaration for an expectation, as well as invocation of it's fulfillments.
///
/// The generated variable represents aт XCTestExpectation that corresponds to a given function
/// signature. The name of the variable is constructed by appending the word "Expectation"
/// to the `variablePrefix` parameter.
///
/// The factory also generates a call expression that fulfils that expectation 
///
/// The following code:
/// ```swift
/// var fooExpectation: XCTestExpectation?
///
/// fooExpectation?.fulfill()
/// ```
/// would be generated for a function like this:
/// ```swift
/// func foo()
///
/// - Note: The `ExpectationFactory` is useful in scenarios where you need to receive a signal
///         that async function did finish it's execution
struct ExpectationFactory {
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
      var \(variableIdentifier(variablePrefix: variablePrefix)): XCTestExpectation?
      """
    )
  }
    
  func fulfillExpectationExpression(variablePrefix: String) -> ExprSyntax {
    ExprSyntax(
      """
      \(variableIdentifier(variablePrefix: variablePrefix))?.fulfill()
      """
        )
  }

  private func variableIdentifier(variablePrefix: String) -> TokenSyntax {
    TokenSyntax.identifier(variablePrefix + "Expectation")
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
