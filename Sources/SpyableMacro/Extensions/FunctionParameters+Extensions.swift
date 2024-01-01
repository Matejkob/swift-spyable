import SwiftSyntax

extension FunctionParameterListSyntax {
  /// - Returns: Whether or not the function parameter list supports generating and using properties to track received arguments and received invocations.
  var supportsParameterTracking: Bool {
    !isEmpty && !contains { $0.containsNonEscapingClosure }
  }
}

extension FunctionParameterSyntax {
  fileprivate var containsNonEscapingClosure: Bool {
    if type.is(FunctionTypeSyntax.self) {
      return true
    }
    guard let attributedType = type.as(AttributedTypeSyntax.self),
      attributedType.baseType.is(FunctionTypeSyntax.self)
    else {
      return false
    }

    return !attributedType.attributes.contains {
      $0.attributeNameTextMatches(TokenSyntax.keyword(.escaping).text)
    }
  }

  var usesAutoclosure: Bool {
    type.as(AttributedTypeSyntax.self)?.attributes.contains {
      $0.attributeNameTextMatches(TokenSyntax.keyword(.autoclosure).text)
    } == true
  }
}

extension AttributeListSyntax.Element {
  fileprivate func attributeNameTextMatches(_ name: String) -> Bool {
    self.as(AttributeSyntax.self)?.attributeName.as(IdentifierTypeSyntax.self)?.name.text == name
  }
}
