import SwiftSyntax
import XCTest

@testable import SpyableMacro

final class UT_ReceivedInvocationsFactory: XCTestCase {

  // MARK: - Variable Declaration

  func testVariableDeclarationSingleArgument() throws {
    try assertProtocolFunction(
      withFunctionDeclaration: "func foo(bar: String?)",
      prefixForVariable: "_prefix_",
      expectingVariableDeclaration: "var _prefix_ReceivedInvocations: [String?] = []"
    )
  }

  func testVariableDeclarationSingleArgumentTupleType() throws {
    try assertProtocolFunction(
      withFunctionDeclaration: "func foo(_ tuple: (text: String, (Decimal?, date: Date))?)",
      prefixForVariable: "_prefix_",
      expectingVariableDeclaration: """
      var _prefix_ReceivedInvocations: [(text: String, (Decimal?, date: Date))?] = []
      """
    )
  }

  func testVariableDeclarationSingleArgumentWithEscapingAttribute() throws {
    try assertProtocolFunction(
      withFunctionDeclaration: "func bar(completion: @escaping () -> Void)",
      prefixForVariable: "_prefix_",
      expectingVariableDeclaration: "var _prefix_ReceivedInvocations: [() -> Void] = []"
    )
  }

  func testVariableDeclarationSingleClosureArgument() throws {
    try assertProtocolFunction(
      withFunctionDeclaration: "func foo(completion: () -> Void)",
      prefixForVariable: "_prefix_",
      expectingVariableDeclaration: "var _prefix_ReceivedInvocations: [() -> Void] = []"
    )
  }

  func testVariableDeclarationSingleOptionalClosureArgument() throws {
    try assertProtocolFunction(
      withFunctionDeclaration: "func name(completion: (() -> Void)?)",
      prefixForVariable: "_prefix_",
      expectingVariableDeclaration: "var _prefix_ReceivedInvocations: [(() -> Void)?] = []"
    )
  }

  func testVariableDeclarationMultiArguments() throws {
    try assertProtocolFunction(
      withFunctionDeclaration: "func foo(text: String, _ count: (x: Int, UInt?)?, final price: Decimal?)",
      prefixForVariable: "_prefix_",
      expectingVariableDeclaration: """
      var _prefix_ReceivedInvocations: [(text: String, count: (x: Int, UInt?)?, price: Decimal?)] = []
      """
    )
  }

  func testVariableDeclarationMultiArgumentsWithEscapingAttribute() throws {
    try assertProtocolFunction(
      withFunctionDeclaration: "func foo(completion: @escaping () -> Void, count: UInt, final price: Decimal?)",
      prefixForVariable: "_prefix_",
      expectingVariableDeclaration: """
      var _prefix_ReceivedInvocations: [(completion: () -> Void, count: UInt, price: Decimal?)] = []
      """
    )
  }

  func testVariableDeclarationMultiArgumentsWithSomeClosureArgument() throws {
    try assertProtocolFunction(
      withFunctionDeclaration: "func bar(completion: () -> Void, _ count: (x: Int, UInt?)?, final price: Decimal?)",
      prefixForVariable: "_prefix_",
      expectingVariableDeclaration: """
      var _prefix_ReceivedInvocations: [(completion: () -> Void, count: (x: Int, UInt?)?, price: Decimal?)] = []
      """
    )
  }

  func testVariableDeclarationMultiArgumentsWithSomeOptionalClosureArgument() throws {
    try assertProtocolFunction(
      withFunctionDeclaration: "func func_name(completion: (() -> Void)?, _ count: (x: Int, UInt?)?, final price: Decimal?)",
      prefixForVariable: "_prefix_",
      expectingVariableDeclaration: """
      var _prefix_ReceivedInvocations: [(completion: (() -> Void)?, count: (x: Int, UInt?)?, price: Decimal?)] = []
      """
    )
  }

  // MARK: - Append Value To Variable Expression

  func testAppendValueToVariableExpressionSingleArgument() throws {
    try assertProtocolFunction(
      withFunctionDeclaration: "func foo(bar: String?)",
      prefixForVariable: "_prefix_",
      expectingExpression: "_prefix_ReceivedInvocations.append((bar))"
    )
  }

  func testAppendValueToVariableExpressionSingleArgumentTupleType() throws {
    try assertProtocolFunction(
      withFunctionDeclaration: "func foo(_ tuple: (text: String, (Decimal?, date: Date))?)",
      prefixForVariable: "_prefix_",
      expectingExpression: "_prefix_ReceivedInvocations.append((tuple))"
    )
  }

  func testAppendValueToVariableExpressionMultiArguments() throws {
    try assertProtocolFunction(
      withFunctionDeclaration: "func foo(text: String, _ count: (x: Int, UInt?)?, final price: Decimal?)",
      prefixForVariable: "_prefix_",
      expectingExpression: "_prefix_ReceivedInvocations.append((text, count, price))"
    )
  }

  // MARK: - Helper Methods for Assertions

  private func assertProtocolFunction(
    withFunctionDeclaration functionDeclaration: String,
    prefixForVariable variablePrefix: String,
    expectingVariableDeclaration expectedDeclaration: String,
    file: StaticString = #file,
    line: UInt = #line
  ) throws {
    let protocolFunctionDeclaration = try FunctionDeclSyntax("\(raw: functionDeclaration)") {}

    let result = try ReceivedInvocationsFactory().variableDeclaration(
      variablePrefix: variablePrefix,
      parameterList: protocolFunctionDeclaration.signature.parameterClause.parameters
    )

    assertBuildResult(result, expectedDeclaration, file: file, line: line)
  }

  private func assertProtocolFunction(
    withFunctionDeclaration functionDeclaration: String,
    prefixForVariable variablePrefix: String,
    expectingExpression expectedExpression: String,
    file: StaticString = #file,
    line: UInt = #line
  ) throws {
    let protocolFunctionDeclaration = try FunctionDeclSyntax("\(raw: functionDeclaration)") {}

    let result = ReceivedInvocationsFactory().appendValueToVariableExpression(
      variablePrefix: variablePrefix,
      parameterList: protocolFunctionDeclaration.signature.parameterClause.parameters
    )

    assertBuildResult(result, expectedExpression, file: file, line: line)
  }
}
