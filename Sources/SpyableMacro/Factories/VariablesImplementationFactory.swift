import SwiftSyntax
import SwiftSyntaxBuilder

/// The `VariablesImplementationFactory` is designed to generate Swift variable declarations
/// that mirror the variable declarations of a protocol, but with added getter and setter functionality.
///
/// It takes a `VariableDeclSyntax` instance from a protocol as input and generates two kinds
/// of variable declarations for non-optional type variables:
/// 1. A variable declaration that is a copy of the protocol variable, but with explicit getter and setter
/// accessors that link it to an underlying variable.
/// 2. A variable declaration for the underlying variable that is used in the getter and setter of the protocol variable.
///
/// For optional type variables, the factory simply returns the original variable declaration without accessors.
///
/// The name of the underlying variable is created by appending the name of the protocol variable to the word "underlying",
/// with the first character of the protocol variable name capitalized. The type of the underlying variable is always
/// implicitly unwrapped optional to handle the non-optional protocol variables.
///
/// For example, given a non-optional protocol variable:
/// ```swift
/// var text: String { get set }
/// ```
/// the `VariablesImplementationFactory` generates the following declarations:
/// ```swift
/// var text: String {
///     get { underlyingText }
///     set { underlyingText = newValue }
/// }
/// var underlyingText: String!
/// ```
/// And for an optional protocol variable:
/// ```swift
/// var text: String? { get set }
/// ```
/// the factory returns:
/// ```swift
/// var text: String?
/// ```
///
/// - Note: If the protocol variable declaration does not have a `PatternBindingSyntax` or a type,
///            the current implementation of the factory returns an empty string or does not generate the
///            variable declaration. These cases may be handled with diagnostics in future iterations of this factory.
struct VariablesImplementationFactory {
    private let accessorRemovalVisitor = AccessorRemovalVisitor()
    
    @MemberDeclListBuilder
    func variablesDeclarations(
        protocolVariableDeclaration: VariableDeclSyntax
    ) -> MemberDeclListSyntax {
        if let binding = protocolVariableDeclaration.bindings.first {
            if let variableType = binding.typeAnnotation?.type, variableType.is(OptionalTypeSyntax.self) {
                accessorRemovalVisitor.visit(protocolVariableDeclaration)
            } else {
                protocolVariableDeclarationWithGetterAndSetter(binding: binding)

                underlyingVariableDeclaration(binding: binding)
            }
        }
        // TODO: Consider throwing diagnostic warning/error here
    }

    private func protocolVariableDeclarationWithGetterAndSetter(
        binding: PatternBindingListSyntax.Element
    ) -> VariableDeclSyntax {
        let underlyingVariableName = underlyingVariableName(binding: binding)
        
        return VariableDeclSyntax(
            bindingKeyword: .keyword(.var),
            bindingsBuilder: {
                PatternBindingSyntax(
                    pattern: binding.pattern,
                    typeAnnotation: binding.typeAnnotation,
                    accessor: .accessors(
                        AccessorBlockSyntax(
                            accessors: AccessorListSyntax(
                                arrayLiteral:
                                    "get { \(raw: underlyingVariableName) }",
                                    "set { \(raw: underlyingVariableName) = newValue }"
                            )
                        )
                    )
                )
            }
        )
    }

    private func underlyingVariableDeclaration(
        binding: PatternBindingListSyntax.Element
    ) -> VariableDeclSyntax {
        VariableDeclSyntax(
            bindingKeyword: .keyword(.var),
            bindingsBuilder: {
                PatternBindingSyntax(
                    pattern: IdentifierPatternSyntax(
                        identifier: .identifier(underlyingVariableName(binding: binding))
                    ),
                    typeAnnotation: TypeAnnotationSyntax(
                        type: ImplicitlyUnwrappedOptionalTypeSyntax(
                            wrappedType: TupleTypeSyntax(
                                elements: TupleTypeElementListSyntax {
                                    if let type = binding.typeAnnotation?.type {
                                        TupleTypeElementSyntax(type: type)
                                    }
                                    // Consider throwing diagnostic warning/error here
                                }
                            )
                        )
                    )
                )
            }
        )
    }

    private func underlyingVariableName(binding: PatternBindingListSyntax.Element) -> String {
        guard let identifierPattern = binding.pattern.as(IdentifierPatternSyntax.self) else {
            return "" // TODO: Consider throwing diagnostic warning/error here
        }
        let identifierText = identifierPattern.identifier.text

        return "underlying" + identifierText.prefix(1).uppercased() + identifierText.dropFirst()
    }
}

private class AccessorRemovalVisitor: SyntaxRewriter {
    override func visit(_ node: PatternBindingSyntax) -> PatternBindingSyntax {
        let superResult = super.visit(node)
        return superResult.with(\.accessor, nil)
    }
}
