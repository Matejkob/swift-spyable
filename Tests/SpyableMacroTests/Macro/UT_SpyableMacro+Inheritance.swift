import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

@testable import SpyableMacro

final class UT_SpyableMacroInheritance: XCTestCase {
  private let sut = ["Spyable": SpyableMacro.self]

  func testMacroWithOpenAccessLevel() {
    let protocolDeclaration = """
      protocol ServiceProtocol {
          var removed: (() -> Void)? { get set }

          func fetchUsername(context: String, completion: @escaping (String) -> Void)
      }
      """

    assertMacroExpansion(
      """
      @Spyable(accessLevel: .open)
      \(protocolDeclaration)
      """,
      expandedSource: """

        \(protocolDeclaration)

        open class ServiceProtocolSpy: ServiceProtocol, @unchecked Sendable {
            public init() {
            }
            open
            var removed: (() -> Void)?
            open var fetchUsernameContextCompletionCallsCount = 0
            open var fetchUsernameContextCompletionCalled: Bool {
                return fetchUsernameContextCompletionCallsCount > 0
            }
            open var fetchUsernameContextCompletionReceivedArguments: (context: String, completion: (String) -> Void)?
            open var fetchUsernameContextCompletionReceivedInvocations: [(context: String, completion: (String) -> Void)] = []
            open var fetchUsernameContextCompletionClosure: ((String, @escaping (String) -> Void) -> Void)?
            open

            func fetchUsername(context: String, completion: @escaping (String) -> Void) {
                fetchUsernameContextCompletionCallsCount += 1
                fetchUsernameContextCompletionReceivedArguments = (context, completion)
                fetchUsernameContextCompletionReceivedInvocations.append((context, completion))
                fetchUsernameContextCompletionClosure?(context, completion)
            }
        }
        """,
      macros: sut
    )
  }

  func testMacroWithOpenAccessLevelAndInheritedType() {
    let protocolDeclaration = """
      protocol ServiceProtocol {
          var removed: (() -> Void)? { get set }

          func fetchUsername(context: String, completion: @escaping (String) -> Void)
      }
      """

    assertMacroExpansion(
      """
      @Spyable(accessLevel: .open, inheritedType: "BaseServiceSpy")
      \(protocolDeclaration)
      """,
      expandedSource: """

        \(protocolDeclaration)

        open class ServiceProtocolSpy: BaseServiceSpy, ServiceProtocol, @unchecked Sendable {
            override public init() {
            }
            open
            var removed: (() -> Void)?
            open var fetchUsernameContextCompletionCallsCount = 0
            open var fetchUsernameContextCompletionCalled: Bool {
                return fetchUsernameContextCompletionCallsCount > 0
            }
            open var fetchUsernameContextCompletionReceivedArguments: (context: String, completion: (String) -> Void)?
            open var fetchUsernameContextCompletionReceivedInvocations: [(context: String, completion: (String) -> Void)] = []
            open var fetchUsernameContextCompletionClosure: ((String, @escaping (String) -> Void) -> Void)?
            open

            func fetchUsername(context: String, completion: @escaping (String) -> Void) {
                fetchUsernameContextCompletionCallsCount += 1
                fetchUsernameContextCompletionReceivedArguments = (context, completion)
                fetchUsernameContextCompletionReceivedInvocations.append((context, completion))
                fetchUsernameContextCompletionClosure?(context, completion)
            }
        }
        """,
      macros: sut
    )
  }

  func testMacroWithOpenAccessLevelAndBehindPreprocessorFlag() {
    let protocolDeclaration = """
      protocol ServiceProtocol {
          func doSomething()
      }
      """

    assertMacroExpansion(
      """
      @Spyable(accessLevel: .open, behindPreprocessorFlag: "DEBUG")
      \(protocolDeclaration)
      """,
      expandedSource: """

        \(protocolDeclaration)

        #if DEBUG
        open class ServiceProtocolSpy: ServiceProtocol, @unchecked Sendable {
            public init() {
            }
            open var doSomethingCallsCount = 0
            open var doSomethingCalled: Bool {
                return doSomethingCallsCount > 0
            }
            open var doSomethingClosure: (() -> Void)?
            open
            func doSomething() {
                doSomethingCallsCount += 1
                doSomethingClosure?()
            }
        }
        #endif
        """,
      macros: sut
    )
  }

