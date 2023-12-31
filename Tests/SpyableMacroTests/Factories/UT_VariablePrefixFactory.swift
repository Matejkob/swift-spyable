import SwiftSyntax
import XCTest

@testable import SpyableMacro

final class UT_VariablePrefixFactory: XCTestCase {
  func testTextFunctionWithoutArguments() throws {
    try assertProtocolFunction(
      withFunctionDeclaration: "func foo() -> String",
      expectingVariableName: "foo"
    )
  }

  func testTextFunctionWithSingleArgument() throws {
    try assertProtocolFunction(
      withFunctionDeclaration: "func foo(text: String) -> String",
      expectingVariableName: "fooText"
    )
  }

  func testTextFunctionWithSingleArgumentTwoNames() throws {
    try assertProtocolFunction(
      withFunctionDeclaration: "func foo(generated text: String) -> String",
      expectingVariableName: "fooGenerated"
    )
  }

  func testTextFunctionWithSingleArgumentOnlySecondName() throws {
    try assertProtocolFunction(
      withFunctionDeclaration: "func foo(_ text: String) -> String",
      expectingVariableName: "foo"
    )
  }

  func testTextFunctionWithMultiArguments() throws {
    try assertProtocolFunction(
      withFunctionDeclaration: """
        func foo(
            text1 text2: String,
            _ count2: Int,
            product1 product2: (name: String, price: Decimal)
        ) -> String
        """,
      expectingVariableName: "fooText1Product1"
    )
  }

  // MARK: - Helper Methods for Assertions

  private func assertProtocolFunction(
    withFunctionDeclaration functionDeclaration: String,
    expectingVariableName expectedName: String,
    file: StaticString = #file,
    line: UInt = #line
  ) throws {
    let protocolFunctionDeclaration = try FunctionDeclSyntax("\(raw: functionDeclaration)") {}

    let result = VariablePrefixFactory().text(for: protocolFunctionDeclaration)

    XCTAssertEqual(result, expectedName, file: file, line: line)
  }
}
