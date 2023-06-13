import SwiftSyntax
import SwiftSyntaxBuilder

struct FunctionImplementationFactory {
    private let callsCountFactory = CallsCountFactory()
    private let receivedArgumentsFactory = ReceivedArgumentsFactory()
    private let receivedInvocationsFactory = ReceivedInvocationsFactory()
    private let closureFactory = ClosureFactory()
    private let returnValueFactory = ReturnValueFactory()

    func declaration(
        variablePrefix: String,
        protocolFunctionDeclaration: FunctionDeclSyntax
    ) -> FunctionDeclSyntax {
        FunctionDeclSyntax(
            attributes: protocolFunctionDeclaration.attributes,
            modifiers: protocolFunctionDeclaration.modifiers,
            funcKeyword: protocolFunctionDeclaration.funcKeyword,
            identifier: protocolFunctionDeclaration.identifier,
            genericParameterClause: protocolFunctionDeclaration.genericParameterClause,
            signature: protocolFunctionDeclaration.signature,
            genericWhereClause: protocolFunctionDeclaration.genericWhereClause,
            bodyBuilder: {
                let parameterList = protocolFunctionDeclaration.signature.input.parameterList

                callsCountFactory.incrementVariableExpression(variablePrefix: variablePrefix)

                if !parameterList.isEmpty {
                    receivedArgumentsFactory.assignValueToVariableExpression(
                        variablePrefix: variablePrefix,
                        parameterList: parameterList
                    )
                    receivedInvocationsFactory.appendValueToVariableExpression(
                        variablePrefix: variablePrefix,
                        parameterList: parameterList
                    )
                }

                if protocolFunctionDeclaration.signature.output == nil {
                    closureFactory.callExpression(
                        variablePrefix: variablePrefix,
                        functionSignature: protocolFunctionDeclaration.signature
                    )
                } else {
                    returnExpression(
                        variablePrefix: variablePrefix,
                        protocolFunctionDeclaration: protocolFunctionDeclaration
                    )
                }
            }
        )
    }

    private func returnExpression(variablePrefix: String, protocolFunctionDeclaration: FunctionDeclSyntax) -> IfExprSyntax {
        return IfExprSyntax(
            conditions: ConditionElementListSyntax {
                ConditionElementSyntax(
                    condition: .expression(
                        ExprSyntax(
                            SequenceExprSyntax {
                                IdentifierExprSyntax(identifier: .identifier(variablePrefix + "Closure"))
                                BinaryOperatorExprSyntax(operatorToken: .binaryOperator("!="))
                                NilLiteralExprSyntax()
                            }
                        )
                    )
                )
            },
            elseKeyword: .keyword(.else),
            elseBody: .codeBlock(
                CodeBlockSyntax {
                    returnValueFactory.returnStatement(variablePrefix: variablePrefix)
                }
            ),
            bodyBuilder: {
                ReturnStmtSyntax(
                    expression: closureFactory.callExpression(
                        variablePrefix: variablePrefix,
                        functionSignature: protocolFunctionDeclaration.signature
                    )
                )
            }
        )
    }
}
