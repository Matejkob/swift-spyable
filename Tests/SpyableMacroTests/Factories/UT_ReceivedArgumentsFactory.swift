import SwiftSyntax
import XCTest

@testable import SpyableMacro

final class UT_ReceivedArgumentsFactory: XCTestCase {

  // MARK: - Variable Declaration

  func testVariableDeclarationSingleArgument() throws {
    try assertProtocolFunction(
      withFunctionDeclaration: "func foo(bar: String)",
      prefixForVariable: "_prefix_",
      expectingVariableDeclaration: "var _prefix_ReceivedBar: String?"
    )
  }

  func testVariableDeclarationAccess() throws {
    try assertProtocolFunction(
      withFunctionDeclaration: "func foo(bar: String)",
      prefixForVariable: "_prefix_",
      expectingVariableDeclaration: "var _prefix_ReceivedBar: String?"
    )
  }

  func testVariableDeclarationSingleOptionalArgument() throws {
    try assertProtocolFunction(
      withFunctionDeclaration: "func foo(_ price: Decimal?)",
      prefixForVariable: "_prefix_",
      expectingVariableDeclaration: "var _prefix_ReceivedPrice: Decimal?"
    )
  }

  func testVariableDeclarationSingleArgumentDoubleParameterName() throws {
    try assertProtocolFunction(
      withFunctionDeclaration: "func foo(firstName secondName: (String, Int))",
      prefixForVariable: "_prefix_",
      expectingVariableDeclaration: "var _prefix_ReceivedSecondName: (String, Int)?"
    )
  }

  func testVariableDeclarationSingleArgumentWithEscapingAttribute() throws {
    try assertProtocolFunction(
      withFunctionDeclaration: "func foo(completion: @escaping () -> Void)",
      prefixForVariable: "_prefix_",
      expectingVariableDeclaration: "var _prefix_ReceivedCompletion: (() -> Void)?"
    )
  }

  func testVariableDeclarationSingleArgumentWithEscapingAttributeAndTuple() throws {
    try assertProtocolFunction(
      withFunctionDeclaration: "func foo(completion: @escaping (() -> Void))",
      prefixForVariable: "_prefix_",
      expectingVariableDeclaration: "var _prefix_ReceivedCompletion: (() -> Void)?"
    )
  }

  func testVariableDeclarationSingleClosureArgument() throws {
    try assertProtocolFunction(
      withFunctionDeclaration: "func foo(completion: () -> Void)",
      prefixForVariable: "_prefix_",
      expectingVariableDeclaration: "var _prefix_ReceivedCompletion: (() -> Void)?"
    )
  }

  func testVariableDeclarationSingleOptionalClosureArgument() throws {
    try assertProtocolFunction(
      withFunctionDeclaration: "func foo(completion: (() -> Void)?)",
      prefixForVariable: "_prefix_",
      expectingVariableDeclaration: "var _prefix_ReceivedCompletion: (() -> Void)?"
    )
  }

  func testVariableDeclarationMultiArguments() throws {
    try assertProtocolFunction(
      withFunctionDeclaration:
        "func foo(text: String, _ count: (x: Int, UInt?)?, final price: Decimal?)",
      prefixForVariable: "_prefix_",
      expectingVariableDeclaration: """
        var _prefix_ReceivedArguments: (text: String, count: (x: Int, UInt?)?, price: Decimal?)?
        """
    )
  }

  func testVariableDeclarationMultiArgumentsWithEscapingAttribute() throws {
    try assertProtocolFunction(
      withFunctionDeclaration: """
        func foo(completion: @escaping () -> Void, _ count: (x: Int, UInt?)?, final price: Decimal?)
        """,
      prefixForVariable: "_prefix_",
      expectingVariableDeclaration: """
        var _prefix_ReceivedArguments: (completion: () -> Void, count: (x: Int, UInt?)?, price: Decimal?)?
        """
    )
  }

  func testVariableDeclarationMultiArgumentsWithSomeClosureArgument() throws {
    try assertProtocolFunction(
      withFunctionDeclaration: """
        func foo(completion: () -> Void, _ count: (x: Int, UInt?)?, final price: Decimal?)
        """,
      prefixForVariable: "_prefix_",
      expectingVariableDeclaration: """
        var _prefix_ReceivedArguments: (completion: () -> Void, count: (x: Int, UInt?)?, price: Decimal?)?
        """
    )
  }

  func testVariableDeclarationMultiArgumentsWithSomeOptionalClosureArgument() throws {
    try assertProtocolFunction(
      withFunctionDeclaration: """
        func foo(completion: (() -> Void)?, _ count: (x: Int, UInt?)?, final price: Decimal?)
        """,
      prefixForVariable: "_prefix_",
      expectingVariableDeclaration: """
        var _prefix_ReceivedArguments: (completion: (() -> Void)?, count: (x: Int, UInt?)?, price: Decimal?)?
        """
    )
  }

  // MARK: - Assign Value To Variable Expression

  func testAssignValueToVariableExpressionSingleArgumentFirstParameterName() throws {
    try assertProtocolFunction(
      withFunctionDeclaration: "func foo(text: String)",
      prefixForVariable: "_prefix_",
      expectingExpression: "_prefix_ReceivedText = (text)"
    )
  }

  func testAssignValueToVariableExpressionSingleArgumentSecondParameterName() throws {
    try assertProtocolFunction(
      withFunctionDeclaration: "func foo(_ count: Int?)",
      prefixForVariable: "_prefix_",
      expectingExpression: "_prefix_ReceivedCount = (count)"
    )
  }

  func testAssignValueToVariableExpressionSingleArgumentDoubleParameterName() throws {
    try assertProtocolFunction(
      withFunctionDeclaration: "func foo(first second: Data)",
      prefixForVariable: "_prefix_",
      expectingExpression: "_prefix_ReceivedSecond = (second)"
    )
  }

  func testAssignValueToVariableExpressionMultiArguments() throws {
    try assertProtocolFunction(
      withFunctionDeclaration:
        "func foo(text: String, _ count: (x: Int, UInt?)?, final price: Decimal?)",
      prefixForVariable: "_prefix_",
      expectingExpression: "_prefix_ReceivedArguments = (text, count, price)"
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

    let result = try ReceivedArgumentsFactory().variableDeclaration(
      modifiers: [],
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

    let result = ReceivedArgumentsFactory().assignValueToVariableExpression(
      variablePrefix: variablePrefix,
      parameterList: protocolFunctionDeclaration.signature.parameterClause.parameters
    )

    assertBuildResult(result, expectedExpression, file: file, line: line)
  }
}
