import XCTest
@testable import SpyableMacro
import SwiftSyntax

final class UT_CalledBuilder: XCTestCase {
    func testVariableDeclaration() {
        let variablePrefix = "functionName"

        let result = CalledBuilder().variableDeclaration(variablePrefix: variablePrefix)

        assertBuildResult(
            result,
            """
            var functionNameCalled: Bool {
                return functionNameCallsCount > 0
            }
            """
        )
    }

}
