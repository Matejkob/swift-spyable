import SwiftSyntax
import SwiftSyntaxBuilder

struct CallsCountBuilder {
    func variableDeclaration(variablePrefix: String) -> VariableDeclSyntax {
        VariableDeclSyntax(
            bindingKeyword: .keyword(.var),
            bindingsBuilder: {
                PatternBindingSyntax(
                    pattern: IdentifierPatternSyntax(
                        identifier: variableIdentifier(variablePrefix: variablePrefix)
                    ),
                    initializer: InitializerClauseSyntax(
                        value: IntegerLiteralExprSyntax(digits: .integerLiteral("0"))
                    )
                )
            }
        )
    }

    func incrementVariableExpression(variablePrefix: String) -> SequenceExprSyntax {
        SequenceExprSyntax {
            IdentifierExprSyntax(identifier: variableIdentifier(variablePrefix: variablePrefix))
            BinaryOperatorExprSyntax(operatorToken: .binaryOperator("+="))
            IntegerLiteralExprSyntax(digits: .integerLiteral("1"))
        }
    }

    private func variableIdentifier(variablePrefix: String) -> TokenSyntax {
        TokenSyntax.identifier(variablePrefix + "CallsCount")
    }
}
