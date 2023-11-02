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

        let result = try SpyFactory().classDeclaration(for: protocolDeclaration)

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

        let result = try SpyFactory().classDeclaration(for: protocolDeclaration)

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

        let result = try SpyFactory().classDeclaration(for: protocolDeclaration)

        assertBuildResult(
            result,
            """
            class ViewModelProtocolSpy: ViewModelProtocol {
                var fooTextCountCallsCount = 0
                var fooTextCountCalled: Bool {
                    return fooTextCountCallsCount > 0
                }
                var fooTextCountReceivedArguments: (text: String, count: Int)?
                var fooTextCountReceivedInvocations: [(text: String, count: Int)] = []
                var fooTextCountClosure: ((String, Int) -> Void)?
                func foo(text: String, count: Int) {
                    fooTextCountCallsCount += 1
                    fooTextCountReceivedArguments = (text, count)
                    fooTextCountReceivedInvocations.append((text, count))
                    fooTextCountClosure?(text, count)
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


        let result = try SpyFactory().classDeclaration(for: protocolDeclaration)

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

        let result = try SpyFactory().classDeclaration(for: protocolDeclaration)

        assertBuildResult(
            result,
            """
            class ServiceProtocolSpy: ServiceProtocol {
                var fooTextCountCallsCount = 0
                var fooTextCountCalled: Bool {
                    return fooTextCountCallsCount > 0
                }
                var fooTextCountReceivedArguments: (text: String, count: Int)?
                var fooTextCountReceivedInvocations: [(text: String, count: Int)] = []
                var fooTextCountReturnValue: Decimal!
                var fooTextCountClosure: ((String, Int) async -> Decimal)?
                func foo(text: String, count: Int) async -> Decimal {
                    fooTextCountCallsCount += 1
                    fooTextCountReceivedArguments = (text, count)
                    fooTextCountReceivedInvocations.append((text, count))
                    if fooTextCountClosure != nil {
                        return await fooTextCountClosure!(text, count)
                    } else {
                        return fooTextCountReturnValue
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

        let result = try SpyFactory().classDeclaration(for: protocolDeclaration)

        assertBuildResult(
            result,
            """
            class ServiceProtocolSpy: ServiceProtocol {
                var fooCallsCount = 0
                var fooCalled: Bool {
                    return fooCallsCount > 0
                }
                var fooReceivedAdded: ((text: String) -> Void)?
                var fooReceivedInvocations: [((text: String) -> Void)?] = []
                var fooThrowableError: Error?
                var fooReturnValue: (() -> Int)?
                var fooClosure: ((((text: String) -> Void)?) throws -> (() -> Int)?)?
                func foo(_ added: ((text: String) -> Void)?) throws -> (() -> Int)? {
                    fooCallsCount += 1
                    fooReceivedAdded = (added)
                    fooReceivedInvocations.append((added))
                    if let fooThrowableError {
                        throw fooThrowableError
                    }
                    if fooClosure != nil {
                        return try fooClosure!(added)
                    } else {
                        return fooReturnValue
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

        let result = try SpyFactory().classDeclaration(for: protocolDeclaration)

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

        let result = try SpyFactory().classDeclaration(for: protocolDeclaration)

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

        let result = try SpyFactory().classDeclaration(for: protocolDeclaration)

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
