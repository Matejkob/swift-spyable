import XCTest
@testable import SpyableMacro
import SwiftSyntax

final class UT_CallsCountFactory: XCTestCase {
    func testVariableDeclaration() {
        let variablePrefix = "functionName"

        let result = CallsCountFactory().variableDeclaration(variablePrefix: variablePrefix)

        assertBuildResult(
            result,
            """
            var functionNameCallsCount = 0
            """
        )
    }

    func testIncrementVariableExpression() {
        let variablePrefix = "function_name"

        let result = CallsCountFactory().incrementVariableExpression(variablePrefix: variablePrefix)

        assertBuildResult(
            result,
            """
            function_nameCallsCount += 1
            """
        )
    }
}
