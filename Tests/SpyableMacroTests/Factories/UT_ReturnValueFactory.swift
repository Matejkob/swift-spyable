import SwiftSyntax
import XCTest

@testable import SpyableMacro

final class UT_ReturnValueFactory: XCTestCase {

  // MARK: - Variable Declaration

  func testVariableDeclaration() throws {
    try assert(
      functionReturnType: "(text: String, count: UInt)",
      prefixForVariable: "_prefix_",
      expectingVariableDeclaration: "var _prefix_ReturnValue: (text: String, count: UInt)!"
    )
  }

  func testVariableDeclarationOptionType() throws {
    try assert(
      functionReturnType: "String?",
      prefixForVariable: "_prefix_",
      expectingVariableDeclaration: "var _prefix_ReturnValue: String?"
    )
  }

  // MARK: Return Statement

  func testReturnStatement() {
    let variablePrefix = "function_name"

    let result = ReturnValueFactory().returnStatement(variablePrefix: variablePrefix)

    assertBuildResult(
      result,
      """
      return function_nameReturnValue
      """
    )
  }

  // MARK: - Helper Methods for Assertions

  private func assert(
    functionReturnType: TypeSyntax,
    prefixForVariable variablePrefix: String,
    expectingVariableDeclaration expectedDeclaration: String,
    file: StaticString = #file,
    line: UInt = #line
  ) throws {
    let result = try ReturnValueFactory().variableDeclaration(
      variablePrefix: variablePrefix,
      functionReturnType: functionReturnType
    )

    assertBuildResult(result, expectedDeclaration, file: file, line: line)
  }
}
