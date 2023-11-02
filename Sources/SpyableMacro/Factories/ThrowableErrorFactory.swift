import SwiftSyntax
import SwiftSyntaxBuilder

/// The `ThrowableErrorFactory` is designed to generate a representation of a Swift
/// variable declaration that simulates a throwable error. It is useful for testing how your code
/// handles errors thrown by a function.
///
/// The factory generates an optional variable of type `Error`. The name of the variable
/// is constructed by appending the word "ThrowableError" to the `variablePrefix` parameter.
///
/// The factory also generates an if-let statement that checks whether the variable is not `nil` and
/// throws it as an error if it isn't. This allows you to simulate the throwing of an error in a function.
///
/// The following code:
/// ```swift
/// var fooThrowableError: Error?
///
/// if let fooThrowableError {
///     throw fooThrowableError
/// }
/// ```
/// would be generated for a function like this:
/// ```swift
/// func foo() throws
/// ```
/// and an argument `variablePrefix` equal to `foo`.
///
/// - Note: The `ThrowableErrorFactory` gives you control over the errors that a function throws in
///         your tests. You can use it to simulate different scenarios and verify that your code handles
///         errors correctly.
struct ThrowableErrorFactory {
    func variableDeclaration(variablePrefix: String) throws -> VariableDeclSyntax {
        try VariableDeclSyntax(
            """
            var \(variableIdentifier(variablePrefix: variablePrefix)): Error?
            """
        )
    }

    func throwErrorExpression(variablePrefix: String) -> ExprSyntax {
        ExprSyntax(
            """
            if let \(variableIdentifier(variablePrefix: variablePrefix)) {
                throw \(variableIdentifier(variablePrefix: variablePrefix))
            }
            """
        )
    }

    private func variableIdentifier(variablePrefix: String) -> TokenSyntax {
        TokenSyntax.identifier(variablePrefix + "ThrowableError")
    }
}
