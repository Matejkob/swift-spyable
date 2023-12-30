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
      expectingVariableDeclaration: "var _prefix_Closure: (() -> Data )?"
    )
  }

  func testVariableDeclarationEverything() throws {
    try assertProtocolFunction(
      withFunctionDeclaration: """
        func _ignore_(
            text: inout String,
            product: (UInt?, name: String),
            added: (() -> Void)?,
            removed: @escaping () -> Bool
        ) async throws -> (text: String, output: (() -> Void)?)
        """,
      prefixForVariable: "_prefix_",
      expectingVariableDeclaration: """
        var _prefix_Closure: ((inout String, (UInt?, name: String), (() -> Void)?, @escaping () -> Bool) async throws -> (text: String, output: (() -> Void)?) )?
        """
    )
  }

  private func assertProtocolFunction(
    withFunctionDeclaration functionDeclaration: String,
    prefixForVariable variablePrefix: String,
    expectingVariableDeclaration expectedDeclaration: String,
    file: StaticString = #file,
    line: UInt = #line
  ) throws {
    let protocolFunctionDeclaration = try FunctionDeclSyntax("\(raw: functionDeclaration)") {}

    let result = try ClosureFactory().variableDeclaration(
      variablePrefix: variablePrefix,
      functionSignature: protocolFunctionDeclaration.signature
    )

    assertBuildResult(result, expectedDeclaration, file: file, line: line)
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

  func testCallExpressionEverything() throws {
    try assertProtocolFunction(
      withFunctionDeclaration: """
        func _ignore_(text: inout String, product: (UInt?, name: String), added: (() -> Void)?, removed: @escaping () -> Bool) async throws -> String?
        """,
      prefixForVariable: "_prefix_",
      expectingCallExpression: "try await _prefix_Closure!(text, product, added, removed)"
    )
  }

  private func assertProtocolFunction(
    withFunctionDeclaration functionDeclaration: String,
    prefixForVariable variablePrefix: String,
    expectingCallExpression expectedExpression: String,
    file: StaticString = #file,
    line: UInt = #line
  ) throws {
    let protocolFunctionDeclaration = try FunctionDeclSyntax("\(raw: functionDeclaration)") {}

    let result = ClosureFactory().callExpression(
      variablePrefix: variablePrefix,
      functionSignature: protocolFunctionDeclaration.signature
    )

    assertBuildResult(result, expectedExpression, file: file, line: line)
  }
}