  func testMacroWithOpenAccessLevelComplexProtocol() {
    let protocolDeclaration = """
      protocol ComplexProtocol {
          var name: String { get set }
          func initialize(name: String, secondName: String?)
          func fetchConfig() async throws -> [String: String]
      }
      """

    assertMacroExpansion(
      """
      @Spyable(accessLevel: .open)
      \(protocolDeclaration)
      """,
      expandedSource: """

        \(protocolDeclaration)

        open class ComplexProtocolSpy: ComplexProtocol, @unchecked Sendable {
            public init() {
            }
            open var name: String {
                get {
                    underlyingName
                }
                set {
                    underlyingName = newValue
                }
            }
            open var underlyingName: (String)!
            open var initializeNameSecondNameCallsCount = 0
            open var initializeNameSecondNameCalled: Bool {
                return initializeNameSecondNameCallsCount > 0
            }
            open var initializeNameSecondNameReceivedArguments: (name: String, secondName: String?)?
            open var initializeNameSecondNameReceivedInvocations: [(name: String, secondName: String?)] = []
            open var initializeNameSecondNameClosure: ((String, String?) -> Void)?
            open
            func initialize(name: String, secondName: String?) {
                initializeNameSecondNameCallsCount += 1
                initializeNameSecondNameReceivedArguments = (name, secondName)
                initializeNameSecondNameReceivedInvocations.append((name, secondName))
                initializeNameSecondNameClosure?(name, secondName)
            }
            open var fetchConfigCallsCount = 0
            open var fetchConfigCalled: Bool {
                return fetchConfigCallsCount > 0
            }
            open var fetchConfigThrowableError: (any Error)?
            open var fetchConfigReturnValue: [String: String]!
            open var fetchConfigClosure: (() async throws -> [String: String])?
            open
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
        }
        """,
      macros: sut
    )
  }

  func testOpenAccessLevelFromProtocolDeclaration() {
    // Test that open access level is NOT automatically detected from protocol declaration
    let protocolDefinition = """
      open protocol ServiceProtocol {
          var removed: (() -> Void)? { get set }

          func fetchUsername(context: String, completion: @escaping (String) -> Void)
      }
      """

    assertMacroExpansion(
      """
      @Spyable
      \(protocolDefinition)
      """,
      expandedSource: """

        \(protocolDefinition)

        class ServiceProtocolSpy: ServiceProtocol, @unchecked Sendable {
            init() {
            }
            var removed: (() -> Void)?
            var fetchUsernameContextCompletionCallsCount = 0
            var fetchUsernameContextCompletionCalled: Bool {
                return fetchUsernameContextCompletionCallsCount > 0
            }
            var fetchUsernameContextCompletionReceivedArguments: (context: String, completion: (String) -> Void)?
            var fetchUsernameContextCompletionReceivedInvocations: [(context: String, completion: (String) -> Void)] = []
            var fetchUsernameContextCompletionClosure: ((String, @escaping (String) -> Void) -> Void)?

            func fetchUsername(context: String, completion: @escaping (String) -> Void) {
                fetchUsernameContextCompletionCallsCount += 1
                fetchUsernameContextCompletionReceivedArguments = (context, completion)
                fetchUsernameContextCompletionReceivedInvocations.append((context, completion))
                fetchUsernameContextCompletionClosure?(context, completion)
            }
        }
        """,
      macros: sut
    )
  }

  func testMacroWithOpenAccessLevelOverridingProtocolLevel() {
    // Test that accessLevel: .open argument overrides the protocol's access level
    let protocolDefinition = """
      internal protocol ServiceProtocol {
          var removed: (() -> Void)? { get set }

          func fetchUsername(context: String, completion: @escaping (String) -> Void)
      }
      """

    assertMacroExpansion(
      """
      @Spyable(accessLevel: .open)
      \(protocolDefinition)
      """,
      expandedSource: """

        \(protocolDefinition)

        open class ServiceProtocolSpy: ServiceProtocol, @unchecked Sendable {
            public init() {
            }
            open
            var removed: (() -> Void)?
            open var fetchUsernameContextCompletionCallsCount = 0
            open var fetchUsernameContextCompletionCalled: Bool {
                return fetchUsernameContextCompletionCallsCount > 0
            }
            open var fetchUsernameContextCompletionReceivedArguments: (context: String, completion: (String) -> Void)?
            open var fetchUsernameContextCompletionReceivedInvocations: [(context: String, completion: (String) -> Void)] = []
            open var fetchUsernameContextCompletionClosure: ((String, @escaping (String) -> Void) -> Void)?
            open

            func fetchUsername(context: String, completion: @escaping (String) -> Void) {
                fetchUsernameContextCompletionCallsCount += 1
                fetchUsernameContextCompletionReceivedArguments = (context, completion)
                fetchUsernameContextCompletionReceivedInvocations.append((context, completion))
                fetchUsernameContextCompletionClosure?(context, completion)
            }
        }
        """,
      macros: sut
    )
  }
}
