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

            func initialize(name: String, secondName: String?)
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
                var initializeNameSecondNameCallsCount = 0
                var initializeNameSecondNameCalled: Bool {
                    return initializeNameSecondNameCallsCount > 0
                }
                var initializeNameSecondNameReceivedArguments: (name: String, secondName: String?)?
                var initializeNameSecondNameReceivedInvocations: [(name: String, secondName: String?)] = []
                var initializeNameSecondNameClosure: ((String, String?) -> Void)?

                    func initialize(name: String, secondName: String?) {
                    initializeNameSecondNameCallsCount += 1
                    initializeNameSecondNameReceivedArguments = (name, secondName)
                    initializeNameSecondNameReceivedInvocations.append((name, secondName))
                    initializeNameSecondNameClosure?(name, secondName)
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
                var fetchDataCallsCount = 0
                var fetchDataCalled: Bool {
                    return fetchDataCallsCount > 0
                }
                var fetchDataReceivedName: (String, count: Int)?
                var fetchDataReceivedInvocations: [(String, count: Int)] = []
                var fetchDataReturnValue: (() -> Void)!
                var fetchDataClosure: (((String, count: Int)) async -> (() -> Void))?
                    func fetchData(_ name: (String, count: Int)) async -> (() -> Void) {
                    fetchDataCallsCount += 1
                    fetchDataReceivedName = (name)
                    fetchDataReceivedInvocations.append((name))
                    if fetchDataClosure != nil {
                        return await fetchDataClosure!(name)
                    } else {
                        return fetchDataReturnValue
                    }
                }
            }
            """,
            macros: sut
        )
    }
}
