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
          func useGenerics<T, U>(values1: [T], values2: Array<U>, values3: (T, U, Int))
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
            public
            var secondName: String?
            public var added: () -> Void {
                get {
                    underlyingAdded
                }
                set {
                    underlyingAdded = newValue
                }
            }
            public var underlyingAdded: (() -> Void)!
            public
            var removed: (() -> Void)?
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
            public
            func initialize(name: String, secondName: String?) {
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
            public
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
            public var fetchDataCallsCount = 0
            public var fetchDataCalled: Bool {
                return fetchDataCallsCount > 0
            }
            public var fetchDataReceivedName: (String, count: Int)?
            public var fetchDataReceivedInvocations: [(String, count: Int)] = []
            public var fetchDataReturnValue: (() -> Void)!
            public var fetchDataClosure: (((String, count: Int)) async -> (() -> Void))?
            public
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
            public var fetchUsernameContextCompletionCallsCount = 0
            public var fetchUsernameContextCompletionCalled: Bool {
                return fetchUsernameContextCompletionCallsCount > 0
            }
            public var fetchUsernameContextCompletionReceivedArguments: (context: String, completion: (String) -> Void)?
            public var fetchUsernameContextCompletionReceivedInvocations: [(context: String, completion: (String) -> Void)] = []
            public var fetchUsernameContextCompletionClosure: ((String, @escaping (String) -> Void) -> Void)?
            public
            func fetchUsername(context: String, completion: @escaping (String) -> Void) {
                fetchUsernameContextCompletionCallsCount += 1
                fetchUsernameContextCompletionReceivedArguments = (context, completion)
                fetchUsernameContextCompletionReceivedInvocations.append((context, completion))
                fetchUsernameContextCompletionClosure?(context, completion)
            }
            public var onTapBackContextActionCallsCount = 0
            public var onTapBackContextActionCalled: Bool {
                return onTapBackContextActionCallsCount > 0
            }
            public var onTapBackContextActionClosure: ((String, () -> Void) -> Void)?
            public
            func onTapBack(context: String, action: () -> Void) {
                onTapBackContextActionCallsCount += 1
                onTapBackContextActionClosure?(context, action)
            }
            public var onTapNextContextActionCallsCount = 0
            public var onTapNextContextActionCalled: Bool {
                return onTapNextContextActionCallsCount > 0
            }
            public var onTapNextContextActionClosure: ((String, @Sendable () -> Void) -> Void)?
            public
            func onTapNext(context: String, action: @Sendable () -> Void) {
                onTapNextContextActionCallsCount += 1
                onTapNextContextActionClosure?(context, action)
            }
            public var assertCallsCount = 0
            public var assertCalled: Bool {
                return assertCallsCount > 0
            }
            public var assertClosure: ((@autoclosure () -> String) -> Void)?
            public
            func assert(_ message: @autoclosure () -> String) {
                assertCallsCount += 1
                assertClosure?(message())
            }
            public var useGenericsValues1Values2Values3CallsCount = 0
            public var useGenericsValues1Values2Values3Called: Bool {
                return useGenericsValues1Values2Values3CallsCount > 0
            }
            public var useGenericsValues1Values2Values3ReceivedArguments: (values1: [Any], values2: Array<Any>, values3: (Any, Any, Int))?
            public var useGenericsValues1Values2Values3ReceivedInvocations: [(values1: [Any], values2: Array<Any>, values3: (Any, Any, Int))] = []
            public var useGenericsValues1Values2Values3Closure: (([Any], Array<Any>, (Any, Any, Int)) -> Void)?
            public
            func useGenerics<T, U>(values1: [T], values2: Array<U>, values3: (T, U, Int)) {
                useGenericsValues1Values2Values3CallsCount += 1
                useGenericsValues1Values2Values3ReceivedArguments = (values1, values2, values3)
                useGenericsValues1Values2Values3ReceivedInvocations.append((values1, values2, values3))
                useGenericsValues1Values2Values3Closure?(values1, values2, values3)
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
            init() {
            }
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
            init() {
            }
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
            init() {
            }
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
            init() {
            }
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
            init() {
            }
        }
        """,
      diagnostics: [
        DiagnosticSpec(
          message: "The `behindPreprocessorFlag` argument requires a static string literal",
          line: 1,
          column: 1,
          notes: [
            NoteSpec(
              message:
                "Provide a literal string value without any dynamic expressions or interpolations to meet the static string literal requirement.",
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
            init() {
            }
        }
        """,
      diagnostics: [
        DiagnosticSpec(
          message: "The `behindPreprocessorFlag` argument requires a static string literal",
          line: 3,
          column: 1,
          notes: [
            NoteSpec(
              message:
                "Provide a literal string value without any dynamic expressions or interpolations to meet the static string literal requirement.",
              line: 3,
              column: 34
            )
          ]
        )
      ],
      macros: sut
    )
  }

  func testSpyClassAccessLevelsMatchProtocolAccessLevels() {
    let accessLevelMappings = [
      (protocolAccessLevel: "public", spyClassAccessLevel: "public"),
      (protocolAccessLevel: "package", spyClassAccessLevel: "package"),
      (protocolAccessLevel: "internal", spyClassAccessLevel: "internal"),
      (protocolAccessLevel: "fileprivate", spyClassAccessLevel: "fileprivate"),
      (protocolAccessLevel: "private", spyClassAccessLevel: "fileprivate"),
    ]

    for mapping in accessLevelMappings {
      let protocolDefinition = """
        \(mapping.protocolAccessLevel) protocol ServiceProtocol {
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

          \(mapping.spyClassAccessLevel) class ServiceProtocolSpy: ServiceProtocol {
              \(mapping.spyClassAccessLevel) init() {
              }
              \(mapping.spyClassAccessLevel)
              var removed: (() -> Void)?
              \(mapping.spyClassAccessLevel) var fetchUsernameContextCompletionCallsCount = 0
              \(mapping.spyClassAccessLevel) var fetchUsernameContextCompletionCalled: Bool {
                  return fetchUsernameContextCompletionCallsCount > 0
              }
              \(mapping.spyClassAccessLevel) var fetchUsernameContextCompletionReceivedArguments: (context: String, completion: (String) -> Void)?
              \(mapping.spyClassAccessLevel) var fetchUsernameContextCompletionReceivedInvocations: [(context: String, completion: (String) -> Void)] = []
              \(mapping.spyClassAccessLevel) var fetchUsernameContextCompletionClosure: ((String, @escaping (String) -> Void) -> Void)?
              \(mapping.spyClassAccessLevel)

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
}
