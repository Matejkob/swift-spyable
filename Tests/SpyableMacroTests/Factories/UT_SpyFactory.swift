import XCTest
import SwiftSyntax
@testable import SpyableMacro
import SwiftSyntaxBuilder

final class UT_SpyFactory: XCTestCase {
    func testDeclarationEmptyProtocol() throws {
        let declaration = DeclSyntax(
            """
            protocol Foo {}
            """
        )
        let protocolDeclaration = try XCTUnwrap(ProtocolDeclSyntax(declaration))

        let result = SpyFactory().classDeclaration(for: protocolDeclaration)

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

        let result = SpyFactory().classDeclaration(for: protocolDeclaration)

        assertBuildResult(
            result,
            """
            class ServiceSpy: Service {
                var fetchCallsCount = 0
                var fetchCalled: Bool {
                    return fetchCallsCount > 0
                }
                var fetchClosure: (() -> Void)?
                func fetch() {
                    fetchCallsCount += 1
                    fetchClosure?()
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

        let result = SpyFactory().classDeclaration(for: protocolDeclaration)

        assertBuildResult(
            result,
            """
            class ViewModelProtocolSpy: ViewModelProtocol {
                var fooWithTextCountCallsCount = 0
                var fooWithTextCountCalled: Bool {
                    return fooWithTextCountCallsCount > 0
                }
                var fooWithTextCountReceivedArguments: (text: String, count: Int)?
                var fooWithTextCountReceivedInvocations: [(text: String, count: Int)] = []
                var fooWithTextCountClosure: ((String, Int) -> Void)?
                func foo(text: String, count: Int) {
                    fooWithTextCountCallsCount += 1
                    fooWithTextCountReceivedArguments = (text, count)
                    fooWithTextCountReceivedInvocations.append((text, count))
                    fooWithTextCountClosure?(text, count)
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


        let result = SpyFactory().classDeclaration(for: protocolDeclaration)

        assertBuildResult(
            result,
            """
            class BarSpy: Bar {
                var printCallsCount = 0
                var printCalled: Bool {
                    return printCallsCount > 0
                }
                var printReturnValue: (text: String, tuple: (count: Int?, Date))!
                var printClosure: (() -> (text: String, tuple: (count: Int?, Date)))?
                func print() -> (text: String, tuple: (count: Int?, Date)) {
                    printCallsCount += 1
                    if printClosure != nil {
                        return printClosure!()
                    } else {
                        return printReturnValue
                    }
                }
            }
            """
        )
    }

    func testDeclarationAsync() throws {
        let declaration = DeclSyntax(
            """
            protocol ServiceProtocol {
            func foo(text: String, count: Int) async -> Decimal
            }
            """
        )
        let protocolDeclaration = try XCTUnwrap(ProtocolDeclSyntax(declaration))

        let result = SpyFactory().classDeclaration(for: protocolDeclaration)

        assertBuildResult(
            result,
            """
            class ServiceProtocolSpy: ServiceProtocol {
                var fooWithTextCountCallsCount = 0
                var fooWithTextCountCalled: Bool {
                    return fooWithTextCountCallsCount > 0
                }
                var fooWithTextCountReceivedArguments: (text: String, count: Int)?
                var fooWithTextCountReceivedInvocations: [(text: String, count: Int)] = []
                var fooWithTextCountReturnValue: Decimal!
                var fooWithTextCountClosure: ((String, Int) async -> Decimal)?
                func foo(text: String, count: Int) async -> Decimal {
                    fooWithTextCountCallsCount += 1
                    fooWithTextCountReceivedArguments = (text, count)
                    fooWithTextCountReceivedInvocations.append((text, count))
                    if fooWithTextCountClosure != nil {
                        return await fooWithTextCountClosure!(text, count)
                    } else {
                        return fooWithTextCountReturnValue
                    }
                }
            }
            """
        )
    }

    func testDeclarationThrows() throws {
        let declaration = DeclSyntax(
            """
            protocol ServiceProtocol {
            func foo(_ added: ((text: String) -> Void)?) throws -> (() -> Int)?
            }
            """
        )
        let protocolDeclaration = try XCTUnwrap(ProtocolDeclSyntax(declaration))

        let result = SpyFactory().classDeclaration(for: protocolDeclaration)

        assertBuildResult(
            result,
            """
            class ServiceProtocolSpy: ServiceProtocol {
                var fooWithAddedCallsCount = 0
                var fooWithAddedCalled: Bool {
                    return fooWithAddedCallsCount > 0
                }
                var fooWithAddedReceivedAdded: ((text: String) -> Void)?
                var fooWithAddedReceivedInvocations: [((text: String) -> Void)?] = []
                var fooWithAddedReturnValue: (() -> Int)?
                var fooWithAddedClosure: ((((text: String) -> Void)?) throws -> (() -> Int)?)?
                func foo(_ added: ((text: String) -> Void)?) throws -> (() -> Int)? {
                    fooWithAddedCallsCount += 1
                    fooWithAddedReceivedAdded = (added)
                    fooWithAddedReceivedInvocations.append((added))
                    if fooWithAddedClosure != nil {
                        return try fooWithAddedClosure!(added)
                    } else {
                        return fooWithAddedReturnValue
                    }
                }
            }
            """
        )
    }

    func testDeclarationVariable() throws {
        let declaration = DeclSyntax(
            """
            protocol ServiceProtocol {
                var data: Data { get }
            }
            """
        )
        let protocolDeclaration = try XCTUnwrap(ProtocolDeclSyntax(declaration))

        let result = SpyFactory().classDeclaration(for: protocolDeclaration)

        assertBuildResult(
            result,
            """
            class ServiceProtocolSpy: ServiceProtocol {
                var data: Data {
                    get {
                        underlyingData
                    }
                    set {
                        underlyingData = newValue
                    }
                }
                var underlyingData: (Data )!
            }
            """
        )
    }


    func testDeclarationOptionalVariable() throws {
        let declaration = DeclSyntax(
            """
            protocol ServiceProtocol {
                var data: Data? { get set }
            }
            """
        )
        let protocolDeclaration = try XCTUnwrap(ProtocolDeclSyntax(declaration))

        let result = SpyFactory().classDeclaration(for: protocolDeclaration)

        assertBuildResult(
            result,
            """
            class ServiceProtocolSpy: ServiceProtocol {
                var data: Data?
            }
            """
        )
    }


    func testDeclarationClosureVariable() throws {
        let declaration = DeclSyntax(
            """
            protocol ServiceProtocol {
                var completion: () -> Void { get set }
            }
            """
        )
        let protocolDeclaration = try XCTUnwrap(ProtocolDeclSyntax(declaration))

        let result = SpyFactory().classDeclaration(for: protocolDeclaration)

        assertBuildResult(
            result,
            """
            class ServiceProtocolSpy: ServiceProtocol {
                var completion: () -> Void {
                    get {
                        underlyingCompletion
                    }
                    set {
                        underlyingCompletion = newValue
                    }
                }
                var underlyingCompletion: (() -> Void )!
            }
            """
        )
    }
}
