import SwiftSyntax
import XCTest

@testable import SpyableMacro

final class UT_ThrowableErrorFactory: XCTestCase {

  // MARK: - Variable Declaration

  func testVariableDeclaration() throws {
    let variablePrefix = "functionName"

    let result = try ThrowableErrorFactory().variableDeclaration(variablePrefix: variablePrefix)

    assertBuildResult(
      result,
      """
      var functionNameThrowableError: (any Error)?
      """
    )
  }

  func testTypedVariableDeclaration() throws {
    let variablePrefix = "functionName"
    let typeSpecifier = "ExampleError"

    let result = try ThrowableErrorFactory().variableDeclaration(variablePrefix: variablePrefix, typeSpecifier: typeSpecifier)

    assertBuildResult(
      result,
      """
      var functionNameThrowableError: ExampleError?
      """
    )
  }

  // MARK: - Throw Error Expression

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
