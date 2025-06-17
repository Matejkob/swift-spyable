import SwiftSyntax

extension TypeSyntax {

  /// Returns `self`, cast to the first supported `TypeSyntaxSupportingGenerics` type that `self` can be cast to, or `nil` if `self` matches none.
  private var asTypeSyntaxSupportingGenerics: TypeSyntaxSupportingGenerics? {
    for typeSyntax in typeSyntaxesSupportingGenerics {
      guard let cast = self.as(typeSyntax.self) else { continue }
      return cast
    }
    return nil
  }

  /// An array of all of the `TypeSyntax`s that are used to compose this object.
  ///
  /// Ex: If this `TypeSyntax` represents a `TupleTypeSyntax`, `(A, B)`, this will return the two type syntaxes, `A` & `B`.
  private var nestedTypeSyntaxes: [Self] {
    // TODO: An improvement upon this could be to throw an error here, instead of falling back to an empty array. This could be ultimately used to emit a diagnostic about the unsupported TypeSyntax for a better user experience.
    asTypeSyntaxSupportingGenerics?.nestedTypeSyntaxes ?? []
  }

  /// Type erases generic types by substituting their names with `Any`.
  ///
  /// Ex: If this `TypeSyntax` represents a `TupleTypeSyntax`,`(A, B)`, it will be turned into `(Any, B)` if `genericTypes` contains `"A"`.
  /// - Parameter genericTypes: A list of generic type names to check against.
  /// - Returns: This object, but with generic types names replaced with `Any`.
  func erasingGenericTypes(_ genericTypes: Set<String>) -> Self {
    guard !genericTypes.isEmpty else { return self }

    // TODO: An improvement upon this could be to throw an error here, instead of falling back to `self`. This could be ultimately used to emit a diagnostic about the unsupported TypeSyntax for a better user experience.
    return TypeSyntax(
      fromProtocol: asTypeSyntaxSupportingGenerics?.erasingGenericTypes(genericTypes)) ?? self
  }

  /// Recurses through type syntaxes to find all `IdentifierTypeSyntax` leaves, and checks each of them to see if its name exists in `genericTypes`.
  ///
  /// Ex: If this `TypeSyntax` represents a `TupleTypeSyntax`,`(A, B)`, it will return `true` if `genericTypes` contains `"A"`.
  /// - Parameter genericTypes: A list of generic type names to check against.
  /// - Returns: Whether or not this `TypeSyntax` contains a type matching a name in `genericTypes`.
  func containsGenericType(from genericTypes: Set<String>) -> Bool {
    guard !genericTypes.isEmpty else { return false }

    return
      if let type = self.as(IdentifierTypeSyntax.self),
      genericTypes.contains(type.name.text)
    {
      true
    } else {
      nestedTypeSyntaxes.contains { $0.containsGenericType(from: genericTypes) }
    }
  }
}

// MARK: - TypeSyntaxSupportingGenerics

/// Conform type syntaxes to this protocol and add them to `typeSyntaxesSupportingGenerics` to support having their generics scanned or type-erased.
///
/// - Warning: We are warned in the documentation of `TypeSyntaxProtocol`, "Do not conform to this protocol yourself". However, we don't use this protocol for anything other than defining additional behavior on particular conformers to `TypeSyntaxProtocol`; we're not using this to define a new type syntax.
private protocol TypeSyntaxSupportingGenerics: TypeSyntaxProtocol {
  /// Type syntaxes that can be found nested within this type.
  ///
  /// Ex: A `TupleTypeSyntax` representing `(A, (B, C))` would have the two nested type syntaxes: `IdentityTypeSyntax`, which would represent `A`, and `TupleTypeSyntax` would represent `(B, C)`, which would in turn have its own `nestedTypeSyntaxes`.
  var nestedTypeSyntaxes: [TypeSyntax] { get }

  /// Returns `self` with generics replaced with `Any`, when the generic identifiers exist in `genericTypes`.
  func erasingGenericTypes(_ genericTypes: Set<String>) -> Self
}

private let typeSyntaxesSupportingGenerics: [TypeSyntaxSupportingGenerics.Type] = [
  IdentifierTypeSyntax.self,  // Start with IdentifierTypeSyntax for the sake of efficiency when looping through this array, as it's the most common TypeSyntax.
  ArrayTypeSyntax.self,
  GenericArgumentClauseSyntax.self,
  TupleTypeSyntax.self,
]

extension IdentifierTypeSyntax: TypeSyntaxSupportingGenerics {
  fileprivate var nestedTypeSyntaxes: [TypeSyntax] {
    genericArgumentClause?.nestedTypeSyntaxes ?? []
  }
  fileprivate func erasingGenericTypes(_ genericTypes: Set<String>) -> Self {
    var copy = self
    if genericTypes.contains(name.text) {
      copy = copy.with(\.name.tokenKind, .identifier("Any"))
    }
    if let genericArgumentClause {
      copy = copy.with(
        \.genericArgumentClause,
        genericArgumentClause.erasingGenericTypes(genericTypes)
      )
    }
    return copy
  }
}

extension ArrayTypeSyntax: TypeSyntaxSupportingGenerics {
  fileprivate var nestedTypeSyntaxes: [TypeSyntax] {
    [element]
  }
  fileprivate func erasingGenericTypes(_ genericTypes: Set<String>) -> Self {
    with(\.element, element.erasingGenericTypes(genericTypes))
  }
}

#if compiler(>=6.0)
  extension GenericArgumentClauseSyntax: @retroactive TypeSyntaxProtocol {}
#endif

extension GenericArgumentClauseSyntax: TypeSyntaxSupportingGenerics {
  fileprivate var nestedTypeSyntaxes: [TypeSyntax] {
    arguments.compactMap {
      #if canImport(SwiftSyntax601)
        if case let .type(type) = $0.argument {
            return type
        } else {
          return nil
        }
      #else
        return $0.argument
      #endif
    }
  }
  
  fileprivate func erasingGenericTypes(_ genericTypes: Set<String>) -> Self {
    var newArgumentElements: [GenericArgumentSyntax] = []
    
    for argumentElement in arguments {
      #if canImport(SwiftSyntax601)
        let newArgument: TypeSyntax
        switch argumentElement.argument {
        case let .type(type):
          newArgument = type.erasingGenericTypes(genericTypes)
        default: continue
        }
      #else
        let newArgument: TypeSyntax = argumentElement.argument.erasingGenericTypes(genericTypes)
      #endif
      let newArgumentElement = GenericArgumentSyntax(
        argument: newArgument,
        trailingComma: argumentElement.trailingComma
      )
      newArgumentElements.append(newArgumentElement)
    }
    
    let newArguments = GenericArgumentListSyntax(newArgumentElements)
    
    return Self(
      leftAngle: self.leftAngle,
      arguments: newArguments,
      rightAngle: self.rightAngle
    )
  }
}

extension TupleTypeSyntax: TypeSyntaxSupportingGenerics {
  fileprivate var nestedTypeSyntaxes: [TypeSyntax] {
    elements.map { $0.type }
  }
  
  fileprivate func erasingGenericTypes(_ genericTypes: Set<String>) -> Self {
    with(
      \.elements,
      TupleTypeElementListSyntax {
        for element in elements {
          element.with(
            \.type,
            element.type.erasingGenericTypes(genericTypes))
        }
      }
    )
  }
}
