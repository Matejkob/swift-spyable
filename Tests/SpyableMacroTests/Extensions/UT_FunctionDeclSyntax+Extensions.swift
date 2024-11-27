import SwiftSyntax
import XCTest

@testable import SpyableMacro

final class UT_FunctionDeclSyntaxExtensions: XCTestCase {

  // MARK: - genericTypes

  func testGenericTypes_WithGenerics() throws {
    let protocolFunctionDeclaration = try FunctionDeclSyntax(
      """
      func foo<T, U>() -> T
      """
    ) {}

    XCTAssertEqual(protocolFunctionDeclaration.genericTypes, ["T", "U"])
  }

  func testGenericTypes_WithoutGenerics() throws {
    let protocolFunctionDeclaration = try FunctionDeclSyntax(
      """
      func foo() -> T
      """
    ) {}

    XCTAssertTrue(protocolFunctionDeclaration.genericTypes.isEmpty)
  }

  // MARK: - forceCastType

  func testForceCastType_WithGeneric() throws {
    let protocolFunctionDeclaration = try FunctionDeclSyntax(
      """
      func foo<T>() -> T
      """
    ) {}

    XCTAssertEqual(
      try XCTUnwrap(protocolFunctionDeclaration.forceCastType).description,
      TypeSyntax(stringLiteral: "T").description
    )
  }

  func testForceCastType_WithoutGeneric() throws {
    let protocolFunctionDeclaration = try FunctionDeclSyntax(
      """
      func foo() -> T
      """
    ) {}

    XCTAssertNil(protocolFunctionDeclaration.forceCastType)
  }
}
