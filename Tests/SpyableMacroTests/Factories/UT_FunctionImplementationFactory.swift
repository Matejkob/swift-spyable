import SwiftSyntax
import XCTest

@testable import SpyableMacro

final class UT_FunctionImplementationFactory: XCTestCase {

  // MARK: - Function Declaration

  func testDeclaration() throws {
    try assertProtocolFunction(
      withFunctionDeclaration: "func foo()",
      prefixForVariable: "_prefix_",
      expectingFunctionDeclaration: """
        func foo() {
            _prefix_CallsCount += 1
            _prefix_Closure?()
        }
        """
    )
  }

  func testDeclarationAccessModifiers() throws {
    try assertProtocolFunction(
      withFunctionDeclaration: "public func foo()",
      prefixForVariable: "_prefix_",
      expectingFunctionDeclaration: """
        public func foo() {
            _prefix_CallsCount += 1
            _prefix_Closure?()
        }
        """
    )
  }

  func testDeclarationArguments() throws {
    try assertProtocolFunction(
      withFunctionDeclaration: "func foo(text: String, count: Int)",
      prefixForVariable: "_prefix_",
      expectingFunctionDeclaration: """
        func foo(text: String, count: Int) {
            _prefix_CallsCount += 1
            _prefix_ReceivedArguments = (text, count)
            _prefix_ReceivedInvocations.append((text, count))
            _prefix_Closure?(text, count)
        }
        """
    )
  }

  func testDeclarationReturnValue() throws {
    try assertProtocolFunction(
      withFunctionDeclaration: "func foo() -> (text: String, tuple: (count: Int?, Date))",
      prefixForVariable: "_prefix_",
      expectingFunctionDeclaration: """
        func foo() -> (text: String, tuple: (count: Int?, Date)) {
            _prefix_CallsCount += 1
            if _prefix_Closure != nil {
                return _prefix_Closure!()
            } else {
                return _prefix_ReturnValue
            }
        }
        """
    )
  }

  func testDeclarationReturnValueAsyncThrows() throws {
    try assertProtocolFunction(
      withFunctionDeclaration: """
        func foo(_ bar: String) async throws -> (text: String, tuple: (count: Int?, Date))
        """,
      prefixForVariable: "_prefix_",
      expectingFunctionDeclaration: """
        func foo(_ bar: String) async throws -> (text: String, tuple: (count: Int?, Date)) {
            _prefix_CallsCount += 1
            _prefix_ReceivedBar = (bar)
            _prefix_ReceivedInvocations.append((bar))
            if let _prefix_ThrowableError {
                throw _prefix_ThrowableError
            }
            if _prefix_Closure != nil {
                return try await _prefix_Closure!(bar)
            } else {
                return _prefix_ReturnValue
            }
        }
        """
    )
  }

  func testDeclarationWithMutatingKeyword() throws {
    try assertProtocolFunction(
      withFunctionDeclaration: "mutating func foo()",
      prefixForVariable: "_prefix_",
      expectingFunctionDeclaration: """
        func foo() {
            _prefix_CallsCount += 1
            _prefix_Closure?()
        }
        """
    )
  }

  func testDeclarationWithEscapingAutoClosure() throws {
    try assertProtocolFunction(
      withFunctionDeclaration: "func foo(action: @autoclosure @escaping () -> Void)",
      prefixForVariable: "_prefix_",
      expectingFunctionDeclaration: """
        func foo(action: @autoclosure @escaping () -> Void) {
            _prefix_CallsCount += 1
            _prefix_ReceivedAction = (action)
            _prefix_ReceivedInvocations.append((action))
            _prefix_Closure?(action())
        }
        """
    )
  }

  func testDeclarationWithNonEscapingClosure() throws {
    try assertProtocolFunction(
      withFunctionDeclaration: "func foo(action: () -> Void)",
      prefixForVariable: "_prefix_",
      expectingFunctionDeclaration: """
        func foo(action: () -> Void) {
            _prefix_CallsCount += 1
            _prefix_Closure?(action)
        }
        """
    )
  }

  // MARK: - Helper Methods for Assertions

  private func assertProtocolFunction(
    withFunctionDeclaration functionDeclaration: String,
    prefixForVariable variablePrefix: String,
    expectingFunctionDeclaration expectedDeclaration: String,
    file: StaticString = #file,
    line: UInt = #line
  ) throws {
    let protocolFunctionDeclaration = try FunctionDeclSyntax("\(raw: functionDeclaration)") {}

    let result = FunctionImplementationFactory().declaration(
      modifiers: [],
      variablePrefix: variablePrefix,
      protocolFunctionDeclaration: protocolFunctionDeclaration
    )

    assertBuildResult(result, expectedDeclaration, file: file, line: line)
  }
}
