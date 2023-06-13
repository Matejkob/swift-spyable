import XCTest
@testable import SpyableMacro
import SwiftSyntax

final class UT_CallsCountBuilder: XCTestCase {
    func testVariableDeclaration() {
        let variablePrefix = "functionName"

        let result = CallsCountBuilder().variableDeclaration(variablePrefix: variablePrefix)

        assertBuildResult(
            result,
            """
            var functionNameCallsCount = 0
            """
        )
    }

    func testIncrementVariableExpression() {
        let variablePrefix = "function_name"

        let result = CallsCountBuilder().incrementVariableExpression(variablePrefix: variablePrefix)

        assertBuildResult(
            result,
            """
            function_nameCallsCount += 1
            """
        )
    }
}
