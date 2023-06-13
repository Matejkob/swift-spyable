import SwiftSyntax
import SwiftSyntaxBuilder

struct ReceivedArgumentsBuilder {
    func variableDeclaration(variablePrefix: String, parameterList: FunctionParameterListSyntax) -> VariableDeclSyntax {
        let identifier = variableIdentifier(variablePrefix: variablePrefix, parameterList: parameterList)
        let type = variableType(parameterList: parameterList)

        return VariableDeclSyntax(
            bindingKeyword: .keyword(.var),
            bindingsBuilder: {
                PatternBindingSyntax(
                    pattern: IdentifierPatternSyntax(identifier: identifier),
                    typeAnnotation: TypeAnnotationSyntax(
                        type: type
                    )
                )
            }
        )
    }

    private func variableType(parameterList: FunctionParameterListSyntax) -> TypeSyntaxProtocol {
        let variableType: TypeSyntaxProtocol

        if parameterList.count == 1, let onlyParameter = parameterList.first {
            if onlyParameter.type.is(OptionalTypeSyntax.self) {
                variableType = onlyParameter.type
            } else {
                variableType = OptionalTypeSyntax(wrappedType: onlyParameter.type, questionMark: .postfixQuestionMarkToken())
            }
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
            variableType = OptionalTypeSyntax(
                wrappedType: TupleTypeSyntax(elements: tupleElements),
                questionMark: .postfixQuestionMarkToken()
            )
        }

        return variableType
    }

    func assignValueToVariableExpression(variablePrefix: String, parameterList: FunctionParameterListSyntax) -> SequenceExprSyntax {
        let identifier = variableIdentifier(variablePrefix: variablePrefix, parameterList: parameterList)

        return SequenceExprSyntax {
            IdentifierExprSyntax(identifier: identifier)
            AssignmentExprSyntax()
            TupleExprSyntax {
                for parameter in parameterList {
                    let identifier = if let secondName = parameter.secondName { secondName } else { parameter.firstName }

                    TupleExprElementSyntax(
                        expression: IdentifierExprSyntax(
                            identifier: identifier
                        )
                    )
                }
            }
        }
    }

    private func variableIdentifier(variablePrefix: String, parameterList: FunctionParameterListSyntax) -> TokenSyntax {
        if parameterList.count == 1, let onlyParameter = parameterList.first {
             let parameterNameToken = if let secondName = onlyParameter.secondName { secondName } else { onlyParameter.firstName }
             let parameterNameText = parameterNameToken.text
             let capitalizedParameterName = parameterNameText.prefix(1).uppercased() + parameterNameText.dropFirst()

             return .identifier(variablePrefix + "Received" + capitalizedParameterName)
         } else {
             return .identifier(variablePrefix + "ReceivedArguments")
         }
    }
}
