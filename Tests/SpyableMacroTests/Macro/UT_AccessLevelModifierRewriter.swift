import SwiftSyntax
import SwiftSyntaxBuilder
import XCTest

@testable import SpyableMacro

final class UT_AccessLevelModifierRewriter: XCTestCase {
  func testDoesNotAddAccessLevelToPropertyAccessors() throws {
    let declaration = try VariableDeclSyntax(
      """
      var value: Int {
        get { underlyingValue }
        set { underlyingValue = newValue }
      }
      """
    )
    let rewriter = AccessLevelModifierRewriter(
      newAccessLevel: DeclModifierSyntax(name: .keyword(.public))
    )

    XCTAssertEqual(
      rewriter.rewrite(declaration).formatted().description,
      "public " + declaration.formatted().description
    )
  }
}
