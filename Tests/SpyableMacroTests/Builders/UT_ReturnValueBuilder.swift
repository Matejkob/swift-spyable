import XCTest
@testable import SpyableMacro
import SwiftSyntax

final class UT_ReturnValueBuilder: XCTestCase {
    func testVariableDeclaration() {
        let variablePrefix = "function_name"
        let functionReturnType = TypeSyntax("(text: String, count: UInt)")

        let result = ReturnValueBuilder().variableDeclaration(
            variablePrefix: variablePrefix,
            functionReturnType: functionReturnType
        )

        assertBuildResult(
            result,
            """
            var function_nameReturnValue: (text: String, count: UInt)!
            """
        )
    }

    func testVariableDeclarationOptionType() {
        let variablePrefix = "functionName"
        let functionReturnType = TypeSyntax("String?")

        let result = ReturnValueBuilder().variableDeclaration(
            variablePrefix: variablePrefix,
            functionReturnType: functionReturnType
        )

        assertBuildResult(
            result,
            """
            var functionNameReturnValue: String?
            """
        )
    }

    func testReturnStatement() {
        let variablePrefix = "function_name"

        let result = ReturnValueBuilder().returnStatement(variablePrefix: variablePrefix)

        assertBuildResult(
            result,
            """
            return function_nameReturnValue
            """
        )
    }
}
