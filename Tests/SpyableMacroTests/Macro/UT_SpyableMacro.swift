import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

@testable import SpyableMacro

final class UT_SpyableMacro: XCTestCase {
    private let sut = ["Spyable": SpyableMacro.self]
    
    func testPublicMacro() {
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
      
          mutating func logout()
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
        
        public class ServiceProtocolSpy: ServiceProtocol {
            public init() {
            }
            public var name: String {
                get {
                    underlyingName
                }
                set {
                    underlyingName = newValue
                }
            }
            public var underlyingName: (String)!
            public var anyProtocol: any Codable {
                get {
                    underlyingAnyProtocol
                }
                set {
                    underlyingAnyProtocol = newValue
                }
            }
            public var underlyingAnyProtocol: (any Codable)!
            public var secondName: String?
            public var added: () -> Void {
                get {
                    underlyingAdded
                }
                set {
                    underlyingAdded = newValue
                }
            }
            public var underlyingAdded: (() -> Void)!
            public var removed: (() -> Void)?
            public var logoutCallsCount = 0
            public var logoutCalled: Bool {
                return logoutCallsCount > 0
            }
            public var logoutClosure: (() -> Void)?
            public func logout() {
                logoutCallsCount += 1
                logoutClosure?()
            }
            public var initializeNameSecondNameCallsCount = 0
            public var initializeNameSecondNameCalled: Bool {
                return initializeNameSecondNameCallsCount > 0
            }
            public var initializeNameSecondNameReceivedArguments: (name: String, secondName: String?)?
            public var initializeNameSecondNameReceivedInvocations: [(name: String, secondName: String?)] = []
            public var initializeNameSecondNameClosure: ((String, String?) -> Void)?
            public func initialize(name: String, secondName: String?) {
                initializeNameSecondNameCallsCount += 1
                initializeNameSecondNameReceivedArguments = (name, secondName)
                initializeNameSecondNameReceivedInvocations.append((name, secondName))
                initializeNameSecondNameClosure?(name, secondName)
            }
            public var fetchConfigCallsCount = 0
            public var fetchConfigCalled: Bool {
                return fetchConfigCallsCount > 0
            }
            public var fetchConfigThrowableError: (any Error)?
            public var fetchConfigReturnValue: [String: String]!
            public var fetchConfigClosure: (() async throws -> [String: String])?
            public func fetchConfig() async throws -> [String: String] {
                fetchConfigCallsCount += 1
                if let fetchConfigThrowableError {
                    throw fetchConfigThrowableError
                }
                if fetchConfigClosure != nil {
                    return try await fetchConfigClosure!()
                } else {
                    return fetchConfigReturnValue
                }
            }
            public var fetchDataCallsCount = 0
            public var fetchDataCalled: Bool {
                return fetchDataCallsCount > 0
            }
            public var fetchDataReceivedName: (String, count: Int)?
            public var fetchDataReceivedInvocations: [(String, count: Int)] = []
            public var fetchDataReturnValue: (() -> Void)!
            public var fetchDataClosure: (((String, count: Int)) async -> (() -> Void))?
            public func fetchData(_ name: (String, count: Int)) async -> (() -> Void) {
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
    
    func testInternalMacro() {
        let protocolDeclaration = """
        protocol ServiceProtocol {
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
        
            mutating func logout()
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
              var underlyingName: (String)!
              var anyProtocol: any Codable {
                  get {
                      underlyingAnyProtocol
                  }
                  set {
                      underlyingAnyProtocol = newValue
                  }
              }
              var underlyingAnyProtocol: (any Codable)!
              var secondName: String?
              var added: () -> Void {
                  get {
                      underlyingAdded
                  }
                  set {
                      underlyingAdded = newValue
                  }
              }
              var underlyingAdded: (() -> Void)!
              var removed: (() -> Void)?
              var logoutCallsCount = 0
              var logoutCalled: Bool {
                  return logoutCallsCount > 0
              }
              var logoutClosure: (() -> Void)?
              func logout() {
                  logoutCallsCount += 1
                  logoutClosure?()
              }
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
              var fetchConfigThrowableError: (any Error)?
              var fetchConfigReturnValue: [String: String]!
              var fetchConfigClosure: (() async throws -> [String: String])?
              func fetchConfig() async throws -> [String: String] {
                  fetchConfigCallsCount += 1
                  if let fetchConfigThrowableError {
                      throw fetchConfigThrowableError
                  }
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
    
    func testPublicMacroWithFlag() {
        let protocolDeclaration = """
      public protocol ServiceProtocol {
          var variable: Bool? { get set }
      }
      """
        assertMacroExpansion(
      """
      @Spyable(behindPreprocessorFlag: "CUSTOM")
      \(protocolDeclaration)
      """,
      expandedSource: """
        
        \(protocolDeclaration)
        
        #if CUSTOM
        public class ServiceProtocolSpy: ServiceProtocol {
            public init() {
            }
            public var variable: Bool?
        }
        #endif
        """,
      macros: sut
        )
    }
}
