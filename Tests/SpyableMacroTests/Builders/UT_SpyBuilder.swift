import XCTest
import SwiftSyntax
@testable import SpyableMacro
import SwiftSyntaxBuilder

final class UT_SpyBuilder: XCTestCase {
    func testDeclarationEmptyProtocol() throws {
        let declaration = DeclSyntax(
            """
            protocol Foo {}
            """
        )
        let protocolDeclaration = try XCTUnwrap(ProtocolDeclSyntax(declaration))

        let result = SpyBuilder().classDeclaration(for: protocolDeclaration)

        assertBuildResult(
            result,
            """
            class FooSpy: Foo {
            }
            """
        )
    }

    func testDeclaration() throws {
        let declaration = DeclSyntax(
            """
            protocol Service {
            func fetch()
            }
            """
        )
        let protocolDeclaration = try XCTUnwrap(ProtocolDeclSyntax(declaration))

        let result = SpyBuilder().classDeclaration(for: protocolDeclaration)

        assertBuildResult(
            result,
            """
            class ServiceSpy: Service {
                var fetchCallsCount = 0
                func fetch() {
                    fetchCallsCount += 1
                }
            }
            """
        )
    }

    func testDeclarationArguments() throws {
        let declaration = DeclSyntax(
            """
            protocol ViewModelProtocol {
            func foo(text: String, count: Int)
            }
            """
        )
        let protocolDeclaration = try XCTUnwrap(ProtocolDeclSyntax(declaration))

        let result = SpyBuilder().classDeclaration(for: protocolDeclaration)

        assertBuildResult(
            result,
            """
            class ViewModelProtocolSpy: ViewModelProtocol {
                var fooWithTextCountCallsCount = 0
                var fooWithTextCountReceivedArguments: (text: String, count: Int)?
                var fooWithTextCountReceivedInvocations: [(text: String, count: Int)] = []
                func foo(text: String, count: Int) {
                    fooWithTextCountCallsCount += 1
                    fooWithTextCountReceivedArguments = (text, count)
                    fooWithTextCountReceivedInvocations.append((text, count))
                }
            }
            """
        )
    }

    func testDeclarationReturnValue() throws {
        let declaration = DeclSyntax(
            """
            protocol Bar {
            func print() -> (text: String, tuple: (count: Int?, Date))
            }
            """
        )
        let protocolDeclaration = try XCTUnwrap(ProtocolDeclSyntax(declaration))


        let result = SpyBuilder().classDeclaration(for: protocolDeclaration)

        assertBuildResult(
            result,
            """
            class BarSpy: Bar {
                var printCallsCount = 0
                var printReturnValue: (text: String, tuple: (count: Int?, Date))!
                func print() -> (text: String, tuple: (count: Int?, Date)) {
                    printCallsCount += 1
                    return printReturnValue
                }
            }
            """
        )
    }
}
