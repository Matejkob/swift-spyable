import SwiftSyntax
import XCTest

@testable import SpyableMacro

final class UT_ReceivedInvocationsFactory: XCTestCase {
  // MARK: - Variable Declaration

  func testInternalVariableDeclarationSingleArgument() throws {
    let variablePrefix = "foo"
    let functionDeclaration = try FunctionDeclSyntax(
      "func foo(bar: String?)"
    ) {}

    let result = try ReceivedInvocationsFactory().variableDeclaration(
      variablePrefix: variablePrefix,
      isPublic: false,
      parameterList: functionDeclaration.signature.parameterClause.parameters
    )

    assertBuildResult(
      result,
      """
      var fooReceivedInvocations: [String?] = []
      """
    )
  }
  
  func testPublicVariableDeclarationSingleArgument() throws {
    let variablePrefix = "foo"
    let functionDeclaration = try FunctionDeclSyntax(
      "func foo(bar: String?)"
    ) {}

    let result = try ReceivedInvocationsFactory().variableDeclaration(
      variablePrefix: variablePrefix,
      isPublic: true,
      parameterList: functionDeclaration.signature.parameterClause.parameters
    )

    assertBuildResult(
      result,
      """
      public var fooReceivedInvocations: [String?] = []
      """
    )
  }

  func testVariableDeclarationSingleArgumentTupleType() throws {
    let variablePrefix = "functionName"
    let functionDeclaration = try FunctionDeclSyntax(
      "func foo(_ tuple: (text: String, (Decimal?, date: Date))?)"
    ) {}

    let result = try ReceivedInvocationsFactory().variableDeclaration(
      variablePrefix: variablePrefix,
      isPublic: false,
      parameterList: functionDeclaration.signature.parameterClause.parameters
    )

    assertBuildResult(
      result,
      """
      var functionNameReceivedInvocations: [(text: String, (Decimal?, date: Date))?] = []
      """
    )
  }

  func testVariableDeclarationSingleArgumentWithEscapingAttribute() throws {
    let variablePrefix = "bar"
    let functionDeclaration = try FunctionDeclSyntax(
      "func bar(completion: @escaping () -> Void)"
    ) {}

    let result = try ReceivedInvocationsFactory().variableDeclaration(
      variablePrefix: variablePrefix,
      isPublic: false,
      parameterList: functionDeclaration.signature.parameterClause.parameters
    )

    assertBuildResult(
      result,
      """
      var barReceivedInvocations: [() -> Void] = []
      """
    )
  }

  func testVariableDeclarationSingleClosureArgument() throws {
    let variablePrefix = "foo"
    let functionDeclaration = try FunctionDeclSyntax(
      "func foo(completion: () -> Void)"
    ) {}

    let result = try ReceivedInvocationsFactory().variableDeclaration(
      variablePrefix: variablePrefix,
      isPublic: false,
      parameterList: functionDeclaration.signature.parameterClause.parameters
    )

    assertBuildResult(
      result,
      """
      var fooReceivedInvocations: [() -> Void] = []
      """
    )
  }

  func testVariableDeclarationSingleOptionalClosureArgument() throws {
    let variablePrefix = "name"
    let functionDeclaration = try FunctionDeclSyntax(
      "func name(completion: (() -> Void)?)"
    ) {}

    let result = try ReceivedInvocationsFactory().variableDeclaration(
      variablePrefix: variablePrefix,
      isPublic: false,
      parameterList: functionDeclaration.signature.parameterClause.parameters
    )

    assertBuildResult(
      result,
      """
      var nameReceivedInvocations: [(() -> Void)?] = []
      """
    )
  }

  func testVariableDeclarationMultiArguments() throws {
    let variablePrefix = "func_name"
    let functionDeclaration = try FunctionDeclSyntax(
      "func foo(text: String, _ count: (x: Int, UInt?)?, final price: Decimal?)"
    ) {}

    let result = try ReceivedInvocationsFactory().variableDeclaration(
      variablePrefix: variablePrefix,
      isPublic: false,
      parameterList: functionDeclaration.signature.parameterClause.parameters
    )

    assertBuildResult(
      result,
      """
      var func_nameReceivedInvocations: [(text: String, count: (x: Int, UInt?)?, price: Decimal?)] = []
      """
    )
  }

