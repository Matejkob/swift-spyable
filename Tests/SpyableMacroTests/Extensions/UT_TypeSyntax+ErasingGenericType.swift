import SwiftSyntax
import XCTest

@testable import SpyableMacro

final class UT_TypeSyntax_ErasingGenericTypes: XCTestCase {
  func testErasingGenericTypes_WithTypeSyntax() {
    func typeSyntaxDescription(with identifier: String) -> String {
      TypeSyntax(stringLiteral: identifier)
        .erasingGenericTypes(["T"])
        .description
    }

    XCTAssertEqual(typeSyntaxDescription(with: " T "), "Any")
    XCTAssertEqual(typeSyntaxDescription(with: " String "), " String ")
  }

  func testErasingGenericTypes_WithIdentifierTypeSyntax() {
    func typeSyntaxDescription(with identifier: String) -> String {
      TypeSyntax(
        IdentifierTypeSyntax(
          leadingTrivia: .space,
          name: .identifier(identifier),
          trailingTrivia: .space
        )
      )
      .erasingGenericTypes(["T"])
      .description
    }

    XCTAssertEqual(typeSyntaxDescription(with: "T"), "Any")
    XCTAssertEqual(typeSyntaxDescription(with: "String"), " String ")
  }

  func testErasingGenericTypes_WithArrayTypeSyntax() {
    func typeSyntaxDescription(with identifier: String) -> String {
      TypeSyntax(
        ArrayTypeSyntax(
          leadingTrivia: .space,
          element: TypeSyntax(stringLiteral: identifier),
          trailingTrivia: .space
        )
      )
      .erasingGenericTypes(["T"])
      .description
    }

    XCTAssertEqual(typeSyntaxDescription(with: "T"), " [Any] ")
    XCTAssertEqual(typeSyntaxDescription(with: "String"), " [String] ")
  }

  func testErasingGenericTypes_WithGenericArgumentClauseSyntax() {
    func typeSyntaxDescription(with identifier: String) -> String {
      TypeSyntax(
        IdentifierTypeSyntax(
          leadingTrivia: .space,
          name: .identifier("Array"),
          genericArgumentClause: GenericArgumentClauseSyntax {
            GenericArgumentSyntax(argument: TypeSyntax(stringLiteral: identifier))
          },
          trailingTrivia: .space
        )
      )
      .erasingGenericTypes(["T"])
      .description
    }

    XCTAssertEqual(typeSyntaxDescription(with: "T"), " Array<Any> ")
    XCTAssertEqual(typeSyntaxDescription(with: "String"), " Array<String> ")
  }

  func testErasingGenericTypes_WithTupleTypeSyntax() {
    func typeSyntaxDescription(with identifier: String) -> String {
      TypeSyntax(
        TupleTypeSyntax(
          leadingTrivia: .space,
          elements: TupleTypeElementListSyntax {
            TupleTypeElementSyntax(
              type: IdentifierTypeSyntax(
                name: .identifier(identifier)
              ))
            TupleTypeElementSyntax(
              type: IdentifierTypeSyntax(
                leadingTrivia: .space,
                name: .identifier("Unerased")
              ))
          },
          trailingTrivia: .space
        )
      )
      .erasingGenericTypes(["T"])
      .description
    }

    XCTAssertEqual(typeSyntaxDescription(with: "T"), " (Any, Unerased) ")
    XCTAssertEqual(typeSyntaxDescription(with: "String"), " (String, Unerased) ")
  }

  func testErasingGenericTypes_WithUnsupportedTypeSyntax() {
    func typeSyntaxDescription(with identifier: String) -> String {
      TypeSyntax(
        MissingTypeSyntax(placeholder: .identifier(identifier))
      )
      .erasingGenericTypes(["T"])
      .description
    }

    XCTAssertEqual(typeSyntaxDescription(with: "T"), "T")
    XCTAssertEqual(typeSyntaxDescription(with: "String"), "String")
  }
}
