import SwiftSyntax
import SwiftSyntaxBuilder

/// The `AssociatedtypeFactory` struct is responsible for creating GenericParameterClauseSyntax
///
/// The factory constructs the representation by using associatedtype name and inheritedType
/// of the associatedtypeDecl to GenericParameterSyntax
///
/// For example, given the associatedtype declarations:
/// ```swift
/// associatedtype Key: Hashable
/// associatedtype Value
/// ```
/// the `AssociatedtypeFactory` generates the following text:
/// ```
/// <Key: Hashable, Value>
/// ```

struct AssociatedtypeFactory {
  func constructGenericParameterClause(associatedtypeDeclList: [AssociatedTypeDeclSyntax])
    -> GenericParameterClauseSyntax?
  {
    guard !associatedtypeDeclList.isEmpty else { return nil }

    var genericParameterList = [GenericParameterSyntax]()
    for (i, associatedtypeDecl) in associatedtypeDeclList.enumerated() {
      let associatedtypeName = associatedtypeDecl.name
      let typeInheritance: InheritanceClauseSyntax? = associatedtypeDecl.inheritanceClause
      let inheritedType = typeInheritance?.inheritedTypes.first?.type
      let hasTrailingComma: Bool = i < associatedtypeDeclList.count - 1
      let genericParameter = GenericParameterSyntax(
        name: associatedtypeName,
        colon: inheritedType != nil ? typeInheritance?.colon : nil,
        inheritedType: typeInheritance?.inheritedTypes.first?.type,
        trailingComma: hasTrailingComma ? .commaToken() : nil
      )

      genericParameterList.append(genericParameter)
    }

    return GenericParameterClauseSyntax(
      parameters: GenericParameterListSyntax(genericParameterList)
    )
  }
}
