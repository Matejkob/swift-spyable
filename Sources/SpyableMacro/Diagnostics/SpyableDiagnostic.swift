import SwiftDiagnostics

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
