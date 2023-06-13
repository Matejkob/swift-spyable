import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
@testable import SpyableMacro

final class UT_SpyableMacro: XCTestCase {
    private let sut = ["Spyable": SpyableMacro.self]
    
    func testMacro() {
        let protocolDeclaration = """
        public protocol ServiceProtocol {
            var name: String {
                get
            }
            var anyProtocol: any Codable {
                get
                set
            }
            var secondName: String? {
                get
            }
            var added: () -> Void {
                get
                set
            }
            var removed: (() -> Void)? {
                get
                set
            }

            func initialize(name: String, _ secondName: String?)
            func fetchConfig() async throws -> [String: String]
            func fetchData(_ name: (String, count: Int)) async -> (() -> Void)
        }
        """

        assertMacroExpansion(
            """
            @Spyable
            \(protocolDeclaration)
            """,
            expandedSource: """

            \(protocolDeclaration)
            class ServiceProtocolSpy: ServiceProtocol {
                var name: String {
                    get {
                        underlyingName
                    }
                    set {
                        underlyingName = newValue
                    }
                }
                var underlyingName: (String )!
                var anyProtocol: any Codable {
                    get {
                        underlyingAnyProtocol
                    }
                    set {
                        underlyingAnyProtocol = newValue
                    }
                }
                var underlyingAnyProtocol: (any Codable )!
                    var secondName: String?
                var added: () -> Void {
                    get {
                        underlyingAdded
                    }
                    set {
                        underlyingAdded = newValue
                    }
                }
                var underlyingAdded: (() -> Void )!
                    var removed: (() -> Void)?
                var initializeWithNameSecondNameCallsCount = 0
                var initializeWithNameSecondNameCalled: Bool {
                    return initializeWithNameSecondNameCallsCount > 0
                }
                var initializeWithNameSecondNameReceivedArguments: (name: String, secondName: String?)?
                var initializeWithNameSecondNameReceivedInvocations: [(name: String, secondName: String?)] = []
                var initializeWithNameSecondNameClosure: ((String, String?) -> Void)?

                    func initialize(name: String, _ secondName: String?) {
                    initializeWithNameSecondNameCallsCount += 1
                    initializeWithNameSecondNameReceivedArguments = (name, secondName)
                    initializeWithNameSecondNameReceivedInvocations.append((name, secondName))
                    initializeWithNameSecondNameClosure?(name, secondName)
                }
                var fetchConfigCallsCount = 0
                var fetchConfigCalled: Bool {
                    return fetchConfigCallsCount > 0
                }
                var fetchConfigReturnValue: [String: String]!
                var fetchConfigClosure: (() async throws -> [String: String])?
                    func fetchConfig() async throws -> [String: String] {
                    fetchConfigCallsCount += 1
                    if fetchConfigClosure != nil {
                        return try await fetchConfigClosure!()
                    } else {
                        return fetchConfigReturnValue
                    }
                }
                var fetchDataWithNameCallsCount = 0
                var fetchDataWithNameCalled: Bool {
                    return fetchDataWithNameCallsCount > 0
                }
                var fetchDataWithNameReceivedName: (String, count: Int)?
                var fetchDataWithNameReceivedInvocations: [(String, count: Int)] = []
                var fetchDataWithNameReturnValue: (() -> Void)!
                var fetchDataWithNameClosure: (((String, count: Int)) async -> (() -> Void))?
                    func fetchData(_ name: (String, count: Int)) async -> (() -> Void) {
                    fetchDataWithNameCallsCount += 1
                    fetchDataWithNameReceivedName = (name)
                    fetchDataWithNameReceivedInvocations.append((name))
                    if fetchDataWithNameClosure != nil {
                        return await fetchDataWithNameClosure!(name)
                    } else {
                        return fetchDataWithNameReturnValue
                    }
                }
            }
            """,
            macros: sut
        )
    }
}
