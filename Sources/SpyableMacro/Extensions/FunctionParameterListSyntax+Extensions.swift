import SwiftSyntax

extension FunctionParameterListSyntax {
  /// - Returns: Whether or not the parameter list supports generating and using properties to track received arguments and received invocations.
  var supportsParameterTracking: Bool {
    !isEmpty && !containsNonEscapingClosure
  }

  /// - Returns: Whether or not the function parameter list contains a parameter that's a nonescaping closure.
  private var containsNonEscapingClosure: Bool {
    contains {
      if $0.type.is(FunctionTypeSyntax.self) {
        return true
      }
      guard let attributedType = $0.type.as(AttributedTypeSyntax.self),
            attributedType.baseType.is(FunctionTypeSyntax.self) else {
        return false
      }

      return !attributedType.attributes.contains(where: { attribute in
        attribute.as(AttributeSyntax.self)?.attributeName == "escaping"
      })
    }
  }
}
