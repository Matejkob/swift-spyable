import SwiftDiagnostics

enum SpyableDiagnostic: String, DiagnosticMessage, Error {
    case onlyApplicablToProtocol

    var message: String {
        switch self {
        case .onlyApplicablToProtocol: "`@Spyable` can be apply only to protocol"
        }
    }
    
    var diagnosticID: MessageID {
        MessageID(domain: "SpyableMacro", id: rawValue)
    }
    
    var severity: DiagnosticSeverity {
        switch self {
        case .onlyApplicablToProtocol: .error
        }
    }
}
