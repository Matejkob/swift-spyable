import SwiftDiagnostics

/// `SpyableDiagnostic` is an enumeration defining specific error messages related to the Spyable system.
///
/// It conforms to the `DiagnosticMessage` and `Error` protocols to provide comprehensive error information
/// and integrate smoothly with error handling mechanisms.
///
/// - Note: The `SpyableDiagnostic` enum can be expanded to include more diagnostic cases as
///         the Spyable system grows and needs to handle more error types.
enum SpyableDiagnostic: String, DiagnosticMessage, Error {
    case onlyApplicableToProtocol

    var message: String {
        switch self {
        case .onlyApplicableToProtocol: "'@Spyable' can only be applied to a 'protocol'"
        }
    }
    
    var diagnosticID: MessageID {
        MessageID(domain: "SpyableMacro", id: rawValue)
    }
    
    var severity: DiagnosticSeverity {
        switch self {
        case .onlyApplicableToProtocol: .error
        }
    }
}
