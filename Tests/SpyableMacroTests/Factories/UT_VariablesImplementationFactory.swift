import XCTest
@testable import SpyableMacro
import SwiftSyntax

final class UT_VariablesImplementationFactory: XCTestCase {
    func testVariablesDeclarations() throws {
        let declaration = DeclSyntax("var point: (x: Int, y: Int?, (Int, Int)) { get }")

        let protocolVariableDeclaration = try XCTUnwrap(VariableDeclSyntax(declaration))

        let result = try VariablesImplementationFactory().variablesDeclarations(
            protocolVariableDeclaration: protocolVariableDeclaration
        )

        assertBuildResult(
            result,
            """
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
        let declaration = DeclSyntax("var foo: String? { get }")

        let protocolVariableDeclaration = try XCTUnwrap(VariableDeclSyntax(declaration))

        let result = try VariablesImplementationFactory().variablesDeclarations(
            protocolVariableDeclaration: protocolVariableDeclaration
        )

        assertBuildResult(
            result,
            """
            var foo: String?
            """
        )
    }

    func testVariablesDeclarationsClosure() throws {
        let declaration = DeclSyntax("var completion: () -> Void { get }")

        let protocolVariableDeclaration = try XCTUnwrap(VariableDeclSyntax(declaration))

        let result = try VariablesImplementationFactory().variablesDeclarations(
            protocolVariableDeclaration: protocolVariableDeclaration
        )

        assertBuildResult(
            result,
            """
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
        let declaration = DeclSyntax("var foo: String?, bar: Int")

        let protocolVariableDeclaration = try XCTUnwrap(VariableDeclSyntax(declaration))

        XCTAssertThrowsError(
            try VariablesImplementationFactory().variablesDeclarations(protocolVariableDeclaration: protocolVariableDeclaration)
        ) { error in
            XCTAssertEqual(error as! SpyableDiagnostic, SpyableDiagnostic.variableDeclInProtocolWithNotSingleBinding)
        }
    }

    func testVariablesDeclarationsWithTuplePattern() throws {
        let declaration = DeclSyntax("var (x, y): Int")

        let protocolVariableDeclaration = try XCTUnwrap(VariableDeclSyntax(declaration))

        XCTAssertThrowsError(
            try VariablesImplementationFactory().variablesDeclarations(protocolVariableDeclaration: protocolVariableDeclaration)
        ) { error in
            XCTAssertEqual(error as! SpyableDiagnostic, SpyableDiagnostic.variableDeclInProtocolWithNotIdentifierPattern)
        }
    }
}
