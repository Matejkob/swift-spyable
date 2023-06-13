import SwiftSyntax
import SwiftSyntaxBuilder

struct SpyFactory {
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

        let variablesDeclarations = protocolDeclaration.memberBlock.members
            .compactMap { $0.decl.as(VariableDeclSyntax.self) }

        let functionsDeclarations = protocolDeclaration.memberBlock.members
            .compactMap { $0.decl.as(FunctionDeclSyntax.self) }
        
        return ClassDeclSyntax(
            identifier: identifier,
            inheritanceClause: TypeInheritanceClauseSyntax {
                InheritedTypeSyntax(
                    typeName: SimpleTypeIdentifierSyntax(name: protocolDeclaration.identifier)
                )
            },
            memberBlockBuilder: {
                for variableDeclaration in variablesDeclarations {
                    variablesImplementationFactory.variablesDeclarations(
                        protocolVariableDeclaration: variableDeclaration
                    )
                }

                for functionDeclaration in functionsDeclarations {
                    let variablePrefix = spyPropertyDescription(for: functionDeclaration)
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

    // MARK: - Helpers

    func spyPropertyDescription(for functionDeclaration: FunctionDeclSyntax) -> String {
        /*
         Sourcery doesn't destingiush
         ```
         func foo()
         ```
         from
         ```
         func foo() -> String
         ```

         I think that the best way to deal with it would be generate basic nameing and
         If the colision would happend then deal with it some how
         Mayby I can use `(declaration.as(FunctionDeclSyntax.self))?.signature.input.description`
         */

        var parts: [String] = []

        parts.append(functionDeclaration.identifier.text)

        let parameterList = functionDeclaration.signature.input.parameterList

        if !parameterList.isEmpty {
            parts.append("With")
        }

        let parameters = parameterList
            .reduce([String]()) { partialResult, parameter in
                var partialResult = partialResult
                partialResult.append(parameter.firstName.text)

                if let secondNameText = parameter.secondName?.text {
                    partialResult.append(secondNameText)
                }
                return partialResult
            }
            .filter { $0 != "_" }
            .map { $0.prefix(1).uppercased() + $0.dropFirst() }

        parts.append(contentsOf: parameters)

        return parts.joined(separator: "")
    }
}
