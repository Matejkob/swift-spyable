import SwiftSyntax

final class AccessLevelModifierRewriter: SyntaxRewriter {
  let newAccessLevel: DeclModifierSyntax

  init(newAccessLevel: DeclModifierSyntax) {
    /// Property / method must be declared `fileprivate` because it matches a requirement in `private` protocol.
    if newAccessLevel.name.text == TokenSyntax.keyword(.private).text {
      self.newAccessLevel = DeclModifierSyntax(name: .keyword(.fileprivate))
    } else {
      self.newAccessLevel = newAccessLevel
    }
  }

  override func visit(_ node: DeclModifierListSyntax) -> DeclModifierListSyntax {
    if node.parent?.is(FunctionParameterSyntax.self) == true {
      return node
    }

    // Always preserve existing modifiers (like override, convenience, etc.)
    var modifiers = Array(node)
    
    // Special case: if accessLevel is open and this is an initializer, use public instead
    if newAccessLevel.name.text == TokenSyntax.keyword(.open).text,
       let parent = node.parent,
       parent.is(InitializerDeclSyntax.self) {
      modifiers.append(DeclModifierSyntax(name: .keyword(.public)))
    } else {
      // Add the access level modifier for all other cases
      modifiers.append(newAccessLevel)
    }
    
    return DeclModifierListSyntax(modifiers)
  }
}
