import SwiftSyntax
import SwiftSyntaxBuilder

struct ReceivedInvocationsBuilder {
    func variableDeclaration(variablePrefix: String, parameterList: FunctionParameterListSyntax) -> VariableDeclSyntax {
        let identifier = variableIdentifier(variablePrefix: variablePrefix)
        let elementType = arrayElementType(parameterList: parameterList)

        return VariableDeclSyntax(
            bindingKeyword: .keyword(.var),
            bindingsBuilder: {
                PatternBindingSyntax(
                    pattern: IdentifierPatternSyntax(identifier: identifier),
                    typeAnnotation: TypeAnnotationSyntax(
                        type: ArrayTypeSyntax(elementType: elementType)
                    ),
                    initializer: InitializerClauseSyntax(
                        value: ArrayExprSyntax(elementsBuilder: {})
                    )
                )
            }
        )
    }

    private func arrayElementType(parameterList: FunctionParameterListSyntax) -> TypeSyntaxProtocol {
        let arrayElementType: TypeSyntaxProtocol

        if parameterList.count == 1, let onlyParameter = parameterList.first {
            arrayElementType = onlyParameter.type
        } else {
            let tupleElements = TupleTypeElementListSyntax {
                for parameter in parameterList {
                    TupleTypeElementSyntax(
                        name: (parameter.secondName != nil ? parameter.secondName : parameter.firstName),
                        colon: .colonToken(),
                        type: parameter.type
                    )
                }
            }
            arrayElementType = TupleTypeSyntax(elements: tupleElements)
        }

        return arrayElementType
    }

    func appendValueToVariableExpression(variablePrefix: String, parameterList: FunctionParameterListSyntax) -> FunctionCallExprSyntax {
        let identifier = variableIdentifier(variablePrefix: variablePrefix)
        let calledExpression = MemberAccessExprSyntax(
            base: IdentifierExprSyntax(identifier: identifier),
            dot: .periodToken(),
            name: .identifier("append")
        )
        let argument = appendArgumentExpression(parameterList: parameterList)

        return FunctionCallExprSyntax(
            calledExpression: calledExpression,
            leftParen: .leftParenToken(),
            argumentList: argument,
            rightParen: .rightParenToken()
        )
    }

    private func appendArgumentExpression(parameterList: FunctionParameterListSyntax) -> TupleExprElementListSyntax {
        let tupleArgument = TupleExprSyntax(
            elementListBuilder: {
                for parameter in parameterList {
                    let identifier = if let secondName = parameter.secondName { secondName } else { parameter.firstName }

                    TupleExprElementSyntax(
                        expression: IdentifierExprSyntax(
                            identifier: identifier
                        )
                    )
                }
            }
        )

        return TupleExprElementListSyntax {
            TupleExprElementSyntax(expression: tupleArgument)
        }
    }

    private func variableIdentifier(variablePrefix: String) -> TokenSyntax {
        TokenSyntax.identifier(variablePrefix + "ReceivedInvocations")
    }
}
