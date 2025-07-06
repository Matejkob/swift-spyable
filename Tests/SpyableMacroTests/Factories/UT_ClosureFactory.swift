import SwiftSyntax
import XCTest

@testable import SpyableMacro

final class UT_ClosureFactory: XCTestCase {

  // MARK: - Variable Declaration

  func testVariableDeclaration() throws {
    try assertProtocolFunction(
      withFunctionDeclaration: "func _ignore_()",
      prefixForVariable: "_prefix_",
      expectingVariableDeclaration: "var _prefix_Closure: (() -> Void)?"
    )
  }

  func testVariableDeclarationArguments() throws {
    try assertProtocolFunction(
      withFunctionDeclaration: "func _ignore_(text: String, count: UInt)",
      prefixForVariable: "_prefix_",
      expectingVariableDeclaration: "var _prefix_Closure: ((String, UInt) -> Void)?"
    )
  }

  func testVariableDeclarationAsync() throws {
    try assertProtocolFunction(
      withFunctionDeclaration: "func _ignore_() async",
      prefixForVariable: "_prefix_",
      expectingVariableDeclaration: "var _prefix_Closure: (() async -> Void)?"
    )
  }

  func testVariableDeclarationThrows() throws {
    try assertProtocolFunction(
      withFunctionDeclaration: "func _ignore_() throws",
      prefixForVariable: "_prefix_",
      expectingVariableDeclaration: "var _prefix_Closure: (() throws -> Void)?"
    )
  }

  func testVariableDeclarationReturnValue() throws {
    try assertProtocolFunction(
      withFunctionDeclaration: "func _ignore_() -> Data",
      prefixForVariable: "_prefix_",
      expectingVariableDeclaration: "var _prefix_Closure: (() -> Data)?"
    )
  }

  func testVariableDeclarationWithInoutAttribute() throws {
    try assertProtocolFunction(
      withFunctionDeclaration: "func _ignore_(value: inout String)",
      prefixForVariable: "_prefix_",
      expectingVariableDeclaration: "var _prefix_Closure: ((inout String) -> Void)?"
    )
  }

  func testVariableDeclarationWithGenericParameter() throws {
    try assertProtocolFunction(
      withFunctionDeclaration: "func _ignore_<T>(value: T)",
      prefixForVariable: "_prefix_",
      expectingVariableDeclaration: "var _prefix_Closure: ((Any) -> Void)?"
    )
  }

  func testVariableDeclarationOptionalTypeReturnValue() throws {
    try assertProtocolFunction(
      withFunctionDeclaration: "func _ignore_() -> Data?",
      prefixForVariable: "_prefix_",
      expectingVariableDeclaration: "var _prefix_Closure: (() -> Data?)?"
    )
  }

  func testVariableDeclarationForcedUnwrappedOptionalTypeReturnValue() throws {
    try assertProtocolFunction(
      withFunctionDeclaration: "func _ignore_() -> Data!",
      prefixForVariable: "_prefix_",
      expectingVariableDeclaration: "var _prefix_Closure: (() -> Data?)?"
    )
  }

  func testVariableDeclarationEverything() throws {
    try assertProtocolFunction(
      withFunctionDeclaration: """
        func _ignore_<T>(text: inout String, value: T, product: (UInt?, name: String), added: (() -> Void)?, removed: @autoclosure @escaping () -> Bool) async throws -> String?
        """,
      prefixForVariable: "_prefix_",
      expectingVariableDeclaration: """
        var _prefix_Closure: ((inout String, Any, (UInt?, name: String), (() -> Void)?, @autoclosure @escaping () -> Bool) async throws -> String?)?
        """
    )
  }

  // MARK: - Call Expression

  func testCallExpression() throws {
    try assertProtocolFunction(
      withFunctionDeclaration: "func _ignore_()",
      prefixForVariable: "_prefix_",
      expectingCallExpression: "_prefix_Closure?()"
    )
  }

  func testCallExpressionArguments() throws {
    try assertProtocolFunction(
      withFunctionDeclaration: "func _ignore_(text: String, count: UInt)",
      prefixForVariable: "_prefix_",
      expectingCallExpression: "_prefix_Closure?(text, count)"
    )
  }

  func testCallExpressionAsync() throws {
    try assertProtocolFunction(
      withFunctionDeclaration: "func _ignore_() async",
      prefixForVariable: "_prefix_",
      expectingCallExpression: "await _prefix_Closure?()"
    )
  }

  func testCallExpressionThrows() throws {
    try assertProtocolFunction(
      withFunctionDeclaration: "func _ignore_() throws",
      prefixForVariable: "_prefix_",
      expectingCallExpression: "try _prefix_Closure?()"
    )
  }

  func testCallExpressionWithInoutAttribute() throws {
    try assertProtocolFunction(
      withFunctionDeclaration: "func _ignore_(value: inout String)",
      prefixForVariable: "_prefix_",
      expectingCallExpression: "_prefix_Closure?(&value)"
    )
  }

  func testCallExpressionWithGenericParameter() throws {
    try assertProtocolFunction(
      withFunctionDeclaration: "func _ignore_<T>(value: T)",
      prefixForVariable: "_prefix_",
      expectingCallExpression: "_prefix_Closure?(value)"
    )
  }

  func testCallExpressionEverything() throws {
    try assertProtocolFunction(
      withFunctionDeclaration: """
        func _ignore_<T>(value: inout T, product: (UInt?, name: String), added: (() -> Void)?, removed: @autoclosure @escaping () -> Bool) async throws -> String?
        """,
      prefixForVariable: "_prefix_",
      expectingCallExpression: "try await _prefix_Closure!(&value, product, added, removed())"
    )
  }

  // MARK: - Helper Methods for Assertions

  private func assertProtocolFunction(
    withFunctionDeclaration functionDeclaration: String,
    prefixForVariable variablePrefix: String,
    expectingVariableDeclaration expectedDeclaration: String,
    file: StaticString = #filePath,
    line: UInt = #line
  ) throws {
    let protocolFunctionDeclaration = try FunctionDeclSyntax("\(raw: functionDeclaration)") {}

    let result = ClosureFactory().variableDeclaration(
      variablePrefix: variablePrefix,
      protocolFunctionDeclaration: protocolFunctionDeclaration
    )

    assertBuildResult(result, expectedDeclaration, file: file, line: line)
  }

  private func assertProtocolFunction(
    withFunctionDeclaration functionDeclaration: String,
    prefixForVariable variablePrefix: String,
    expectingCallExpression expectedExpression: String,
    file: StaticString = #filePath,
    line: UInt = #line
  ) throws {
    let protocolFunctionDeclaration = try FunctionDeclSyntax("\(raw: functionDeclaration)") {}

    let result = ClosureFactory().callExpression(
      variablePrefix: variablePrefix,
      protocolFunctionDeclaration: protocolFunctionDeclaration
    )

    assertBuildResult(result, expectedExpression, file: file, line: line)
  }
}
