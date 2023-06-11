import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

private enum Const {
    static let spySuffix = "Spy"

    enum CallsCount {
        static let variableSuffix = "CallsCount"
    }

    enum ReturnValue {
        static let variableSuffix = "ReturnValue"
    }
}

struct SpyDeclarationsBuilder {

    // MARK: - Class Declaration

    func classDeclaration(for protocolDeclaration: ProtocolDeclSyntax) throws -> ClassDeclSyntax {
        let identifier = classIdentifier(from: protocolDeclaration.identifier)

        let functionsDeclarations = protocolDeclaration.memberBlock.members
            .compactMap { $0.decl.as(FunctionDeclSyntax.self) }
        
        return ClassDeclSyntax(
            identifier: identifier,
            inheritanceClause: TypeInheritanceClauseSyntax {
                InheritedTypeSyntax(typeName: SimpleTypeIdentifierSyntax(name: protocolDeclaration.identifier))
            },
            memberBlockBuilder: {
                for functionDeclaration in functionsDeclarations {
                    let variablePrefix = spyPropertyDescription(for: functionDeclaration)

                    /*
                     var fooCallsCount = 0
                     */
                    callsCountVariableDeclaration(withPrefix: variablePrefix)

                    /*
                     var fooReturnValue: String!
                     */
                    if let returnType = functionDeclaration.signature.output?.returnType {
                        returnValueVariableDeclaration(ofType: returnType, withPrefix: variablePrefix)
                    }

                    /*
                     func foo() -> String { ... }
                     */
                    implementedFunction(with: functionDeclaration, and: variablePrefix)
                }
            }
        )
    }

    // MARK: - Class Identifier

    func classIdentifier(from protocolDeclarationIdentifier: TokenSyntax) -> TokenSyntax {
        TokenSyntax.identifier(protocolDeclarationIdentifier.text + Const.spySuffix)
    }

    // MARK: - Implemented Function

    func implementedFunction(
            with functionDeclaration: FunctionDeclSyntax,
            and variablePrefix: String
    ) -> FunctionDeclSyntax {
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
                incrementCallsCountExpression(withPrefix: variablePrefix)

                /*
                 return fooReturnValue
                 */
                if functionDeclaration.signature.output != nil {
                    returnValueStatement(withPrefix: variablePrefix)
                }
            }
        )

    }

    // MARK: - Calls Count

    func callsCountVariableDeclaration(withPrefix prefix: String) -> VariableDeclSyntax {
        VariableDeclSyntax(
            bindingKeyword: .keyword(.var),
            bindingsBuilder: {
                PatternBindingSyntax(
                    pattern: IdentifierPatternSyntax(
                        identifier: .identifier(prefix + Const.CallsCount.variableSuffix)
                    ),
                    initializer: InitializerClauseSyntax(
                        value: IntegerLiteralExprSyntax(digits: .integerLiteral("0"))
                    )
                )
            }
        )
    }

    func incrementCallsCountExpression(withPrefix prefix: String) -> SequenceExprSyntax {
        SequenceExprSyntax {
            IdentifierExprSyntax(identifier: .identifier(prefix + Const.CallsCount.variableSuffix))
            BinaryOperatorExprSyntax(operatorToken: .binaryOperator("+="))
            IntegerLiteralExprSyntax(digits: .integerLiteral("1"))
        }
    }

    // MARK: - Return Value

    func returnValueVariableDeclaration(
        ofType type: TypeSyntax,
        withPrefix prefix: String
    ) -> VariableDeclSyntax {
        VariableDeclSyntax(
            bindingKeyword: .keyword(.var),
            bindingsBuilder: {
                PatternBindingSyntax(
                    pattern: IdentifierPatternSyntax(
                        identifier: .identifier(prefix + Const.ReturnValue.variableSuffix)
                    ),
                    typeAnnotation: TypeAnnotationSyntax(
                        type: ImplicitlyUnwrappedOptionalTypeSyntax(wrappedType: type)
                    )
                )
            }
        )
    }

    func returnValueStatement(withPrefix prefix: String) -> ReturnStmtSyntax {
        ReturnStmtSyntax(
            returnKeyword: .keyword(.return),
            expression: IdentifierExprSyntax(identifier: .identifier(prefix + Const.ReturnValue.variableSuffix))
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
