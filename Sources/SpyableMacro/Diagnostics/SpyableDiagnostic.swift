import SwiftDiagnostics

enum SpyableDiagnostic: String, DiagnosticMessage {
    case unknown

    var message: String {
        switch self {
        case .unknown: "Unknown error"
        }
    }
    
    var diagnosticID: MessageID {
        MessageID(domain: "AutoSpyMacro", id: rawValue)
    }
    
    var severity: SwiftDiagnostics.DiagnosticSeverity {
        switch self {
        case .unknown: .error
        }
    }
}

