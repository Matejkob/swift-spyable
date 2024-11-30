import SwiftSyntax
import SwiftSyntaxMacros

/// `SpyableMacro` is an implementation of the `Spyable` macro, which generates a test spy class
/// for the protocol to which the macro is added.
///
/// The macro uses an `Extractor` to ensure that the `@Spyable` attribute is being used correctly, i.e., it is
/// applied to a protocol declaration. If the attribute is not applied to a protocol, an error is thrown.
///
/// After verifying the protocol, `SpyableMacro` uses a `SpyFactory` to generate a new spy class declaration
/// that implements the given protocol and records interactions with its methods and properties. The resulting
/// class is added to the source file, thus "expanding" the `@Spyable` attribute into this new declaration.
///
/// Additionally, if a `String` value is passed via the `behindPreprocessorFlag` parameter, this will be used to wrap the entire declaration in an preprocessor `IfConfigDeclSyntax`, to allow users to restrict the exposure of their generated spies.
///
/// Example:
/// ```swift
/// @Spyable
/// protocol ServiceProtocol {
///     func fetch(text: String, count: Int) async -> Decimal
/// }
/// ```
/// This will generate a `ServiceProtocolSpy` class that implements `ServiceProtocol` and records method calls.
public enum SpyableMacro: PeerMacro {
  private static let extractor = Extractor()
  private static let spyFactory = SpyFactory()

  public static func expansion(
    of node: AttributeSyntax,
    providingPeersOf declaration: some DeclSyntaxProtocol,
    in context: some MacroExpansionContext
  ) throws -> [DeclSyntax] {
    let protocolDeclaration = try extractor.extractProtocolDeclaration(from: declaration)

    var spyClassDeclaration = try spyFactory.classDeclaration(for: protocolDeclaration)

    if let accessLevel = extractor.extractAccessLevel(from: protocolDeclaration) {
      let accessLevelModifierRewriter = AccessLevelModifierRewriter(newAccessLevel: accessLevel)

      spyClassDeclaration =
        accessLevelModifierRewriter
        .rewrite(spyClassDeclaration)
        .cast(ClassDeclSyntax.self)
    }

    if let flag = try extractor.extractPreprocessorFlag(from: node, in: context) {
      return [
        DeclSyntax(
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
      ]
    } else {
      return [DeclSyntax(spyClassDeclaration)]
    }
  }
}
