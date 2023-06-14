import SwiftSyntax
import SwiftSyntaxBuilder

struct SpyFactory {
    private let variablePrefixFactory = VariablePrefixFactory()
    private let variablesImplementationFactory = VariablesImplementationFactory()
    private let callsCountFactory = CallsCountFactory()
    private let calledFactory = CalledFactory()
    private let receivedArgumentsFactory = ReceivedArgumentsFactory()
    private let receivedInvocationsFactory = ReceivedInvocationsFactory()
    private let returnValueFactory = ReturnValueFactory()
    private let closureFactory = ClosureFactory()
    private let functionImplementationFactory = FunctionImplementationFactory()

    func classDeclaration(for protocolDeclaration: ProtocolDeclSyntax) -> ClassDeclSyntax {
        let identifier = TokenSyntax.identifier(protocolDeclaration.identifier.text + "Spy")

        let variableDeclarations = protocolDeclaration.memberBlock.members
            .compactMap { $0.decl.as(VariableDeclSyntax.self) }

        let functionDeclarations = protocolDeclaration.memberBlock.members
            .compactMap { $0.decl.as(FunctionDeclSyntax.self) }
        
        return ClassDeclSyntax(
            identifier: identifier,
            inheritanceClause: TypeInheritanceClauseSyntax {
                InheritedTypeSyntax(
                    typeName: SimpleTypeIdentifierSyntax(name: protocolDeclaration.identifier)
                )
            },
            memberBlockBuilder: {
                for variableDeclaration in variableDeclarations {
                    variablesImplementationFactory.variablesDeclarations(
                        protocolVariableDeclaration: variableDeclaration
                    )
                }

                for functionDeclaration in functionDeclarations {
                    let variablePrefix = variablePrefixFactory.text(for: functionDeclaration)
                    let parameterList = functionDeclaration.signature.input.parameterList

                    callsCountFactory.variableDeclaration(variablePrefix: variablePrefix)
                    calledFactory.variableDeclaration(variablePrefix: variablePrefix)

                    if !parameterList.isEmpty {
                        receivedArgumentsFactory.variableDeclaration(
                            variablePrefix: variablePrefix,
                            parameterList: parameterList
                        )
                        receivedInvocationsFactory.variableDeclaration(
                            variablePrefix: variablePrefix,
                            parameterList: parameterList
                        )
                    }

                    if let returnType = functionDeclaration.signature.output?.returnType {
                        returnValueFactory.variableDeclaration(
                            variablePrefix: variablePrefix,
                            functionReturnType: returnType
                        )
                    }

                    closureFactory.variableDeclaration(
                        variablePrefix: variablePrefix,
                        functionSignature: functionDeclaration.signature
                    )

                    functionImplementationFactory.declaration(
                        variablePrefix: variablePrefix,
                        protocolFunctionDeclaration: functionDeclaration
                    )
                }
            }
        )
    }
}
