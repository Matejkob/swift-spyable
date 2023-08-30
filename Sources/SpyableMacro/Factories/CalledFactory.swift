import SwiftSyntax
import SwiftSyntaxBuilder

/// The `CalledFactory` is designed to generate a representation of a Swift variable
/// declaration to track if a certain function has been called.
///
/// The resulting variable's of type Bool and its name is constructed by appending
/// the word "Called" to the `variablePrefix` parameter. This variable uses a getter
/// that checks whether another variable (with the name `variablePrefix` + "CallsCount")
/// is greater than zero. If so, the getter returns true, indicating the function has been called,
/// otherwise it returns false.
///
/// > Important: The factory assumes the existence of a variable named `variablePrefix + "CallsCount"`,
/// which should keep track of the number of times a function has been called.
///
/// The following code:
/// ```swift
/// var fooCalled: Bool {
///     return fooCallsCount > 0
/// }
/// ```
/// would be generated for a function like this:
/// ```swift
/// func foo()
/// ```
/// and an argument `variablePrefix` equal to `foo`.
struct CalledFactory {
    func variableDeclaration(variablePrefix: String) -> VariableDeclSyntax {
        VariableDeclSyntax(
            bindingSpecifier: .keyword(.var),
            bindingsBuilder: {
                PatternBindingSyntax(
                    pattern: IdentifierPatternSyntax(
                        identifier: .identifier(variablePrefix + "Called")
                    ),
                    typeAnnotation: TypeAnnotationSyntax(
                        type: IdentifierTypeSyntax(name: .identifier("Bool"))
                    ),
                    accessorBlock: AccessorBlockSyntax(
                        accessors: AccessorBlockSyntax.Accessors.getter(
                            CodeBlockItemListSyntax {
                                CodeBlockItemSyntax(
                                    item: .stmt(
                                        StmtSyntax(
                                            ReturnStmtSyntax(
                                                expression: SequenceExprSyntax {
                                                    DeclReferenceExprSyntax(baseName: .identifier(variablePrefix + "CallsCount"))
                                                    BinaryOperatorExprSyntax(operator: .binaryOperator(">"))
                                                    IntegerLiteralExprSyntax(literal: .integerLiteral("0"))
                                                }
                                            )
                                        )
                                    )
                                )
                            }
                        )
                    )
                )
            }
        )
    }
}
