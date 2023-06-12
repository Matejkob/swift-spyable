import XCTest
@testable import SpyableMacro
import SwiftSyntax

final class UT_FunctionImplementationBuilder: XCTestCase {
    func testDeclaration() throws {
        let variablePrefix = "functionName"

        let protocolFunctionDeclaration = try FunctionDeclSyntax(
            "func foo()"
        ) {}

        let result = FunctionImplementationBuilder().declaration(
            variablePrefix: variablePrefix,
            protocolFunctionDeclaration: protocolFunctionDeclaration
        )

        assertBuildResult(
            result,
            """
            func foo() {
                functionNameCallsCount += 1
            }
            """
        )
    }

    func testDeclarationArguments() throws {
        let variablePrefix = "func_name"

        let protocolFunctionDeclaration = try FunctionDeclSyntax(
            "func foo(text: String, count: Int)"
        ) {}

        let result = FunctionImplementationBuilder().declaration(
            variablePrefix: variablePrefix,
            protocolFunctionDeclaration: protocolFunctionDeclaration
        )

        assertBuildResult(
            result,
            """
            func foo(text: String, count: Int) {
                func_nameCallsCount += 1
                func_nameReceivedArguments = (text, count)
                func_nameReceivedInvocations.append((text, count))
            }
            """
        )
    }

    func testDeclarationReturnValue() throws {
        let variablePrefix = "funcName"

        let protocolFunctionDeclaration = try FunctionDeclSyntax(
            "func foo() -> (text: String, tuple: (count: Int?, Date))"
        ) {}

        let result = FunctionImplementationBuilder().declaration(
            variablePrefix: variablePrefix,
            protocolFunctionDeclaration: protocolFunctionDeclaration
        )

        assertBuildResult(
            result,
            """
            func foo() -> (text: String, tuple: (count: Int?, Date)) {
                funcNameCallsCount += 1
                return funcNameReturnValue
            }
            """
        )
    }
}
