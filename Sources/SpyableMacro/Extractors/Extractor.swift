import SwiftSyntax

struct Extractor {
    func extractProtocolDeclaration(from declaration: DeclSyntaxProtocol) throws -> ProtocolDeclSyntax {
        guard let protocolDeclaration = declaration.as(ProtocolDeclSyntax.self) else {
            throw SpyableDiagnostic.onlyApplicableToProtocol
        }

        return protocolDeclaration
    }
}
