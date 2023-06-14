import SwiftSyntax
import SwiftSyntaxBuilder

/// The `ClosureFactory` is designed to generate a representation of a Swift
/// variable declaration for a closure, as well as the invocation of this closure.
///
/// The generated variable represents a closure that corresponds to a given function
/// signature. The name of the variable is constructed by appending the word "Closure"
/// to the `variablePrefix` parameter.
///
/// The factory also generates a call expression that executes the closure using the names
/// of the parameters from the function signature.
///
/// The following code:
/// ```swift
/// var fooClosure: ((String, Int) async throws -> Data)?
///
/// try await fooClosure!(text, count)
/// ```
/// would be generated for a function like this:
/// ```swift
/// func foo(text: String, count: Int) async throws -> Data
/// ```
/// and an argument `variablePrefix` equal to `foo`.
///
/// - Note: The `ClosureFactory` is useful in scenarios where you need to mock the
///         behavior of a function, particularly for testing purposes. You can use it to define
///         the behavior of the function under different conditions, and validate that your code
///         interacts correctly with the function.
struct ClosureFactory {
    func variableDeclaration(
        variablePrefix: String,
        functionSignature: FunctionSignatureSyntax
    ) -> VariableDeclSyntax {
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
        let calledExpression: ExprSyntaxProtocol

        if functionSignature.output == nil {
            calledExpression = OptionalChainingExprSyntax(
                expression: IdentifierExprSyntax(
                    identifier: variableIdentifier(variablePrefix: variablePrefix)
                )
            )
        } else {
            calledExpression = ForcedValueExprSyntax(
                expression: IdentifierExprSyntax(
                    identifier: variableIdentifier(variablePrefix: variablePrefix)
                )
            )
        }

        var expression: ExprSyntaxProtocol = FunctionCallExprSyntax(
            calledExpression: calledExpression,
            leftParen: .leftParenToken(),
            argumentList: TupleExprElementListSyntax {
                for parameter in functionSignature.input.parameterList {                    
                    TupleExprElementSyntax(
                        expression: IdentifierExprSyntax(
                            identifier: parameter.secondName ?? parameter.firstName
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
