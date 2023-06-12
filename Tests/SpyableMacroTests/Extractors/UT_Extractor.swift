import SwiftSyntax
import XCTest
@testable import SpyableMacro

final class UT_Extractor: XCTestCase {
    func testExtractProtocolDeclarationSuccessfully() throws {
        let declaration = DeclSyntax(
            """
            protocol Foo {}
            """
        )

        XCTAssertNoThrow(_ = try Extractor().extractProtocolDeclaration(from: declaration))
    }

    func test_extractProtocolDeclaration_fails() throws {
        var receivedError: Error?

        let declaration = DeclSyntax(
            """
            struct Foo {}
            """
        )

        XCTAssertThrowsError(_ = try Extractor().extractProtocolDeclaration(from: declaration)) {
            receivedError = $0
        }
        let unwrappedReceivedError = try XCTUnwrap(receivedError as? SpyableDiagnostic)
        XCTAssertEqual(unwrappedReceivedError, .onlyApplicableToProtocol)
    }
}
