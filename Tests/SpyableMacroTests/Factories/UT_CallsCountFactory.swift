import SwiftSyntax
import XCTest

@testable import SpyableMacro

final class UT_CallsCountFactory: XCTestCase {
  func testInternalVariableDeclaration() throws {
    let variablePrefix = "functionName"

    let result = try CallsCountFactory().variableDeclaration(variablePrefix: variablePrefix, isPublic: false)

    assertBuildResult(
      result,
      """
      var functionNameCallsCount = 0
      """
    )
  }
    
  func testPublicVariableDeclaration() throws {
    let variablePrefix = "functionName"
    
    let result = try CallsCountFactory().variableDeclaration(variablePrefix: variablePrefix, isPublic: true)
    
    assertBuildResult(
      result,
        """
        public var functionNameCallsCount = 0
        """
    )
  }

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
