import SwiftSyntax
import SwiftSyntaxMacros

public enum SpyableMacro: PeerMacro {
  private static let extractor = Extractor()
  private static let spyFactory = SpyFactory()

  public static func expansion(
    of node: AttributeSyntax,
    providingPeersOf declaration: some DeclSyntaxProtocol,
    in context: some MacroExpansionContext
  ) throws -> [DeclSyntax] {
    // Extract the protocol declaration
    let protocolDeclaration = try extractor.extractProtocolDeclaration(from: declaration)

    // Extract inherited type from the attribute
    let inheritedType = extractor.extractInheritedType(from: node, in: context)

    // Generate the initial spy class declaration with inherited type
    var spyClassDeclaration = try spyFactory.classDeclaration(
      for: protocolDeclaration,
      inheritedType: inheritedType
    )

    // Apply access level modifiers if needed
    if let accessLevel = determineAccessLevel(
      for: node, protocolDeclaration: protocolDeclaration, context: context)
    {
      spyClassDeclaration = rewriteSpyClass(spyClassDeclaration, withAccessLevel: accessLevel)
    }

    // Handle preprocessor flag
    if let preprocessorFlag = extractor.extractPreprocessorFlag(from: node, in: context) {
      return [wrapInIfConfig(spyClassDeclaration, withFlag: preprocessorFlag)]
    }

    return [DeclSyntax(spyClassDeclaration)]
  }

  /// Determines the access level to use for the spy class.
  private static func determineAccessLevel(
    for node: AttributeSyntax,
    protocolDeclaration: ProtocolDeclSyntax,
    context: MacroExpansionContext
  ) -> DeclModifierSyntax? {
    if let accessLevelFromNode = extractor.extractAccessLevel(from: node, in: context) {
      return accessLevelFromNode
    } else {
      return extractor.extractAccessLevel(from: protocolDeclaration)
    }
  }

  /// Applies the specified access level to the spy class declaration.
  private static func rewriteSpyClass(
    _ spyClassDeclaration: DeclSyntaxProtocol,
    withAccessLevel accessLevel: DeclModifierSyntax
  ) -> ClassDeclSyntax {
    let rewriter = AccessLevelModifierRewriter(newAccessLevel: accessLevel)
    return rewriter.rewrite(spyClassDeclaration).cast(ClassDeclSyntax.self)
  }

  /// Wraps a declaration in an `#if` preprocessor directive.
  private static func wrapInIfConfig(
    _ spyClassDeclaration: ClassDeclSyntax,
    withFlag flag: String
  ) -> DeclSyntax {
    return DeclSyntax(
      IfConfigDeclSyntax(
        clauses: IfConfigClauseListSyntax {
          IfConfigClauseSyntax(
            poundKeyword: .poundIfToken(),
            condition: ExprSyntax(stringLiteral: flag),
            elements: .statements(
              CodeBlockItemListSyntax {
                DeclSyntax(spyClassDeclaration)
              }
            )
          )
        }
      )
    )
  }
}
