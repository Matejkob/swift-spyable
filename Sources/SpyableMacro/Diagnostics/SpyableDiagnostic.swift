import SwiftDiagnostics

/// An enumeration defining specific diagnostic error messages for the Spyable system.
///
/// This enumeration conforms to `DiagnosticMessage` and `Error` protocols, facilitating detailed error reporting
/// and seamless integration with Swift's error handling mechanisms. It is designed to be extendable, allowing for
/// the addition of new diagnostic cases as the system evolves.
///
/// - Note: New diagnostic cases can be added to address additional error conditions encountered within the Spyable system.
enum SpyableDiagnostic: String, DiagnosticMessage, Error {
  case onlyApplicableToProtocol
  case variableDeclInProtocolWithNotSingleBinding
  case variableDeclInProtocolWithNotIdentifierPattern
  case behindPreprocessorFlagArgumentRequiresStaticStringLiteral

  /// Provides a human-readable diagnostic message for each diagnostic case.
  var message: String {
    switch self {
    case .onlyApplicableToProtocol:
      "`@Spyable` can only be applied to a `protocol`"
    case .variableDeclInProtocolWithNotSingleBinding:
      "Variable declaration in a `protocol` with the `@Spyable` attribute must have exactly one binding"
    case .variableDeclInProtocolWithNotIdentifierPattern:
      "Variable declaration in a `protocol` with the `@Spyable` attribute must have identifier pattern"
    case .behindPreprocessorFlagArgumentRequiresStaticStringLiteral:
      "The `behindPreprocessorFlag` argument requires a static string literal"
    }
  }

  /// Specifies the severity level of each diagnostic case.
  var severity: DiagnosticSeverity {
    switch self {
    case .onlyApplicableToProtocol,
        .variableDeclInProtocolWithNotSingleBinding,
        .variableDeclInProtocolWithNotIdentifierPattern,
        .behindPreprocessorFlagArgumentRequiresStaticStringLiteral: .error
    }
  }

  /// Unique identifier for each diagnostic message, facilitating precise error tracking.
  var diagnosticID: MessageID {
    MessageID(domain: "SpyableMacro", id: rawValue)
  }
}
