import XCTest
@testable import SpyableMacro
import SwiftSyntax

final class UT_CalledFactory: XCTestCase {
    func testVariableDeclaration() throws {
        let variablePrefix = "functionName"

        let result = try CalledFactory().variableDeclaration(variablePrefix: variablePrefix)

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
