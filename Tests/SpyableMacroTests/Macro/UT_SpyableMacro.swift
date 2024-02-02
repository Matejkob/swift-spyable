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

          mutating func logout()
          func initialize(name: String, secondName: String?)
          func fetchConfig() async throws -> [String: String]
          func fetchData(_ name: (String, count: Int)) async -> (() -> Void)
          func fetchUsername(context: String, completion: @escaping (String) -> Void)
          func onTapBack(context: String, action: () -> Void)
          func onTapNext(context: String, action: @Sendable () -> Void)
          func assert(_ message: @autoclosure () -> String)
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
            var onTapBackContextActionCallsCount = 0
            var onTapBackContextActionCalled: Bool {
                return onTapBackContextActionCallsCount > 0
            }
            var onTapBackContextActionClosure: ((String, () -> Void) -> Void)?
            func onTapBack(context: String, action: () -> Void) {
                onTapBackContextActionCallsCount += 1
                onTapBackContextActionClosure?(context, action)
            }
            var onTapNextContextActionCallsCount = 0
            var onTapNextContextActionCalled: Bool {
                return onTapNextContextActionCallsCount > 0
            }
            var onTapNextContextActionClosure: ((String, @Sendable () -> Void) -> Void)?
            func onTapNext(context: String, action: @Sendable () -> Void) {
                onTapNextContextActionCallsCount += 1
                onTapNextContextActionClosure?(context, action)
            }
            var assertCallsCount = 0
            var assertCalled: Bool {
                return assertCallsCount > 0
            }
            var assertClosure: ((@autoclosure () -> String) -> Void)?
            func assert(_ message: @autoclosure () -> String) {
                assertCallsCount += 1
                assertClosure?(message())
            }
        }
        """,
      macros: sut
    )
  }

  // MARK: - `behindPreprocessorFlag` argument

  func testMacroWithNoArgument() {
    let protocolDeclaration = "protocol MyProtocol {}"

    assertMacroExpansion(
      """
      @Spyable()
      \(protocolDeclaration)
      """,
      expandedSource: """

        \(protocolDeclaration)

        class MyProtocolSpy: MyProtocol {
        }
        """,
      macros: sut
    )
  }

  func testMacroWithNoBehindPreprocessorFlagArgument() {
    let protocolDeclaration = "protocol MyProtocol {}"

    assertMacroExpansion(
      """
      @Spyable(someOtherArgument: 1)
      \(protocolDeclaration)
      """,
      expandedSource: """

        \(protocolDeclaration)

        class MyProtocolSpy: MyProtocol {
        }
        """,
      macros: sut
    )
  }

  func testMacroWithBehindPreprocessorFlagArgument() {
    let protocolDeclaration = "protocol MyProtocol {}"

    assertMacroExpansion(
      """
      @Spyable(behindPreprocessorFlag: "CUSTOM")
      \(protocolDeclaration)
      """,
      expandedSource: """

        \(protocolDeclaration)

        #if CUSTOM
        class MyProtocolSpy: MyProtocol {
        }
        #endif
        """,
      macros: sut
    )
  }

  func testMacroWithBehindPreprocessorFlagArgumentAndOtherAttributes() {
    let protocolDeclaration = "protocol MyProtocol {}"

    assertMacroExpansion(
      """
      @MainActor
      @Spyable(behindPreprocessorFlag: "CUSTOM")
      @available(*, deprecated)
      \(protocolDeclaration)
      """,
      expandedSource: """

        @MainActor
        @available(*, deprecated)
        \(protocolDeclaration)

        #if CUSTOM
        class MyProtocolSpy: MyProtocol {
        }
        #endif
        """,
      macros: sut
    )
  }

  func testMacroWithBehindPreprocessorFlagArgumentWithInterpolation() {
    let protocolDeclaration = "protocol MyProtocol {}"

    assertMacroExpansion(
      #"""
      @Spyable(behindPreprocessorFlag: "CUSTOM\(123)FLAG")
      \#(protocolDeclaration)
      """#,
      expandedSource: """

        \(protocolDeclaration)

        class MyProtocolSpy: MyProtocol {
        }
        """,
      diagnostics: [
        DiagnosticSpec(
          message: "The `behindPreprocessorFlag` argument requires a static string literal",
          line: 1,
          column: 1,
          notes: [
            NoteSpec(
            message: "Provide a literal string value without any dynamic expressions or interpolations to meet the static string literal requirement.",
            line: 1,
            column: 34
          )
          ]
        )
      ],
      macros: sut
    )
  }

  func testMacroWithBehindPreprocessorFlagArgumentFromVariable() {
    let protocolDeclaration = "protocol MyProtocol {}"

    assertMacroExpansion(
      """
      let myCustomFlag = "DEBUG"

      @Spyable(behindPreprocessorFlag: myCustomFlag)
      \(protocolDeclaration)
      """,
      expandedSource: """
        let myCustomFlag = "DEBUG"
        \(protocolDeclaration)

        class MyProtocolSpy: MyProtocol {
        }
        """,
      diagnostics: [
        DiagnosticSpec(
          message: "The `behindPreprocessorFlag` argument requires a static string literal",
          line: 3,
          column: 1,
          notes: [
            NoteSpec(
            message: "Provide a literal string value without any dynamic expressions or interpolations to meet the static string literal requirement.",
            line: 3,
            column: 34
          )
          ]
        )
      ],
      macros: sut
    )
  }
}
