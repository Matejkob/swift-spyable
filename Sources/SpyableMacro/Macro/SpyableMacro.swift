import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics

public enum SpyableMacro: PeerMacro {
    private static let extractor = Extractor()
    private static let spyFactory = SpyFactory()

    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let protocolDeclaration = try extractor.extractProtocolDeclaration(from: declaration)

        let spyClassDeclaration = spyFactory.classDeclaration(for: protocolDeclaration)

        return [DeclSyntax(spyClassDeclaration)]
    }
}
