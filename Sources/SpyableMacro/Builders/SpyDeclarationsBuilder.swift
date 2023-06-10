import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

private enum Const {
    static let spySufix = "Spy"

    enum CallsCount {
        static let variableSufix = "CallsCount"
    }
}

struct SpyDeclarationsBuilder {
    func classDeclaration(for protocolDeclaration: ProtocolDeclSyntax) throws -> ClassDeclSyntax {
        let identifier = classIdentifier(from: protocolDeclaration.identifier)

        let functionsDeclarations = protocolDeclaration.memberBlock.members
            .compactMap { $0.decl.as(FunctionDeclSyntax.self) }
        
        return ClassDeclSyntax(
            identifier: identifier,
            memberBlockBuilder: {
                for functionDeclaration in functionsDeclarations {
                    let variablePrefix = spyPropertyDescription(for: functionDeclaration)

                    /*
                     var fooCallsCount = 0
                     */
                    callsCountVariableDeclaration(withPrefix: variablePrefix)

                    /*
                     func foo() { ... }
                     */
                    FunctionDeclSyntax(
                        attributes: functionDeclaration.attributes,
                        modifiers: functionDeclaration.modifiers,
                        funcKeyword: functionDeclaration.funcKeyword,
                        identifier: functionDeclaration.identifier,
                        genericParameterClause: functionDeclaration.genericParameterClause,
                        signature: functionDeclaration.signature,
                        genericWhereClause: functionDeclaration.genericWhereClause,
                        bodyBuilder: {
                            /*
                             fooCallsCount += 1
                             */
                            incrementCallsCountExpresion(withPrefix: variablePrefix)
                        }
                    )
                }
            }
        )
    }

    // MARK: - Class Identifier

    func classIdentifier(from protocolDeclarationIdentifier: TokenSyntax) -> TokenSyntax {
        TokenSyntax.identifier(protocolDeclarationIdentifier.text + Const.spySufix)
    }

    // MARK: - Calls Count

    func callsCountVariableDeclaration(withPrefix prefix: String) -> VariableDeclSyntax {
        VariableDeclSyntax(
            bindingKeyword: .keyword(.var),
            bindingsBuilder: {
                PatternBindingSyntax(
                    pattern: IdentifierPatternSyntax(
                        identifier: .identifier(prefix + Const.CallsCount.variableSufix)
                    ),
                    initializer: InitializerClauseSyntax(
                        value: IntegerLiteralExprSyntax(digits: .integerLiteral("0"))
                    )
                )
            }
        )
    }

    func incrementCallsCountExpresion(withPrefix prefix: String) -> SequenceExprSyntax {
        SequenceExprSyntax {
            IdentifierExprSyntax(identifier: .identifier(prefix + Const.CallsCount.variableSufix))
            BinaryOperatorExprSyntax(operatorToken: .binaryOperator("+="))
            IntegerLiteralExprSyntax(digits: .integerLiteral("1"))
        }
    }

    // MARK: - Return Value

    func returnValueVariableDeclaration(withPrefix prefix: String) -> VariableDeclSyntax {
        VariableDeclSyntax(
            bindingKeyword: .keyword(.var),
            bindingsBuilder: {
                PatternBindingSyntax(
                    pattern: IdentifierPatternSyntax(
                        identifier: .identifier(prefix + Const.CallsCount.variableSufix)
                    ),
                    initializer: InitializerClauseSyntax(
                        value: IntegerLiteralExprSyntax(digits: .integerLiteral("0"))
                    )
                )
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
