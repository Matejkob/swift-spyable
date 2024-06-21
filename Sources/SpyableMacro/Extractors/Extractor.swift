import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

/// A utility  responsible for extracting specific syntax elements from Swift Syntax.
///
/// This struct provides methods to retrieve detailed syntax elements from abstract syntax trees,
/// such as protocol declarations and arguments from attribute..
struct Extractor {
  /// Extracts a `ProtocolDeclSyntax` instance from a given declaration.
  ///
  /// This method takes a declaration conforming to `DeclSyntaxProtocol` and attempts
  /// to downcast it to `ProtocolDeclSyntax`. If the downcast succeeds, the protocol declaration
  /// is returned. Otherwise, it emits an error indicating that the operation is only applicable
  /// to protocol declarations.
  ///
  /// - Parameter declaration: The declaration to be examined, conforming to `DeclSyntaxProtocol`.
  /// - Returns: A `ProtocolDeclSyntax` instance if the input declaration is a protocol declaration.
  /// - Throws: `SpyableDiagnostic.onlyApplicableToProtocol` if the input is not a protocol declaration.
  func extractProtocolDeclaration(
    from declaration: DeclSyntaxProtocol
  ) throws -> ProtocolDeclSyntax {
    guard let protocolDeclaration = declaration.as(ProtocolDeclSyntax.self) else {
      throw SpyableDiagnostic.onlyApplicableToProtocol
    }

    return protocolDeclaration
  }

  /// Extracts a preprocessor flag value from an attribute if present.
  ///
  /// This method analyzes an `AttributeSyntax` to find an argument labeled `behindPreprocessorFlag`.
  /// If found, it verifies that the argument's value is a static string literal. It then returns
  /// this string value. If the specific argument is not found, or if its value is not a static string,
  /// the method provides relevant diagnostics and returns `DEBUG`.
  ///
  /// - Parameters:
  ///   - attribute: The attribute syntax to analyze.
  ///   - context: The macro expansion context in which this operation is performed.
  /// - Returns: The static string literal value of the `behindPreprocessorFlag` argument if present and valid.
  /// - Throws: Diagnostic errors for various failure cases, such as the absence of the argument or non-static string values.
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
      return "DEBUG"
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
}
