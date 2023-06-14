import SwiftSyntax
import SwiftSyntaxBuilder

/// The `FunctionImplementationFactory` is designed to generate Swift function declarations
/// based on protocol function declarations. It enriches the declarations with functionality that tracks
/// function invocations, received arguments, and return values.
///
/// It leverages multiple other factories to generate components of the function body:
/// - `CallsCountFactory`: to increment the `CallsCount` each time the function is invoked.
/// - `ReceivedArgumentsFactory`: to update the `ReceivedArguments` with the arguments of the latest invocation.
/// - `ReceivedInvocationsFactory`: to append the latest invocation to the `ReceivedInvocations` list.
/// - `ClosureFactory`: to generate a closure expression that mirrors the function signature.
/// - `ReturnValueFactory`: to provide the return statement from the `ReturnValue`.
///
/// If the function doesn't have output, the factory uses the `ClosureFactory` to generate a call expression,
/// otherwise, it generates an `IfExprSyntax` that checks whether a closure is set for the function.
/// If the closure is set, it is called and its result is returned, else it returns the value from the `ReturnValueFactory`.
///
/// > Important: This factory assumes that certain variables exist to store the tracking data:
/// > - `CallsCount`: A variable that tracks the number of times the function has been invoked.
/// > - `ReceivedArguments`: A variable to store the arguments that were passed in the latest function call.
/// > - `ReceivedInvocations`: A list to record all invocations of the function.
/// > - `ReturnValue`: A variable to hold the return value of the function.
///
/// For example, given a protocol function:
/// ```swift
/// func display(text: String)
/// ```
/// the `FunctionImplementationFactory` generates the following function declaration:
/// ```swift
/// func display(text: String) {
///     displayCallsCount += 1
///     displayReceivedArguments = text
///     displayReceivedInvocations.append(text)
///     displayClosure?(text)
/// }
/// ```
///
/// And for a protocol function with return type:
/// ```swift
/// func fetchText() async throws -> String
/// ```
/// the factory generates:
/// ```swift
/// func fetchText() -> String {
///     fetchTextCallsCount += 1
///     if let closure = fetchTextClosure {
///         return try await closure()
///     } else {
///         return fetchTextReturnValue
///     }
/// }
/// ```
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
