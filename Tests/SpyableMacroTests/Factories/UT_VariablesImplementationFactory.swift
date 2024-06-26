import SwiftSyntax
import XCTest

@testable import SpyableMacro

final class UT_VariablesImplementationFactory: XCTestCase {

  // MARK: - Variables Declarations

  func testVariablesDeclarations() throws {
    try assertProtocolVariable(
      withVariableDeclaration: "var point: (x: Int, y: Int?, (Int, Int)) { get }",
      expectingVariableDeclaration: """
        var point: (x: Int, y: Int?, (Int, Int)) {
            get {
                underlyingPoint
            }
            set {
                underlyingPoint = newValue
            }
        }
        var underlyingPoint: ((x: Int, y: Int?, (Int, Int)))!
        """
    )
  }

  func testVariablesDeclarationsOptional() throws {
    try assertProtocolVariable(
      withVariableDeclaration: "var foo: String? { get }",
      expectingVariableDeclaration: "var foo: String?"
    )
  }

  func testVariablesDeclarationsForcedUnwrapped() throws {
    try assertProtocolVariable(
      withVariableDeclaration: "var foo: String! { get }",
      expectingVariableDeclaration: "var foo: String!"
    )
  }

  func testVariablesDeclarationsClosure() throws {
    try assertProtocolVariable(
      withVariableDeclaration: "var completion: () -> Void { get }",
      expectingVariableDeclaration: """
        var completion: () -> Void {
            get {
                underlyingCompletion
            }
            set {
                underlyingCompletion = newValue
            }
        }
        var underlyingCompletion: (() -> Void)!
        """
    )
  }

  func testVariablesDeclarationsWithMultiBindings() throws {
    let protocolVariableDeclaration = try VariableDeclSyntax("var foo: String?, bar: Int")

    XCTAssertThrowsError(
      try VariablesImplementationFactory().variablesDeclarations(
        protocolVariableDeclaration: protocolVariableDeclaration
      )
    ) { error in
      XCTAssertEqual(
        error as! SpyableDiagnostic,
        SpyableDiagnostic.variableDeclInProtocolWithNotSingleBinding
      )
    }
  }

  func testVariablesDeclarationsWithTuplePattern() throws {
    let protocolVariableDeclaration = try VariableDeclSyntax("var (x, y): Int")

    XCTAssertThrowsError(
      try VariablesImplementationFactory().variablesDeclarations(
        protocolVariableDeclaration: protocolVariableDeclaration
      )
    ) { error in
      XCTAssertEqual(
        error as! SpyableDiagnostic,
        SpyableDiagnostic.variableDeclInProtocolWithNotIdentifierPattern
      )
    }
  }

  // MARK: - Helper Methods for Assertions

  private func assertProtocolVariable(
    withVariableDeclaration variableDeclaration: String,
    expectingVariableDeclaration expectedDeclaration: String,
    file: StaticString = #file,
    line: UInt = #line
  ) throws {
    let protocolVariableDeclaration = try VariableDeclSyntax("\(raw: variableDeclaration)")

    let result = try VariablesImplementationFactory().variablesDeclarations(
      protocolVariableDeclaration: protocolVariableDeclaration
    )

    assertBuildResult(result, expectedDeclaration, file: file, line: line)
  }
}
