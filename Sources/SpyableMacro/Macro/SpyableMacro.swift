import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics

public enum SpyableMacro: PeerMacro {
    private static let extractor = Extractor()
    private static let builder = SpyDeclarationsBuilder()

    public static func expansion<Context: MacroExpansionContext, Declaration: DeclSyntaxProtocol>(
        of node: AttributeSyntax,
        providingPeersOf declaration: Declaration,
        in context: Context
    ) throws -> [DeclSyntax] {
        let protocolDeclaration = try extractor.extractProtocolDeclaration(from: declaration)
        
        let spyClassDeclaration = try builder.classDeclaration(for: protocolDeclaration)
        
        return [DeclSyntax(spyClassDeclaration)]
    }
}
