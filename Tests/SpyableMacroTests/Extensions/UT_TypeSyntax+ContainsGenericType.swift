import SwiftSyntax
import XCTest

@testable import SpyableMacro

final class UT_TypeSyntax_ContainsGenericType: XCTestCase {
  func testContainsGenericType_WithTypeSyntax() {
    func typeSyntax(
      with identifier: String,
      containsGenericType genericTypes: Set<String>
    ) -> Bool {
      TypeSyntax(stringLiteral: identifier)
        .containsGenericType(from: genericTypes)
    }

    XCTAssertTrue(typeSyntax(with: "T", containsGenericType: ["T"]))
    XCTAssertFalse(typeSyntax(with: "String", containsGenericType: ["T"]))
  }

  func testContainsGenericType_WithIdentifierTypeSyntax() {
    func typeSyntax(
      with identifier: String,
      containsGenericType genericTypes: Set<String>
    ) -> Bool {
      TypeSyntax(
        IdentifierTypeSyntax(
          name: .identifier(identifier)
        )
      )
      .containsGenericType(from: genericTypes)
    }

    XCTAssertTrue(typeSyntax(with: "T", containsGenericType: ["T"]))
    XCTAssertFalse(typeSyntax(with: "String", containsGenericType: ["T"]))
  }

  func testContainsGenericType_WithArrayTypeSyntax() {
    func typeSyntax(
      with identifier: String,
      containsGenericType genericTypes: Set<String>
    ) -> Bool {
      TypeSyntax(
        ArrayTypeSyntax(
          element: TypeSyntax(stringLiteral: identifier)
        )
      )
      .containsGenericType(from: genericTypes)
    }

    XCTAssertTrue(typeSyntax(with: "T", containsGenericType: ["T"]))
    XCTAssertFalse(typeSyntax(with: "String", containsGenericType: ["T"]))
  }

  func testContainsGenericType_WithGenericArgumentClauseSyntax() {
    func typeSyntax(
      with identifier: String,
      containsGenericType genericTypes: Set<String>
    ) -> Bool {
      TypeSyntax(
        IdentifierTypeSyntax(
          name: .identifier("Array"),
          genericArgumentClause: GenericArgumentClauseSyntax {
            GenericArgumentSyntax(argument: TypeSyntax(stringLiteral: identifier))
          }
        )
      )
      .containsGenericType(from: genericTypes)
    }

    XCTAssertTrue(typeSyntax(with: "T", containsGenericType: ["T"]))
    XCTAssertFalse(typeSyntax(with: "String", containsGenericType: ["T"]))
  }

  func testContainsGenericType_WithTupleTypeSyntax() {
    func typeSyntax(
      with identifier: String,
      containsGenericType genericTypes: Set<String>
    ) -> Bool {
      TypeSyntax(
        TupleTypeSyntax(
          elements: TupleTypeElementListSyntax {
            TupleTypeElementSyntax(
              type: IdentifierTypeSyntax(
                name: .identifier(identifier)
              ))
          })
      )
      .containsGenericType(from: genericTypes)
    }

    XCTAssertTrue(typeSyntax(with: "T", containsGenericType: ["T"]))
    XCTAssertFalse(typeSyntax(with: "String", containsGenericType: ["T"]))
  }

  func testContainsGenericType_WithUnsupportedTypeSyntax() {
    func typeSyntax(
      with identifier: String,
      containsGenericType genericTypes: Set<String>
    ) -> Bool {
      TypeSyntax(
        MissingTypeSyntax(placeholder: .identifier(identifier))
      )
      .containsGenericType(from: genericTypes)
    }

    XCTAssertFalse(typeSyntax(with: "T", containsGenericType: ["T"]))
    XCTAssertFalse(typeSyntax(with: "String", containsGenericType: ["T"]))
  }
}
