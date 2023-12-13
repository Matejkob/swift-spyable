import SwiftSyntax
import XCTest

@testable import SpyableMacro

final class UT_CalledFactory: XCTestCase {
  func testInternalVariableDeclaration() throws {
    let variablePrefix = "functionName"
    
    let result = try CalledFactory().variableDeclaration(variablePrefix: variablePrefix, isPublic: false)
    
    assertBuildResult(
      result,
      """
      var functionNameCalled: Bool {
          return functionNameCallsCount > 0
      }
      """
    )
  }
  
  func testPublicVariableDeclaration() throws {
    let variablePrefix = "functionName"
    
    let result = try CalledFactory().variableDeclaration(variablePrefix: variablePrefix, isPublic: true)
    
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
