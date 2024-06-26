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
///         the current implementation of the factory returns an empty string or does not generate the
///         variable declaration. These cases may be handled with diagnostics in future iterations of this factory.
/// - Important: The variable declaration must have exactly one binding. Any deviation from this will result in
///              an error diagnostic produced by the macro.
struct VariablesImplementationFactory {
  private let accessorRemovalVisitor = AccessorRemovalVisitor()

  @MemberBlockItemListBuilder
  func variablesDeclarations(
    protocolVariableDeclaration: VariableDeclSyntax
  ) throws -> MemberBlockItemListSyntax {
    if protocolVariableDeclaration.bindings.count == 1 {
      // Since the count of `bindings` is exactly 1, it is safe to force unwrap it.
      let binding = protocolVariableDeclaration.bindings.first!

      /*
       var name: String?
       var name: String!
       */
      if binding.typeAnnotation?.type.is(OptionalTypeSyntax.self) == true ||
          binding.typeAnnotation?.type.is(ImplicitlyUnwrappedOptionalTypeSyntax.self) == true {
        accessorRemovalVisitor.visit(protocolVariableDeclaration)
      /*
       var name: String
       */
      } else {
        try protocolVariableDeclarationWithGetterAndSetter(binding: binding)

        try underlyingVariableDeclaration(binding: binding)
      }
    } else {
      // As far as I know variable declaration in a protocol should have exactly one binding.
      throw SpyableDiagnostic.variableDeclInProtocolWithNotSingleBinding
    }
  }

  private func protocolVariableDeclarationWithGetterAndSetter(
    binding: PatternBindingSyntax
  ) throws -> VariableDeclSyntax {
    try VariableDeclSyntax(
      """
      var \(binding.pattern.trimmed)\(binding.typeAnnotation!.trimmed) {
          get { \(raw: underlyingVariableName(binding: binding)) }
          set { \(raw: underlyingVariableName(binding: binding)) = newValue }
      }
      """
    )
  }

  private func underlyingVariableDeclaration(
    binding: PatternBindingListSyntax.Element
  ) throws -> VariableDeclSyntax {
    try VariableDeclSyntax(
      """
      var \(raw: underlyingVariableName(binding: binding)): (\(binding.typeAnnotation!.type.trimmed))!
      """
    )
  }

  private func underlyingVariableName(binding: PatternBindingListSyntax.Element) throws -> String {
    guard let identifierPattern = binding.pattern.as(IdentifierPatternSyntax.self) else {
      // As far as I know variable declaration in a protocol should have identifier pattern
      throw SpyableDiagnostic.variableDeclInProtocolWithNotIdentifierPattern
    }

    let identifierText = identifierPattern.identifier.text

    return "underlying" + identifierText.prefix(1).uppercased() + identifierText.dropFirst()
  }
}

private class AccessorRemovalVisitor: SyntaxRewriter {
  override func visit(_ node: PatternBindingSyntax) -> PatternBindingSyntax {
    let superResult = super.visit(node)
    return superResult.with(\.accessorBlock, nil)
  }
}
