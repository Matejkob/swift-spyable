import SwiftSyntax
import XCTest
@testable import SpyableMacro

final class UT_Extractor: XCTestCase {
    private var sut: Extractor!
    
    override func setUp() {
        super.setUp()
        sut = Extractor()
    }
    
    func test_extractProtocolDeclaration_sucessfully() throws {
        let expected = ProtocolDeclSyntax(
            identifier: .identifier("Foo"),
            memberBlock: "{}"
        )
        
        let declaration: DeclSyntax = """
        protocol Foo {}
        """
        
        let resived = try sut.extractProtocolDeclaration(from: declaration)

        // TODO: assert expected and resived
    }

    func test_extractProtocolDeclaration_fails() throws {
        var resivedError: Error?

        let declaration: DeclSyntax = """
        struct Foo {}
        """

        XCTAssertThrowsError(try sut.extractProtocolDeclaration(from: declaration)) { resivedError = $0 }
        let unwrapedRecivedError = try XCTUnwrap(resivedError as? SpyableDiagnostic)
        XCTAssertEqual(unwrapedRecivedError, .onlyApplicablToProtocol)
    }
}

