import SwiftSyntax
import XCTest

@testable import SpyableMacro

final class UT_VariablePrefixFactory: XCTestCase {
  func testTextFunctionWithoutArguments() throws {
    let declaration: DeclSyntax = "func foo() -> String"
    let functionDeclaration = try XCTUnwrap(FunctionDeclSyntax(declaration))

    let result = VariablePrefixFactory().text(for: functionDeclaration)

    XCTAssertEqual(result, "foo")
  }

  func testTextFunctionWithSingleArgument() throws {
    let declaration: DeclSyntax = "func foo(text: String) -> String"
    let functionDeclaration = try XCTUnwrap(FunctionDeclSyntax(declaration))

    let result = VariablePrefixFactory().text(for: functionDeclaration)

    XCTAssertEqual(result, "fooText")
  }

  func testTextFunctionWithSingleArgumentTwoNames() throws {
    let declaration: DeclSyntax = "func foo(generated text: String) -> String"
    let functionDeclaration = try XCTUnwrap(FunctionDeclSyntax(declaration))

    let result = VariablePrefixFactory().text(for: functionDeclaration)

    XCTAssertEqual(result, "fooGenerated")
  }

  func testTextFunctionWithSingleArgumentOnlySecondName() throws {
    let declaration: DeclSyntax = "func foo(_ text: String) -> String"
    let functionDeclaration = try XCTUnwrap(FunctionDeclSyntax(declaration))

    let result = VariablePrefixFactory().text(for: functionDeclaration)

    XCTAssertEqual(result, "foo")
  }

  func testTextFunctionWithMultiArguments() throws {
    let declaration: DeclSyntax = """
      func foo(text1 text2: String, _ count2: Int, product1 product2: (name: String, price: Decimal)) -> String
      """
    let functionDeclaration = try XCTUnwrap(FunctionDeclSyntax(declaration))

    let result = VariablePrefixFactory().text(for: functionDeclaration)

    XCTAssertEqual(result, "fooText1Product1")
  }
}
