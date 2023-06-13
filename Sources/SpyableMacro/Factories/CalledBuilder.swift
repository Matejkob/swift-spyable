import SwiftSyntax
import SwiftSyntaxBuilder

struct CalledBuilder {
    func variableDeclaration(variablePrefix: String) -> VariableDeclSyntax {
        VariableDeclSyntax(
            bindingKeyword: .keyword(.var),
            bindingsBuilder: {
                PatternBindingSyntax(
                    pattern: IdentifierPatternSyntax(
                        identifier: .identifier(variablePrefix + "Called")
                    ),
                    typeAnnotation: TypeAnnotationSyntax(
                        type: SimpleTypeIdentifierSyntax(name: .identifier("Bool"))
                    ),
                    accessor: .getter(
                        CodeBlockSyntax {
                            ReturnStmtSyntax(
                                expression: SequenceExprSyntax {
                                    IdentifierExprSyntax(identifier: .identifier(variablePrefix + "CallsCount"))
                                    BinaryOperatorExprSyntax(operatorToken: .binaryOperator(">"))
                                    IntegerLiteralExprSyntax(digits: .integerLiteral("0"))
                                }
                            )
                        }
                    )
                )
            }
        )
    }
}
