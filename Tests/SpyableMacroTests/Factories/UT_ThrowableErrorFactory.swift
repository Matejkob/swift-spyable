import SwiftSyntax
import XCTest

@testable import SpyableMacro

final class UT_ThrowableErrorFactory: XCTestCase {

  // MARK: - Variable Declaration

  func testVariableDeclaration() throws {
    let variablePrefix = "functionName"

    let result = try ThrowableErrorFactory().variableDeclaration(
      modifiers: [], variablePrefix: variablePrefix)

    assertBuildResult(
      result,
      """
      var functionNameThrowableError: (any Error)?
      """
    )
  }

  func testVariableDeclarationWithAccess() throws {
    let variablePrefix = "functionName"

    let result = try ThrowableErrorFactory().variableDeclaration(
      modifiers: [.init(name: "public")],
      variablePrefix: variablePrefix
    )

    assertBuildResult(
      result,
      """
      public var functionNameThrowableError: (any Error)?
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
