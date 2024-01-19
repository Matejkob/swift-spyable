import SwiftSyntax

extension VariableDeclSyntax {
  func applying(modifiers: DeclModifierListSyntax) -> VariableDeclSyntax {
    var copy = self
    copy.modifiers = modifiers
    return copy
  }
}
