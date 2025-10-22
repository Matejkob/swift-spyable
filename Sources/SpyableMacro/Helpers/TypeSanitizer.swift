import Foundation
import SwiftSyntax

/// A helper struct that provides methods for sanitizing SwiftSyntax TypeSyntax nodes for use as variable names.
/// This replaces string-based operations with AST-based analysis for more robust type handling.
struct TypeSyntaxSanitizer {

  /// Sanitizes a TypeSyntax node by converting it to a clean string representation suitable for variable names.
  /// This method recursively processes the AST structure to handle complex types.
  /// - Parameter typeSyntax: The TypeSyntax node to sanitize
  /// - Returns: A sanitized string representation suitable for use in variable names
  static func sanitize(_ typeSyntax: TypeSyntax) -> String {
    // Check for trailing optionals first to match legacy behavior
    let (coreType, optionalCount) = extractTrailingOptionals(typeSyntax)
    let sanitizedCore = sanitizeRecursive(coreType)

    // Prepend "Optional" for each trailing optional
    var result = sanitizedCore
    for _ in 0..<optionalCount {
      result = "Optional\(result)"
    }

    return result
  }

  /// Extracts trailing optionals from a type, returning the core type and count of trailing optionals.
  /// This matches the legacy behavior of processing trailing optionals differently.
  /// - Parameter typeSyntax: The TypeSyntax node to analyze
  /// - Returns: A tuple containing the core type and the number of trailing optionals
  private static func extractTrailingOptionals(_ typeSyntax: TypeSyntax) -> (TypeSyntax, Int) {
    var currentType = typeSyntax
    var optionalCount = 0

    // Count trailing optionals
    while let optionalType = currentType.as(OptionalTypeSyntax.self) {
      currentType = optionalType.wrappedType
      optionalCount += 1
    }

    // Also handle ImplicitlyUnwrappedOptional
    while let implicitlyUnwrappedOptionalType = currentType.as(
      ImplicitlyUnwrappedOptionalTypeSyntax.self)
    {
      currentType = implicitlyUnwrappedOptionalType.wrappedType
      optionalCount += 1
    }

    return (currentType, optionalCount)
  }

