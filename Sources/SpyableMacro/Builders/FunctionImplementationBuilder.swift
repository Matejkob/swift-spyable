import SwiftSyntax
import SwiftSyntaxBuilder

struct FunctionImplementationBuilder {
    private let callsCountBuilder = CallsCountBuilder()
    private let receivedArgumentsBuilder = ReceivedArgumentsBuilder()
    private let receivedInvocationsBuilder = ReceivedInvocationsBuilder()
    private let returnValueBuilder = ReturnValueBuilder()

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

                callsCountBuilder.incrementVariableExpression(variablePrefix: variablePrefix)

                if !parameterList.isEmpty {
                    receivedArgumentsBuilder.assignValueToVariableExpression(
                        variablePrefix: variablePrefix,
                        parameterList: parameterList
                    )
                    receivedInvocationsBuilder.appendValueToVariableExpression(
                        variablePrefix: variablePrefix,
                        parameterList: parameterList
                    )
                }

                if protocolFunctionDeclaration.signature.output != nil {
                    returnValueBuilder.returnStatement(variablePrefix: variablePrefix)
                }
            }
        )
    }
}
