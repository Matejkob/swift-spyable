import SwiftSyntax
import SwiftSyntaxBuilder

struct ReturnValueBuilder {
    func variableDeclaration(variablePrefix: String, functionReturnType: TypeSyntax) -> VariableDeclSyntax {
        VariableDeclSyntax(
            bindingKeyword: .keyword(.var),
            bindingsBuilder: {
                PatternBindingSyntax(
                    pattern: IdentifierPatternSyntax(
                        identifier: variableIdentifier(variablePrefix: variablePrefix)
                    ),
                    typeAnnotation: {
                        if functionReturnType.is(OptionalTypeSyntax.self) {
                            TypeAnnotationSyntax(type: functionReturnType)
                        } else {
                            TypeAnnotationSyntax(
                                type: ImplicitlyUnwrappedOptionalTypeSyntax(wrappedType: functionReturnType)
                            )
                        }
                    }()
                )
            }
        )
    }

    func returnStatement(variablePrefix: String) -> ReturnStmtSyntax {
        ReturnStmtSyntax(
            returnKeyword: .keyword(.return),
            expression: IdentifierExprSyntax(identifier: variableIdentifier(variablePrefix: variablePrefix))
        )
    }

    private func variableIdentifier(variablePrefix: String) -> TokenSyntax {
        TokenSyntax.identifier(variablePrefix + "ReturnValue")
    }
}
