import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics

public struct SpyableMacro: PeerMacro {
    public static func expansion<Context: MacroExpansionContext, Declaration: DeclSyntaxProtocol>(
        of node: AttributeSyntax,
        providingPeersOf declaration: Declaration,
        in context: Context
    ) throws -> [DeclSyntax] {
        guard let protocolDeclaration = declaration.as(ProtocolDeclSyntax.self) else {
            let diagnostic = Diagnostic(node: Syntax(node), message: SpyableDiagnostic.unknown)
            context.diagnose(diagnostic)
            return []
        }
        
        let identifier = TokenSyntax.identifier(protocolDeclaration.identifier.text + "Spy")
    
        let structDeclaration = StructDeclSyntax(
            identifier: identifier,
            memberBlock: MemberDeclBlockSyntax(stringLiteral: "{}")
        )
         
        return [DeclSyntax(structDeclaration)]
    }
}
