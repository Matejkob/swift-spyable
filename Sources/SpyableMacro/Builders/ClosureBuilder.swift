import SwiftSyntax
import SwiftSyntaxBuilder

struct ClosureBuilder {
    func variableDeclaration(variablePrefix: String, functionSignature: FunctionSignatureSyntax) -> VariableDeclSyntax {
        let elements = TupleTypeElementListSyntax {
            TupleTypeElementSyntax(
                type: FunctionTypeSyntax(
                    arguments: TupleTypeElementListSyntax {
                        for parameter in functionSignature.input.parameterList {
                            TupleTypeElementSyntax(type: parameter.type)
                        }
                    },
                    effectSpecifiers: TypeEffectSpecifiersSyntax(
                        asyncSpecifier: functionSignature.effectSpecifiers?.asyncSpecifier,
                        throwsSpecifier: functionSignature.effectSpecifiers?.throwsSpecifier
                    ),
                    output: functionSignature.output ?? ReturnClauseSyntax(
                        returnType: SimpleTypeIdentifierSyntax(
                            name: .identifier("Void")
                        )
                    )
                )
            )
        }

        let typeAnnotation = TypeAnnotationSyntax(
            type: OptionalTypeSyntax(
                wrappedType: TupleTypeSyntax(
                    elements: elements
                )
            )
        )

        return VariableDeclSyntax(
            bindingKeyword: .keyword(.var),
            bindingsBuilder: {
                PatternBindingSyntax(
                    pattern: IdentifierPatternSyntax(
                        identifier: variableIdentifier(variablePrefix: variablePrefix)
                    ),
                    typeAnnotation: typeAnnotation
                )
            }
        )
    }

    func callExpression(variablePrefix: String, functionSignature: FunctionSignatureSyntax) -> ExprSyntaxProtocol {
        var expression: ExprSyntaxProtocol = FunctionCallExprSyntax(
            calledExpression: ForcedValueExprSyntax(
                expression: IdentifierExprSyntax(
                    identifier: variableIdentifier(variablePrefix: variablePrefix)
                )
            ),
            leftParen: .leftParenToken(),
            argumentList: TupleExprElementListSyntax {
                for parameter in functionSignature.input.parameterList {
                    let identifier = if let secondName = parameter.secondName { secondName } else { parameter.firstName }
                    
                    TupleExprElementSyntax(
                        expression: IdentifierExprSyntax(
                            identifier: identifier
                        )
                    )
                }
            },
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
