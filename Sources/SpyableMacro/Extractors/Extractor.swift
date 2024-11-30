import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

/// `Extractor` is a utility designed to analyze and extract specific syntax elements from the protocol declartion.
///
/// This struct provides methods for working with protocol declarations, access levels,
/// and attributes, simplifying the task of retrieving and validating syntax information.
struct Extractor {
  /// Extracts a `ProtocolDeclSyntax` instance from a given declaration.
  ///
  /// This method ensures that the provided declaration conforms to `ProtocolDeclSyntax`.
  /// If the declaration is not a protocol, an error is thrown.
  ///
  /// - Parameter declaration: The declaration to examine, conforming to `DeclSyntaxProtocol`.
  /// - Returns: A `ProtocolDeclSyntax` instance if the input is a protocol declaration.
  /// - Throws: `SpyableDiagnostic.onlyApplicableToProtocol` if the input is not a protocol.
  func extractProtocolDeclaration(
    from declaration: DeclSyntaxProtocol
  ) throws -> ProtocolDeclSyntax {
    guard let protocolDeclaration = declaration.as(ProtocolDeclSyntax.self) else {
      throw SpyableDiagnostic.onlyApplicableToProtocol
    }
    return protocolDeclaration
  }

  /// Extracts a preprocessor flag value from an attribute if present and valid.
  ///
  /// This method searches for an argument labeled `behindPreprocessorFlag` within the
  /// given attribute. If the argument is found, its value is validated to ensure it is
  /// a static string literal.
  ///
  /// - Parameters:
  ///   - attribute: The attribute syntax to analyze.
  ///   - context: The macro expansion context in which the operation is performed.
  /// - Returns: The static string literal value of the `behindPreprocessorFlag` argument,
  ///   or `nil` if the argument is missing or invalid.
  /// - Throws: Diagnostic errors if the argument is invalid or absent.
  func extractPreprocessorFlag(
    from attribute: AttributeSyntax,
    in context: some MacroExpansionContext
  ) throws -> String? {
    guard case let .argumentList(argumentList) = attribute.arguments else {
      // No arguments are present in the attribute.
      return nil
    }

    guard
      let behindPreprocessorFlagArgument = argumentList.first(where: { argument in
        argument.label?.text == "behindPreprocessorFlag"
      })
    else {
      // The `behindPreprocessorFlag` argument is missing.
      return nil
    }

    let segments = behindPreprocessorFlagArgument.expression
      .as(StringLiteralExprSyntax.self)?
      .segments

    guard let segments,
      segments.count == 1,
      case let .stringSegment(literalSegment)? = segments.first
    else {
      // The `behindPreprocessorFlag` argument's value is not a static string literal.
      context.diagnose(
        Diagnostic(
          node: attribute,
          message: SpyableDiagnostic.behindPreprocessorFlagArgumentRequiresStaticStringLiteral,
          highlights: [Syntax(behindPreprocessorFlagArgument.expression)],
          notes: [
            Note(
              node: Syntax(behindPreprocessorFlagArgument.expression),
              message: SpyableNoteMessage.behindPreprocessorFlagArgumentRequiresStaticStringLiteral
            )
          ]
        )
      )
      return nil
    }

    return literalSegment.content.text
  }

  /// Extracts the access level modifier from a protocol declaration.
  ///
  /// This method identifies the first access level modifier present in the protocol
  /// declaration. Supported access levels include `public`, `internal`, `fileprivate`,
  /// `private`, and `package`.
  ///
  /// - Parameter protocolDeclSyntax: The protocol declaration to analyze.
  /// - Returns: The `DeclModifierSyntax` representing the access level, or `nil` if no
  ///   valid access level modifier is found.
  func extractAccessLevel(from protocolDeclSyntax: ProtocolDeclSyntax) -> DeclModifierSyntax? {
    protocolDeclSyntax.modifiers.first(where: \.name.isAccessLevelSupportedInProtocol)
  }
}

extension TokenSyntax {
  /// Determines if the token represents a supported access level modifier for protocols.
  ///
  /// Supported access levels are:
  /// - `public`
  /// - `package`
  /// - `internal`
  /// - `fileprivate`
  /// - `private`
  ///
  /// - Returns: `true` if the token matches one of the supported access levels; otherwise, `false`.
  fileprivate var isAccessLevelSupportedInProtocol: Bool {
    let supportedAccessLevels: [TokenSyntax] = [
      .keyword(.public),
      .keyword(.package),
      .keyword(.internal),
      .keyword(.fileprivate),
      .keyword(.private),
    ]

    return
      supportedAccessLevels
      .map { $0.text }
      .contains(text)
  }
}
