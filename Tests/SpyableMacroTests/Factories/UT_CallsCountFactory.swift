import SwiftSyntax
import XCTest

@testable import SpyableMacro

final class UT_CallsCountFactory: XCTestCase {

  // MARK: - Variable Declaration

  func testVariableDeclaration() throws {
    let variablePrefix = "functionName"

    let result = try CallsCountFactory().variableDeclaration(
      modifiers: [], variablePrefix: variablePrefix)

    assertBuildResult(
      result,
      """
      var functionNameCallsCount = 0
      """
    )
  }

  func testVariableDeclarationWithAccess() throws {
    let variablePrefix = "functionName"

    let result = try CallsCountFactory().variableDeclaration(
      modifiers: [.init(name: "public")], variablePrefix: variablePrefix)

    assertBuildResult(
      result,
      """
      public var functionNameCallsCount = 0
      """
    )
  }

  // MARK: - Variable Expression

  func testIncrementVariableExpression() {
    let variablePrefix = "function_name"

    let result = CallsCountFactory().incrementVariableExpression(variablePrefix: variablePrefix)

    assertBuildResult(
      result,
      """
      function_nameCallsCount += 1
      """
    )
  }
}