  /// Recursively sanitizes a TypeSyntax node by matching against specific syntax node types.
  /// - Parameter typeSyntax: The TypeSyntax node to sanitize
  /// - Returns: A sanitized string representation
  private static func sanitizeRecursive(_ typeSyntax: TypeSyntax) -> String {
    // Handle Optional types (e.g., String? when nested in another type)
    if let optionalType = typeSyntax.as(OptionalTypeSyntax.self) {
      return "\(sanitizeRecursive(optionalType.wrappedType))Optional"
    }

    // Handle ImplicitlyUnwrappedOptional types (e.g., String!)
    if let implicitlyUnwrappedOptionalType = typeSyntax.as(
      ImplicitlyUnwrappedOptionalTypeSyntax.self)
    {
      return "\(sanitizeRecursive(implicitlyUnwrappedOptionalType.wrappedType))Optional"
    }

    // Handle Array types (e.g., [String])
    if let arrayType = typeSyntax.as(ArrayTypeSyntax.self) {
      return "Array\(sanitizeRecursive(arrayType.element))"
    }

    // Handle Dictionary types (e.g., [String: Int])
    if let dictionaryType = typeSyntax.as(DictionaryTypeSyntax.self) {
      let keyType = sanitizeRecursive(dictionaryType.key)
      let valueType = sanitizeRecursive(dictionaryType.value)
      return "Dictionary\(keyType)\(valueType)"
    }

    // Handle Tuple types (e.g., (String, Int) or (name: String, age: Int))
    if let tupleType = typeSyntax.as(TupleTypeSyntax.self) {
      let elementTypes = tupleType.elements.map { element in
        var result = ""
        // Include label if present (e.g., "name" in "name: String")
        if let label = element.firstName?.text {
          result += label
        }
        result += sanitizeRecursive(element.type)
        return result
      }
      return elementTypes.joined()
    }

    // Handle Function types (e.g., (String) -> Int)
    if let functionType = typeSyntax.as(FunctionTypeSyntax.self) {
      let parameterTypes = functionType.parameters.map { sanitizeRecursive($0.type) }
      let returnType = sanitizeRecursive(functionType.returnClause.type)
      return parameterTypes.joined() + returnType
    }

    // Handle Attributed types (e.g., @escaping (String) -> Void, inout String)
    if let attributedType = typeSyntax.as(AttributedTypeSyntax.self) {
      var specifiers: [String] = []

      // Handle specifiers like 'inout', 'isolated', etc.
      #if canImport(SwiftSyntax600)
        for specifier in attributedType.specifiers {
          specifiers.append(specifier.trimmedDescription)
        }
      #else
        if let specifier = attributedType.specifier {
          specifiers.append(specifier.trimmedDescription)
        }
      #endif

      // Handle attributes like '@escaping', '@Sendable'
      let attributes = attributedType.attributes.compactMap { attribute in
        if let simpleAttribute = attribute.as(AttributeSyntax.self) {
          return sanitizeAttributeName(simpleAttribute.attributeName.trimmedDescription)
        }
        return nil
      }

      let baseType = sanitizeRecursive(attributedType.baseType)
      return specifiers.joined() + attributes.joined() + baseType
    }

    // Handle Generic types (e.g., Array<String>)
    if let identifierType = typeSyntax.as(IdentifierTypeSyntax.self) {
      var result = identifierType.name.text

      // Handle generic arguments if present
      if let genericArgumentClause = identifierType.genericArgumentClause {
        let genericArguments = genericArgumentClause.arguments.compactMap { argument in
          #if canImport(SwiftSyntax601)
            if case let .type(type) = argument.argument {
              return sanitizeRecursive(type)
            } else {
              return nil
            }
          #else
            return sanitizeRecursive(argument.argument)
          #endif
        }
        result += genericArguments.joined()
      }

      return result
    }

    // Handle Member types (e.g., Swift.String)
    if let memberType = typeSyntax.as(MemberTypeSyntax.self) {
      let baseType = sanitizeRecursive(memberType.baseType)
      let memberName = memberType.name.text
      return baseType + memberName
    }

    // Handle Composition types (e.g., Codable & Hashable)
    if let compositionType = typeSyntax.as(CompositionTypeSyntax.self) {
      let typeNames = compositionType.elements.map { element in
        sanitizeRecursive(element.type)
      }
      return typeNames.joined()
    }

    // Handle "any" and "some" types (e.g., any Codable, some Protocol)
    if let someOrAnyType = typeSyntax.as(SomeOrAnyTypeSyntax.self) {
      let constraintType = sanitizeRecursive(someOrAnyType.constraint)
      let prefix = someOrAnyType.someOrAnySpecifier.text
      return prefix + constraintType
    }

    // Fallback to string representation for unknown types
    return typeSyntax.trimmedDescription.removeCharacters(in: forbiddenCharacters)
  }

  /// Sanitizes attribute names by removing the @ symbol and keeping the original casing.
  /// - Parameter attributeName: The attribute name to sanitize
  /// - Returns: A sanitized attribute name
  private static func sanitizeAttributeName(_ attributeName: String) -> String {
    let cleaned = attributeName.replacingOccurrences(of: "@", with: "")
    return cleaned
  }

  /// Characters that are not allowed in variable names
  private static let forbiddenCharacters: CharacterSet = [
    ":", "[", "]", "<", ">", "(", ")", ",", " ", "-", "&",
  ]
}

// MARK: - String Extensions

extension String {
  /// Checks if the string represents an optional type (ends with "?")
  fileprivate var isOptional: Bool {
    self.last == "?"
  }

  /// Removes all characters in the given character set from the string
  /// - Parameter set: The character set containing characters to remove
  /// - Returns: A new string with the specified characters removed
  fileprivate func removeCharacters(in set: CharacterSet) -> String {
    return self.unicodeScalars
      .filter { !set.contains($0) }
      .map(String.init)
      .joined()
  }

  /// Removes function attributes (like @escaping, @Sendable) from the string,
  /// replacing them with their non-attributed versions
  /// - Returns: A string with function attributes removed
  fileprivate func removingFunctionAttributes() -> String {
    return
      self
      .replacingOccurrences(of: "@escaping ", with: "escaping")
      .replacingOccurrences(of: "@Sendable ", with: "Sendable")
      .replacingOccurrences(of: "@autoclosure ", with: "autoclosure")
      .replacingOccurrences(of: "@MainActor ", with: "MainActor")
      .replacingOccurrences(of: "@", with: "")  // Remove any remaining @ symbols
  }
}
