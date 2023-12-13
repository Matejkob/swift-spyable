import SwiftSyntax
import XCTest

@testable import SpyableMacro

final class UT_ThrowableErrorFactory: XCTestCase {
  func testInternalVariableDeclaration() throws {
    let variablePrefix = "functionName"

    let result = try ThrowableErrorFactory().variableDeclaration(variablePrefix: variablePrefix, isPublic: false)

    assertBuildResult(
      result,
      """
      var functionNameThrowableError: (any Error)?
      """
    )
  }
  
  func testPublicVariableDeclaration() throws {
    let variablePrefix = "functionName"
    
    let result = try ThrowableErrorFactory().variableDeclaration(variablePrefix: variablePrefix, isPublic: true)
    
    assertBuildResult(
      result,
        """
        public var functionNameThrowableError: (any Error)?
        """
    )
  }

  func testThrowErrorExpression() {
    let variablePrefix = "function_name"

    let result = ThrowableErrorFactory().throwErrorExpression(variablePrefix: variablePrefix)

    assertBuildResult(
      result,
      """
      if let function_nameThrowableError {
          throw function_nameThrowableError
      }
      """
    )
  }
}
