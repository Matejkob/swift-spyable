import SwiftSyntax
import XCTest

@testable import SpyableMacro

final class UT_CalledFactory: XCTestCase {

  // MARK: - Variable Declaration

  func testVariableDeclaration() throws {
    let variablePrefix = "functionName"

    let result = try CalledFactory().variableDeclaration(
      modifiers: [], variablePrefix: variablePrefix)

    assertBuildResult(
      result,
      """
      var functionNameCalled: Bool {
          return functionNameCallsCount > 0
      }
      """
    )
  }

  func testVariableDeclarationWithAccess() throws {
    let variablePrefix = "functionName"

    let result = try CalledFactory().variableDeclaration(
      modifiers: [.init(name: "public")], variablePrefix: variablePrefix)

    assertBuildResult(
      result,
      """
      public var functionNameCalled: Bool {
          return functionNameCallsCount > 0
      }
      """
    )
  }
}
