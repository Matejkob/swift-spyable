import SwiftSyntax
import XCTest

@testable import SpyableMacro

final class UT_ClosureFactory: XCTestCase {
  func testInternalVariableDeclaration() throws {
    let variablePrefix = "foo"

    let protocolFunctionDeclaration = try FunctionDeclSyntax(
      """
      func foo()
      """
    ) {}

    let result = try ClosureFactory().variableDeclaration(
      variablePrefix: variablePrefix,
      isPublic: false,
      functionSignature: protocolFunctionDeclaration.signature
    )

    assertBuildResult(
      result,
      """
      var fooClosure: (() -> Void)?
      """
    )
  }
  
  func testPublicVariableDeclaration() throws {
    let variablePrefix = "foo"

    let protocolFunctionDeclaration = try FunctionDeclSyntax(
      """
      func foo()
      """
    ) {}

    let result = try ClosureFactory().variableDeclaration(
      variablePrefix: variablePrefix,
      isPublic: true,
      functionSignature: protocolFunctionDeclaration.signature
    )

    assertBuildResult(
      result,
      """
      public var fooClosure: (() -> Void)?
      """
    )
  }


  func testVariableDeclarationArguments() throws {
    let variablePrefix = "foo"

    let protocolFunctionDeclaration = try FunctionDeclSyntax(
      """
      func foo(text: String, count: UInt)
      """
    ) {}

    let result = try ClosureFactory().variableDeclaration(
      variablePrefix: variablePrefix,
      isPublic: false,
      functionSignature: protocolFunctionDeclaration.signature
    )

    assertBuildResult(
      result,
      """
      var fooClosure: ((String, UInt) -> Void)?
      """
    )
  }

  func testVariableDeclarationAsync() throws {
    let variablePrefix = "foo"

    let protocolFunctionDeclaration = try FunctionDeclSyntax(
      """
      func foo() async
      """
    ) {}

    let result = try ClosureFactory().variableDeclaration(
      variablePrefix: variablePrefix,
      isPublic: false,
      functionSignature: protocolFunctionDeclaration.signature
    )

    assertBuildResult(
      result,
      """
      var fooClosure: (() async -> Void)?
      """
    )
  }

  func testVariableDeclarationThrows() throws {
    let variablePrefix = "foo"

    let protocolFunctionDeclaration = try FunctionDeclSyntax(
      """
      func foo() throws
      """
    ) {}

    let result = try ClosureFactory().variableDeclaration(
      variablePrefix: variablePrefix,
      isPublic: false,
      functionSignature: protocolFunctionDeclaration.signature
    )

    assertBuildResult(
      result,
      """
      var fooClosure: (() throws -> Void)?
      """
    )
  }

  func testVariableDeclarationReturnValue() throws {
    let variablePrefix = "foo"

    let protocolFunctionDeclaration = try FunctionDeclSyntax(
      """
      func foo() -> Data
      """
    ) {}

    let result = try ClosureFactory().variableDeclaration(
      variablePrefix: variablePrefix,
      isPublic: false,
      functionSignature: protocolFunctionDeclaration.signature
    )

    assertBuildResult(
      result,
      """
      var fooClosure: (() -> Data )?
      """
    )
  }

  func testVariableDeclarationEverything() throws {
    let variablePrefix = "foo"

    let protocolFunctionDeclaration = try FunctionDeclSyntax(
      """
      func foo(
          text: inout String,
          product: (UInt?, name: String),
          added: (() -> Void)?,
          removed: @escaping () -> Bool
      ) async throws -> (text: String, output: (() -> Void)?)
      """
    ) {}

    let result = try ClosureFactory().variableDeclaration(
      variablePrefix: variablePrefix,
      isPublic: false,
      functionSignature: protocolFunctionDeclaration.signature
    )

    assertBuildResult(
      result,
      """
      var fooClosure: ((inout String, (UInt?, name: String), (() -> Void)?, @escaping () -> Bool) async throws -> (text: String, output: (() -> Void)?) )?
      """
    )
  }

  func testCallExpression() throws {
    let variablePrefix = "foo"

    let protocolFunctionDeclaration = try FunctionDeclSyntax(
      """
      func foo()
      """
    ) {}

    let result = ClosureFactory().callExpression(
      variablePrefix: variablePrefix,
      functionSignature: protocolFunctionDeclaration.signature
    )

    assertBuildResult(
      result,
      """
      fooClosure?()
      """
    )
  }

  func testCallExpressionArguments() throws {
    let variablePrefix = "foo"

    let protocolFunctionDeclaration = try FunctionDeclSyntax(
      """
      func foo(text: String, count: UInt)
      """
    ) {}

    let result = ClosureFactory().callExpression(
      variablePrefix: variablePrefix,
      functionSignature: protocolFunctionDeclaration.signature
    )

    assertBuildResult(
      result,
      """
      fooClosure?(text, count)
      """
    )
  }

  func testCallExpressionAsync() throws {
    let variablePrefix = "foo"

    let protocolFunctionDeclaration = try FunctionDeclSyntax(
      """
      func foo() async
      """
    ) {}

    let result = ClosureFactory().callExpression(
      variablePrefix: variablePrefix,
      functionSignature: protocolFunctionDeclaration.signature
    )

    assertBuildResult(
      result,
      """
      await fooClosure?()
      """
    )
  }

  func testCallExpressionThrows() throws {
    let variablePrefix = "foo"

    let protocolFunctionDeclaration = try FunctionDeclSyntax(
      """
      func foo() throws
      """
    ) {}

    let result = ClosureFactory().callExpression(
      variablePrefix: variablePrefix,
      functionSignature: protocolFunctionDeclaration.signature
    )

    assertBuildResult(
      result,
      """
      try fooClosure?()
      """
    )
  }

  func testCallExpressionEverything() throws {
    let variablePrefix = "foo"

    let protocolFunctionDeclaration = try FunctionDeclSyntax(
      """
      func foo(text: inout String, product: (UInt?, name: String), added: (() -> Void)?, removed: @escaping () -> Bool) async throws -> String?
      """
    ) {}

    let result = ClosureFactory().callExpression(
      variablePrefix: variablePrefix,
      functionSignature: protocolFunctionDeclaration.signature
    )

    assertBuildResult(
      result,
      """
      try await fooClosure!(text, product, added, removed)
      """
    )
  }
}
