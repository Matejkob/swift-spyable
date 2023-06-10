import XCTest
import SwiftSyntax
@testable import SpyableMacro
import SwiftSyntaxBuilder

final class UT_SpyDeclarationsBuilder: XCTestCase {
    private var sut: SpyDeclarationsBuilder!

    override func setUp() {
        super.setUp()
        sut = SpyDeclarationsBuilder()
    }
    func test_spyPropertyName() throws {
        let declaration: DeclSyntax = """
        func foo(text: String, value: Int, totalCost: Decimal) {

        }
        """

        let functionDeclaration = try XCTUnwrap(declaration.as(FunctionDeclSyntax.self))

        let result = sut.spyPropertyDescription(for: functionDeclaration)

        print(result)
    }

    func test_spyPropertyName_1() throws {
        let declaration: DeclSyntax = """
        func foo(_ text: String, value: Int, totalCost: Decimal) {

        }
        """

        let functionDeclaration = try XCTUnwrap(declaration.as(FunctionDeclSyntax.self))

        let result = sut.spyPropertyDescription(for: functionDeclaration)

        print(result)
    }
}
