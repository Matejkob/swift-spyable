import SwiftSyntax

extension FunctionDeclSyntax {
  /// The name of each generic type used. Ex: the set `[T, U]` in `func foo<T, U>()`.
  var genericTypes: Set<String> {
    Set(genericParameterClause?.parameters.map { $0.name.text } ?? [])
  }

  /// If the function declaration requires being cast to a type, this will specify that type.
  /// Namely, this will apply to situations where generics are used in the function, and properties are consequently stored with generic types replaced with `Any`.
  ///
  /// Ex: `func foo() -> T` will create `var fooReturnValue: Any!`, which will be used in the spy method implementation as `fooReturnValue as! T`
  var forceCastType: TypeSyntax? {
    guard !genericTypes.isEmpty,
          let returnType = signature.returnClause?.type,
          returnType.containsGenericType(from: genericTypes) == true else {
      return nil
    }
    return returnType.trimmed
  }
}
