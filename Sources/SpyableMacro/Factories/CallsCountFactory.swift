import SwiftSyntax
import SwiftSyntaxBuilder

/// The `CallsCountFactory` is designed to generate a representation of a Swift variable
/// declaration and its associated increment operation. These constructs are typically used to
/// track the number of times a specific function has been called during the execution of a test case.
///
/// The resulting variable's of type integer variable with an initial value of 0. It's name
/// is constructed by appending "CallsCount" to the `variablePrefix` parameter.
/// The factory's also generating an expression that increments the count of a variable.
///
/// The following code:
/// ```swift
/// var fooCallsCount = 0
///
/// fooCallsCount += 1
/// ```
/// would be generated for a function like this:
/// ```swift
/// func foo()
/// ```
/// and an argument `variablePrefix` equal to `foo`.
struct CallsCountFactory {
    func variableDeclaration(variablePrefix: String) -> VariableDeclSyntax {
        VariableDeclSyntax(
            bindingSpecifier: .keyword(.var),
            bindingsBuilder: {
                PatternBindingSyntax(
                    pattern: IdentifierPatternSyntax(
                        identifier: variableIdentifier(variablePrefix: variablePrefix)
                    ),
                    initializer: InitializerClauseSyntax(
                        value: IntegerLiteralExprSyntax(literal: .integerLiteral("0"))
                    )
                )
            }
        )
    }

    func incrementVariableExpression(variablePrefix: String) -> SequenceExprSyntax {
        SequenceExprSyntax {
            DeclReferenceExprSyntax(baseName: variableIdentifier(variablePrefix: variablePrefix))
            BinaryOperatorExprSyntax(operator: .binaryOperator("+="))
            IntegerLiteralExprSyntax(literal: .integerLiteral("1"))
        }
    }

    private func variableIdentifier(variablePrefix: String) -> TokenSyntax {
        TokenSyntax.identifier(variablePrefix + "CallsCount")
    }
}