  func testVariableDeclarationMultiArgumentsWithEscapingAttribute() throws {
    let variablePrefix = "foo"
    let functionDeclaration = try FunctionDeclSyntax(
      "func foo(completion: @escaping () -> Void, count: UInt, final price: Decimal?)"
    ) {}

    let result = try ReceivedInvocationsFactory().variableDeclaration(
      variablePrefix: variablePrefix,
      isPublic: false,
      parameterList: functionDeclaration.signature.parameterClause.parameters
    )

    assertBuildResult(
      result,
      """
      var fooReceivedInvocations: [(completion: () -> Void, count: UInt, price: Decimal?)] = []
      """
    )
  }

  func testVariableDeclarationMultiArgumentsWithSomeClosureArgument() throws {
    let variablePrefix = "bar"
    let functionDeclaration = try FunctionDeclSyntax(
      "func bar(completion: () -> Void, _ count: (x: Int, UInt?)?, final price: Decimal?)"
    ) {}

    let result = try ReceivedInvocationsFactory().variableDeclaration(
      variablePrefix: variablePrefix,
      isPublic: false,
      parameterList: functionDeclaration.signature.parameterClause.parameters
    )

    assertBuildResult(
      result,
      """
      var barReceivedInvocations: [(completion: () -> Void, count: (x: Int, UInt?)?, price: Decimal?)] = []
      """
    )
  }

  func testVariableDeclarationMultiArgumentsWithSomeOptionalClosureArgument() throws {
    let variablePrefix = "func_name"
    let functionDeclaration = try FunctionDeclSyntax(
      "func func_name(completion: (() -> Void)?, _ count: (x: Int, UInt?)?, final price: Decimal?)"
    ) {}

    let result = try ReceivedInvocationsFactory().variableDeclaration(
      variablePrefix: variablePrefix,
      isPublic: false,
      parameterList: functionDeclaration.signature.parameterClause.parameters
    )

    assertBuildResult(
      result,
      """
      var func_nameReceivedInvocations: [(completion: (() -> Void)?, count: (x: Int, UInt?)?, price: Decimal?)] = []
      """
    )
  }

  // MARK: - Append Value To Variable Expression

  func testAppendValueToVariableExpressionSingleArgument() throws {
    let variablePrefix = "funcName"
    let functionDeclaration = try FunctionDeclSyntax(
      "func foo(bar: String?)"
    ) {}

    let result = ReceivedInvocationsFactory().appendValueToVariableExpression(
      variablePrefix: variablePrefix,
      parameterList: functionDeclaration.signature.parameterClause.parameters
    )

    assertBuildResult(
      result,
      """
      funcNameReceivedInvocations.append((bar))
      """
    )
  }

  func testAppendValueToVariableExpressionSingleArgumentTupleType() throws {
    let variablePrefix = "functionName"
    let functionDeclaration = try FunctionDeclSyntax(
      "func foo(_ tuple: (text: String, (Decimal?, date: Date))?)"
    ) {}

    let result = ReceivedInvocationsFactory().appendValueToVariableExpression(
      variablePrefix: variablePrefix,
      parameterList: functionDeclaration.signature.parameterClause.parameters
    )

    assertBuildResult(
      result,
      """
      functionNameReceivedInvocations.append((tuple))
      """
    )
  }

  func testAppendValueToVariableExpressionMultiArguments() throws {
    let variablePrefix = "func_name"
    let functionDeclaration = try FunctionDeclSyntax(
      "func foo(text: String, _ count: (x: Int, UInt?)?, final price: Decimal?)"
    ) {}

    let result = ReceivedInvocationsFactory().appendValueToVariableExpression(
      variablePrefix: variablePrefix,
      parameterList: functionDeclaration.signature.parameterClause.parameters
    )

    assertBuildResult(
      result,
      """
      func_nameReceivedInvocations.append((text, count, price))
      """
    )
  }
}
