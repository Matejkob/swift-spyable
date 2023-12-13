import SwiftSyntax
import XCTest

@testable import SpyableMacro

final class UT_ReturnValueFactory: XCTestCase {
  func testInternalVariableDeclaration() throws {
    let variablePrefix = "function_name"
    let functionReturnType = TypeSyntax("(text: String, count: UInt)")

    let result = try ReturnValueFactory().variableDeclaration(
      variablePrefix: variablePrefix,
      isPublic: false,
      functionReturnType: functionReturnType
    )

    assertBuildResult(
      result,
      """
      var function_nameReturnValue: (text: String, count: UInt)!
      """
    )
  }
  
  func testPublicVariableDeclaration() throws {
    let variablePrefix = "function_name"
    let functionReturnType = TypeSyntax("(text: String, count: UInt)")
    
    let result = try ReturnValueFactory().variableDeclaration(
      variablePrefix: variablePrefix,
      isPublic: true,
      functionReturnType: functionReturnType
    )
    
    assertBuildResult(
      result,
        """
        public var function_nameReturnValue: (text: String, count: UInt)!
        """
    )
  }

  func testVariableDeclarationOptionType() throws {
    let variablePrefix = "functionName"
    let functionReturnType = TypeSyntax("String?")

    let result = try ReturnValueFactory().variableDeclaration(
      variablePrefix: variablePrefix,
      isPublic: false,
      functionReturnType: functionReturnType
    )

    assertBuildResult(
      result,
      """
      var functionNameReturnValue: String?
      """
    )
  }

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
}
