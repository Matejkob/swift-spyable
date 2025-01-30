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

    return DeclModifierListSyntax {
      newAccessLevel
    }
  }
}
