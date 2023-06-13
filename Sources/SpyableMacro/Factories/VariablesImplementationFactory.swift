import SwiftSyntax
import SwiftSyntaxBuilder

struct VariablesImplementationFactory {
    private let accessorRemovalVisitor = AccessorRemovalVisitor()
    
    @MemberDeclListBuilder
    func variablesDeclarations(protocolVariableDeclaration: VariableDeclSyntax) -> MemberDeclListSyntax {
        if let binding = protocolVariableDeclaration.bindings.first {
            if let variableType = binding.typeAnnotation?.type, variableType.is(OptionalTypeSyntax.self) {
                accessorRemovalVisitor.visit(protocolVariableDeclaration)
            } else {
                protocolVariableDeclarationWithGetterAndSetter(binding: binding)

                underlyingVariableDeclaration(binding: binding)
            }
        }
        // TODO: Thing about throwing diagnostic here
    }

    private func protocolVariableDeclarationWithGetterAndSetter(binding: PatternBindingListSyntax.Element) -> VariableDeclSyntax {
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

    private func underlyingVariableDeclaration(binding: PatternBindingListSyntax.Element) -> VariableDeclSyntax {
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
                                    // TODO: Thing about throwing diagnostic here
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
            return "" // TODO: Thins about throwing diagnostic here
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
