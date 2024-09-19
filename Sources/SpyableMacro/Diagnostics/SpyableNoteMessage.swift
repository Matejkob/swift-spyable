import SwiftDiagnostics

/// An enumeration defining specific note messages related to diagnostic warnings or errors for the Spyable system.
///
/// This enumeration conforms to `NoteMessage`, providing supplementary information that can help in resolving
/// the diagnostic issues identified by `SpyableDiagnostic`. Designed to complement error messages with actionable
/// advice or clarifications.
///
/// - Note: New note messages can be introduced to offer additional guidance for resolving diagnostics encountered in the Spyable system.
enum SpyableNoteMessage: String, NoteMessage {
  case behindPreprocessorFlagArgumentRequiresStaticStringLiteral

  /// Provides a detailed note message for each case, offering guidance or clarification.
  var message: String {
    switch self {
    case .behindPreprocessorFlagArgumentRequiresStaticStringLiteral:
      "Provide a literal string value without any dynamic expressions or interpolations to meet the static string literal requirement."
    }
  }

  #if canImport(SwiftSyntax510)
    /// Unique identifier for each note message, aligning with the corresponding diagnostic message for clarity.
    var noteID: MessageID {
      MessageID(domain: "SpyableMacro", id: rawValue + "NoteMessage")
    }
  #else
    /// Unique identifier for each note message, aligning with the corresponding diagnostic message for clarity.
    //var fixItID: MessageID {
    //  MessageID(domain: "SpyableMacro", id: rawValue + "NoteMessage")
    //}
  #endif
}
