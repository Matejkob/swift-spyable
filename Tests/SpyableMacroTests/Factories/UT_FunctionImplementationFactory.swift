import SwiftSyntax
import XCTest

@testable import SpyableMacro

final class UT_FunctionImplementationFactory: XCTestCase {
  func testInternalDeclaration() throws {
    let variablePrefix = "functionName"

    let protocolFunctionDeclaration = try FunctionDeclSyntax(
      "func foo()"
    ) {}

    let result = FunctionImplementationFactory().declaration(
      variablePrefix: variablePrefix,
      isPublic: false,
      protocolFunctionDeclaration: protocolFunctionDeclaration
    )

    assertBuildResult(
      result,
      """
      func foo() {
          functionNameCallsCount += 1
          functionNameClosure?()
      }
      """
    )
  }
  
  func testPublicDeclaration() throws {
    let variablePrefix = "functionName"

    let protocolFunctionDeclaration = try FunctionDeclSyntax(
      "func foo()"
    ) {}

    let result = FunctionImplementationFactory().declaration(
      variablePrefix: variablePrefix,
      isPublic: true,
      protocolFunctionDeclaration: protocolFunctionDeclaration
    )

    assertBuildResult(
      result,
      """
      public func foo() {
          functionNameCallsCount += 1
          functionNameClosure?()
      }
      """
    )
  }

  func testDeclarationArguments() throws {
    let variablePrefix = "func_name"

    let protocolFunctionDeclaration = try FunctionDeclSyntax(
      "func foo(text: String, count: Int)"
    ) {}

    let result = FunctionImplementationFactory().declaration(
      variablePrefix: variablePrefix,
      isPublic: false,
      protocolFunctionDeclaration: protocolFunctionDeclaration
    )

    assertBuildResult(
      result,
      """
      func foo(text: String, count: Int) {
          func_nameCallsCount += 1
          func_nameReceivedArguments = (text, count)
          func_nameReceivedInvocations.append((text, count))
          func_nameClosure?(text, count)
      }
      """
    )
  }

  func testDeclarationReturnValue() throws {
    let variablePrefix = "funcName"

    let protocolFunctionDeclaration = try FunctionDeclSyntax(
      "func foo() -> (text: String, tuple: (count: Int?, Date))"
    ) {}

    let result = FunctionImplementationFactory().declaration(
      variablePrefix: variablePrefix,
      isPublic: false,
      protocolFunctionDeclaration: protocolFunctionDeclaration
    )

    assertBuildResult(
      result,
      """
      func foo() -> (text: String, tuple: (count: Int?, Date)) {
          funcNameCallsCount += 1
          if funcNameClosure != nil {
              return funcNameClosure!()
          } else {
              return funcNameReturnValue
          }
      }
      """
    )
  }

  func testDeclarationReturnValueAsyncThrows() async throws {
    let variablePrefix = "foo"

    let protocolFunctionDeclaration = try FunctionDeclSyntax(
      "func foo(_ bar: String) async throws -> (text: String, tuple: (count: Int?, Date))"
    ) {}

    let result = FunctionImplementationFactory().declaration(
      variablePrefix: variablePrefix,
      isPublic: false,
      protocolFunctionDeclaration: protocolFunctionDeclaration
    )

    assertBuildResult(
      result,
      """
      func foo(_ bar: String) async throws -> (text: String, tuple: (count: Int?, Date)) {
          fooCallsCount += 1
          fooReceivedBar = (bar)
          fooReceivedInvocations.append((bar))
          if let fooThrowableError {
              throw fooThrowableError
          }
          if fooClosure != nil {
              return try await fooClosure!(bar)
          } else {
              return fooReturnValue
          }
      }
      """
    )
  }

  func testDeclarationWithMutatingKeyword() throws {
    let variablePrefix = "functionName"

    let protocolFunctionDeclaration = try FunctionDeclSyntax(
      "mutating func foo()"
    ) {}

    let result = FunctionImplementationFactory().declaration(
      variablePrefix: variablePrefix,
      isPublic: false,
      protocolFunctionDeclaration: protocolFunctionDeclaration
    )

    assertBuildResult(
      result,
      """
      func foo() {
          functionNameCallsCount += 1
          functionNameClosure?()
      }
      """
    )
  }
}
