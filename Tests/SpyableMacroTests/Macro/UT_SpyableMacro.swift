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

        public class ServiceProtocolSpy: ServiceProtocol, @unchecked Sendable {
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

        class MyProtocolSpy: MyProtocol, @unchecked Sendable {
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

        class MyProtocolSpy: MyProtocol, @unchecked Sendable {
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
        class MyProtocolSpy: MyProtocol, @unchecked Sendable {
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
        class MyProtocolSpy: MyProtocol, @unchecked Sendable {
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

        class MyProtocolSpy: MyProtocol, @unchecked Sendable {
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

        class MyProtocolSpy: MyProtocol, @unchecked Sendable {
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

          \(mapping.spyClassAccessLevel) class ServiceProtocolSpy: ServiceProtocol, @unchecked Sendable {
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

  func testMacroWithAccessLevelArgument() {
    let accessLevelMappings = [
      (protocolAccessLevel: "public", spyClassAccessLevel: "public"),
      (protocolAccessLevel: "package", spyClassAccessLevel: "package"),
      (protocolAccessLevel: "internal", spyClassAccessLevel: "internal"),
      (protocolAccessLevel: "fileprivate", spyClassAccessLevel: "fileprivate"),
      (protocolAccessLevel: "private", spyClassAccessLevel: "fileprivate"),
    ]

    for mapping in accessLevelMappings {
      let protocolDefinition = """
        protocol ServiceProtocol {
            var removed: (() -> Void)? { get set }

            func fetchUsername(context: String, completion: @escaping (String) -> Void)
        }
        """

      assertMacroExpansion(
        """
        @Spyable(accessLevel: .\(mapping.protocolAccessLevel))
        \(protocolDefinition)
        """,
        expandedSource: """

          \(protocolDefinition)

          \(mapping.spyClassAccessLevel) class ServiceProtocolSpy: ServiceProtocol, @unchecked Sendable {
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

  func testMacroWithAccessLevelArgumentOverridingInheritedAccessLevel() {
    let protocolDeclaration = """
      public protocol ServiceProtocol {
          var removed: (() -> Void)? { get set }

          func fetchUsername(context: String, completion: @escaping (String) -> Void)
      }
      """

    assertMacroExpansion(
      """
      @Spyable(accessLevel: .fileprivate)
      \(protocolDeclaration)
      """,
      expandedSource: """

        \(protocolDeclaration)

        fileprivate class ServiceProtocolSpy: ServiceProtocol, @unchecked Sendable {
            fileprivate init() {
            }
            fileprivate
            var removed: (() -> Void)?
            fileprivate var fetchUsernameContextCompletionCallsCount = 0
            fileprivate var fetchUsernameContextCompletionCalled: Bool {
                return fetchUsernameContextCompletionCallsCount > 0
            }
            fileprivate var fetchUsernameContextCompletionReceivedArguments: (context: String, completion: (String) -> Void)?
            fileprivate var fetchUsernameContextCompletionReceivedInvocations: [(context: String, completion: (String) -> Void)] = []
            fileprivate var fetchUsernameContextCompletionClosure: ((String, @escaping (String) -> Void) -> Void)?
            fileprivate

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

  func testMacroWithAllArgumentsAndOtherAttributes() {
    let protocolDeclaration = "public protocol MyProtocol {}"

    assertMacroExpansion(
      """
      @MainActor
      @Spyable(behindPreprocessorFlag: "CUSTOM_FLAG", accessLevel: .package)
      @available(*, deprecated)
      \(protocolDeclaration)
      """,
      expandedSource: """

        @MainActor
        @available(*, deprecated)
        \(protocolDeclaration)

        #if CUSTOM_FLAG
        package class MyProtocolSpy: MyProtocol, @unchecked Sendable {
            package init() {
            }
        }
        #endif
        """,
      macros: sut
    )
  }
  
  func testPolymorphismOverloadedMethodsWithDifferentReturnTypesOnly() {
    let protocolDeclaration = """
      protocol OverloadedReturnTypesProtocol {
        func doSomething()
        func doSomething() -> Int
        func doSomething() -> String?
        func doSomething() -> [String]
        func doSomething() -> [String: Int]
        func doSomething() -> (Int, Int)
        func doSomething() -> (Int, Bool)
      }
      """

    assertMacroExpansion(
      """
      @Spyable
      \(protocolDeclaration)
      """,
      expandedSource: """

        \(protocolDeclaration)

        class OverloadedReturnTypesProtocolSpy: OverloadedReturnTypesProtocol, @unchecked Sendable {
            init() {
            }
            var doSomethingCallsCount = 0
            var doSomethingCalled: Bool {
                return doSomethingCallsCount > 0
            }
            var doSomethingClosure: (() -> Void)?
            func doSomething() {
                doSomethingCallsCount += 1
                doSomethingClosure?()
            }
            var doSomethingIntCallsCount = 0
            var doSomethingIntCalled: Bool {
                return doSomethingIntCallsCount > 0
            }
            var doSomethingIntReturnValue: Int!
            var doSomethingIntClosure: (() -> Int)?
            func doSomething() -> Int {
                doSomethingIntCallsCount += 1
                if doSomethingIntClosure != nil {
                    return doSomethingIntClosure!()
                } else {
                    return doSomethingIntReturnValue
                }
            }
            var doSomethingOptionalStringCallsCount = 0
            var doSomethingOptionalStringCalled: Bool {
                return doSomethingOptionalStringCallsCount > 0
            }
            var doSomethingOptionalStringReturnValue: String?
            var doSomethingOptionalStringClosure: (() -> String?)?
            func doSomething() -> String? {
                doSomethingOptionalStringCallsCount += 1
                if doSomethingOptionalStringClosure != nil {
                    return doSomethingOptionalStringClosure!()
                } else {
                    return doSomethingOptionalStringReturnValue
                }
            }
            var doSomethingArrayStringCallsCount = 0
            var doSomethingArrayStringCalled: Bool {
                return doSomethingArrayStringCallsCount > 0
            }
            var doSomethingArrayStringReturnValue: [String]!
            var doSomethingArrayStringClosure: (() -> [String])?
            func doSomething() -> [String] {
                doSomethingArrayStringCallsCount += 1
                if doSomethingArrayStringClosure != nil {
                    return doSomethingArrayStringClosure!()
                } else {
                    return doSomethingArrayStringReturnValue
                }
            }
            var doSomethingDictionaryStringIntCallsCount = 0
            var doSomethingDictionaryStringIntCalled: Bool {
                return doSomethingDictionaryStringIntCallsCount > 0
            }
            var doSomethingDictionaryStringIntReturnValue: [String: Int]!
            var doSomethingDictionaryStringIntClosure: (() -> [String: Int])?
            func doSomething() -> [String: Int] {
                doSomethingDictionaryStringIntCallsCount += 1
                if doSomethingDictionaryStringIntClosure != nil {
                    return doSomethingDictionaryStringIntClosure!()
                } else {
                    return doSomethingDictionaryStringIntReturnValue
                }
            }
            var doSomethingIntIntCallsCount = 0
            var doSomethingIntIntCalled: Bool {
                return doSomethingIntIntCallsCount > 0
            }
            var doSomethingIntIntReturnValue: (Int, Int)!
            var doSomethingIntIntClosure: (() -> (Int, Int))?
            func doSomething() -> (Int, Int) {
                doSomethingIntIntCallsCount += 1
                if doSomethingIntIntClosure != nil {
                    return doSomethingIntIntClosure!()
                } else {
                    return doSomethingIntIntReturnValue
                }
            }
            var doSomethingIntBoolCallsCount = 0
            var doSomethingIntBoolCalled: Bool {
                return doSomethingIntBoolCallsCount > 0
            }
            var doSomethingIntBoolReturnValue: (Int, Bool)!
            var doSomethingIntBoolClosure: (() -> (Int, Bool))?
            func doSomething() -> (Int, Bool) {
                doSomethingIntBoolCallsCount += 1
                if doSomethingIntBoolClosure != nil {
                    return doSomethingIntBoolClosure!()
                } else {
                    return doSomethingIntBoolReturnValue
                }
            }
        }
        """,
      macros: sut
    )
  }

  func testPolymorphismOverloadedMethodsWithDifferentParameterTypes() {
    let protocolDeclaration = """
      protocol OverloadedParameterTypesProtocol {
        func compute(value: Int)
        func compute(for id: String)
        func compute(for ids: Set<String>) -> [String]
        func compute(value: Int) -> Bool
        func compute(value: Int?) -> [Int: String]
        func compute(value: String?) -> Bool
        func compute(value: Bool) -> Bool
      }
      """

    assertMacroExpansion(
      """
      @Spyable
      \(protocolDeclaration)
      """,
      expandedSource: """

        \(protocolDeclaration)

        class OverloadedParameterTypesProtocolSpy: OverloadedParameterTypesProtocol, @unchecked Sendable {
            init() {
            }
            var computeValueIntCallsCount = 0
            var computeValueIntCalled: Bool {
                return computeValueIntCallsCount > 0
            }
            var computeValueIntReceivedValue: Int?
            var computeValueIntReceivedInvocations: [Int] = []
            var computeValueIntClosure: ((Int) -> Void)?
            func compute(value: Int) {
                computeValueIntCallsCount += 1
                computeValueIntReceivedValue = (value)
                computeValueIntReceivedInvocations.append((value))
                computeValueIntClosure?(value)
            }
            var computeForStringCallsCount = 0
            var computeForStringCalled: Bool {
                return computeForStringCallsCount > 0
            }
            var computeForStringReceivedId: String?
            var computeForStringReceivedInvocations: [String] = []
            var computeForStringClosure: ((String) -> Void)?
            func compute(for id: String) {
                computeForStringCallsCount += 1
                computeForStringReceivedId = (id)
                computeForStringReceivedInvocations.append((id))
                computeForStringClosure?(id)
            }
            var computeForSetStringArrayStringCallsCount = 0
            var computeForSetStringArrayStringCalled: Bool {
                return computeForSetStringArrayStringCallsCount > 0
            }
            var computeForSetStringArrayStringReceivedIds: Set<String>?
            var computeForSetStringArrayStringReceivedInvocations: [Set<String>] = []
            var computeForSetStringArrayStringReturnValue: [String]!
            var computeForSetStringArrayStringClosure: ((Set<String>) -> [String])?
            func compute(for ids: Set<String>) -> [String] {
                computeForSetStringArrayStringCallsCount += 1
                computeForSetStringArrayStringReceivedIds = (ids)
                computeForSetStringArrayStringReceivedInvocations.append((ids))
                if computeForSetStringArrayStringClosure != nil {
                    return computeForSetStringArrayStringClosure!(ids)
                } else {
                    return computeForSetStringArrayStringReturnValue
                }
            }
            var computeValueIntBoolCallsCount = 0
            var computeValueIntBoolCalled: Bool {
                return computeValueIntBoolCallsCount > 0
            }
            var computeValueIntBoolReceivedValue: Int?
            var computeValueIntBoolReceivedInvocations: [Int] = []
            var computeValueIntBoolReturnValue: Bool!
            var computeValueIntBoolClosure: ((Int) -> Bool)?
            func compute(value: Int) -> Bool {
                computeValueIntBoolCallsCount += 1
                computeValueIntBoolReceivedValue = (value)
                computeValueIntBoolReceivedInvocations.append((value))
                if computeValueIntBoolClosure != nil {
                    return computeValueIntBoolClosure!(value)
                } else {
                    return computeValueIntBoolReturnValue
                }
            }
            var computeValueOptionalIntDictionaryIntStringCallsCount = 0
            var computeValueOptionalIntDictionaryIntStringCalled: Bool {
                return computeValueOptionalIntDictionaryIntStringCallsCount > 0
            }
            var computeValueOptionalIntDictionaryIntStringReceivedValue: Int?
            var computeValueOptionalIntDictionaryIntStringReceivedInvocations: [Int?] = []
            var computeValueOptionalIntDictionaryIntStringReturnValue: [Int: String]!
            var computeValueOptionalIntDictionaryIntStringClosure: ((Int?) -> [Int: String])?
            func compute(value: Int?) -> [Int: String] {
                computeValueOptionalIntDictionaryIntStringCallsCount += 1
                computeValueOptionalIntDictionaryIntStringReceivedValue = (value)
                computeValueOptionalIntDictionaryIntStringReceivedInvocations.append((value))
                if computeValueOptionalIntDictionaryIntStringClosure != nil {
                    return computeValueOptionalIntDictionaryIntStringClosure!(value)
                } else {
                    return computeValueOptionalIntDictionaryIntStringReturnValue
                }
            }
            var computeValueOptionalStringBoolCallsCount = 0
            var computeValueOptionalStringBoolCalled: Bool {
                return computeValueOptionalStringBoolCallsCount > 0
            }
            var computeValueOptionalStringBoolReceivedValue: String?
            var computeValueOptionalStringBoolReceivedInvocations: [String?] = []
            var computeValueOptionalStringBoolReturnValue: Bool!
            var computeValueOptionalStringBoolClosure: ((String?) -> Bool)?
            func compute(value: String?) -> Bool {
                computeValueOptionalStringBoolCallsCount += 1
                computeValueOptionalStringBoolReceivedValue = (value)
                computeValueOptionalStringBoolReceivedInvocations.append((value))
                if computeValueOptionalStringBoolClosure != nil {
                    return computeValueOptionalStringBoolClosure!(value)
                } else {
                    return computeValueOptionalStringBoolReturnValue
                }
            }
            var computeValueBoolBoolCallsCount = 0
            var computeValueBoolBoolCalled: Bool {
                return computeValueBoolBoolCallsCount > 0
            }
            var computeValueBoolBoolReceivedValue: Bool?
            var computeValueBoolBoolReceivedInvocations: [Bool] = []
            var computeValueBoolBoolReturnValue: Bool!
            var computeValueBoolBoolClosure: ((Bool) -> Bool)?
            func compute(value: Bool) -> Bool {
                computeValueBoolBoolCallsCount += 1
                computeValueBoolBoolReceivedValue = (value)
                computeValueBoolBoolReceivedInvocations.append((value))
                if computeValueBoolBoolClosure != nil {
                    return computeValueBoolBoolClosure!(value)
                } else {
                    return computeValueBoolBoolReturnValue
                }
            }
        }
        """,
      macros: sut
    )
  }

  func testPolymorphismOverloadedMethodsWithComplexTypes() {
    let protocolDeclaration = """
      protocol ComplexTypesProtocol {
        func doSomething() -> Set<Int>
        func doSomething() -> Set<Int?>
        func doSomething() -> Set<Int>?
        func doSomething() -> Result<String, Error>?
        func doSomething() -> Set<Int?>?
        
        func compute(value: Int) -> Result<String, Error>
        func compute(value: Int) -> Set<String>
        func compute(value: Int) -> Set<String?>
        func compute(value: Int) -> Set<String>?
        func compute(value: Int) -> Set<String?>?
        func compute(value: Int?) -> (String, Bool)
        func compute(value: Int?) -> (String, String?)
        func compute(value: Set<Int?>?) -> [Int: String]
        func compute(value: Set<Int?>) -> [Int: String]
        func compute(value: Set<Int>) -> [Int: String]
      }
      """

    assertMacroExpansion(
      """
      @Spyable
      \(protocolDeclaration)
      """,
      expandedSource: """

        \(protocolDeclaration)

        class ComplexTypesProtocolSpy: ComplexTypesProtocol, @unchecked Sendable {
            init() {
            }
            var doSomethingSetIntCallsCount = 0
            var doSomethingSetIntCalled: Bool {
                return doSomethingSetIntCallsCount > 0
            }
            var doSomethingSetIntReturnValue: Set<Int>!
            var doSomethingSetIntClosure: (() -> Set<Int>)?
            func doSomething() -> Set<Int> {
                doSomethingSetIntCallsCount += 1
                if doSomethingSetIntClosure != nil {
                    return doSomethingSetIntClosure!()
                } else {
                    return doSomethingSetIntReturnValue
                }
            }
            var doSomethingSetIntOptionalCallsCount = 0
            var doSomethingSetIntOptionalCalled: Bool {
                return doSomethingSetIntOptionalCallsCount > 0
            }
            var doSomethingSetIntOptionalReturnValue: Set<Int?>!
            var doSomethingSetIntOptionalClosure: (() -> Set<Int?>)?
            func doSomething() -> Set<Int?> {
                doSomethingSetIntOptionalCallsCount += 1
                if doSomethingSetIntOptionalClosure != nil {
                    return doSomethingSetIntOptionalClosure!()
                } else {
                    return doSomethingSetIntOptionalReturnValue
                }
            }
            var doSomethingOptionalSetIntCallsCount = 0
            var doSomethingOptionalSetIntCalled: Bool {
                return doSomethingOptionalSetIntCallsCount > 0
            }
            var doSomethingOptionalSetIntReturnValue: Set<Int>?
            var doSomethingOptionalSetIntClosure: (() -> Set<Int>?)?
            func doSomething() -> Set<Int>? {
                doSomethingOptionalSetIntCallsCount += 1
                if doSomethingOptionalSetIntClosure != nil {
                    return doSomethingOptionalSetIntClosure!()
                } else {
                    return doSomethingOptionalSetIntReturnValue
                }
            }
            var doSomethingOptionalResultStringErrorCallsCount = 0
            var doSomethingOptionalResultStringErrorCalled: Bool {
                return doSomethingOptionalResultStringErrorCallsCount > 0
            }
            var doSomethingOptionalResultStringErrorReturnValue: Result<String, Error>?
            var doSomethingOptionalResultStringErrorClosure: (() -> Result<String, Error>?)?
            func doSomething() -> Result<String, Error>? {
                doSomethingOptionalResultStringErrorCallsCount += 1
                if doSomethingOptionalResultStringErrorClosure != nil {
                    return doSomethingOptionalResultStringErrorClosure!()
                } else {
                    return doSomethingOptionalResultStringErrorReturnValue
                }
            }
            var doSomethingOptionalSetIntOptionalCallsCount = 0
            var doSomethingOptionalSetIntOptionalCalled: Bool {
                return doSomethingOptionalSetIntOptionalCallsCount > 0
            }
            var doSomethingOptionalSetIntOptionalReturnValue: Set<Int?>?
            var doSomethingOptionalSetIntOptionalClosure: (() -> Set<Int?>?)?
            func doSomething() -> Set<Int?>? {
                doSomethingOptionalSetIntOptionalCallsCount += 1
                if doSomethingOptionalSetIntOptionalClosure != nil {
                    return doSomethingOptionalSetIntOptionalClosure!()
                } else {
                    return doSomethingOptionalSetIntOptionalReturnValue
                }
            }
            var computeValueIntResultStringErrorCallsCount = 0
            var computeValueIntResultStringErrorCalled: Bool {
                return computeValueIntResultStringErrorCallsCount > 0
            }
            var computeValueIntResultStringErrorReceivedValue: Int?
            var computeValueIntResultStringErrorReceivedInvocations: [Int] = []
            var computeValueIntResultStringErrorReturnValue: Result<String, Error>!
            var computeValueIntResultStringErrorClosure: ((Int) -> Result<String, Error>)?

            func compute(value: Int) -> Result<String, Error> {
                computeValueIntResultStringErrorCallsCount += 1
                computeValueIntResultStringErrorReceivedValue = (value)
                computeValueIntResultStringErrorReceivedInvocations.append((value))
                if computeValueIntResultStringErrorClosure != nil {
                    return computeValueIntResultStringErrorClosure!(value)
                } else {
                    return computeValueIntResultStringErrorReturnValue
                }
            }
            var computeValueIntSetStringCallsCount = 0
            var computeValueIntSetStringCalled: Bool {
                return computeValueIntSetStringCallsCount > 0
            }
            var computeValueIntSetStringReceivedValue: Int?
            var computeValueIntSetStringReceivedInvocations: [Int] = []
            var computeValueIntSetStringReturnValue: Set<String>!
            var computeValueIntSetStringClosure: ((Int) -> Set<String>)?
            func compute(value: Int) -> Set<String> {
                computeValueIntSetStringCallsCount += 1
                computeValueIntSetStringReceivedValue = (value)
                computeValueIntSetStringReceivedInvocations.append((value))
                if computeValueIntSetStringClosure != nil {
                    return computeValueIntSetStringClosure!(value)
                } else {
                    return computeValueIntSetStringReturnValue
                }
            }
            var computeValueIntSetStringOptionalCallsCount = 0
            var computeValueIntSetStringOptionalCalled: Bool {
                return computeValueIntSetStringOptionalCallsCount > 0
            }
            var computeValueIntSetStringOptionalReceivedValue: Int?
            var computeValueIntSetStringOptionalReceivedInvocations: [Int] = []
            var computeValueIntSetStringOptionalReturnValue: Set<String?>!
            var computeValueIntSetStringOptionalClosure: ((Int) -> Set<String?>)?
            func compute(value: Int) -> Set<String?> {
                computeValueIntSetStringOptionalCallsCount += 1
                computeValueIntSetStringOptionalReceivedValue = (value)
                computeValueIntSetStringOptionalReceivedInvocations.append((value))
                if computeValueIntSetStringOptionalClosure != nil {
                    return computeValueIntSetStringOptionalClosure!(value)
                } else {
                    return computeValueIntSetStringOptionalReturnValue
                }
            }
            var computeValueIntOptionalSetStringCallsCount = 0
            var computeValueIntOptionalSetStringCalled: Bool {
                return computeValueIntOptionalSetStringCallsCount > 0
            }
            var computeValueIntOptionalSetStringReceivedValue: Int?
            var computeValueIntOptionalSetStringReceivedInvocations: [Int] = []
            var computeValueIntOptionalSetStringReturnValue: Set<String>?
            var computeValueIntOptionalSetStringClosure: ((Int) -> Set<String>?)?
            func compute(value: Int) -> Set<String>? {
                computeValueIntOptionalSetStringCallsCount += 1
                computeValueIntOptionalSetStringReceivedValue = (value)
                computeValueIntOptionalSetStringReceivedInvocations.append((value))
                if computeValueIntOptionalSetStringClosure != nil {
                    return computeValueIntOptionalSetStringClosure!(value)
                } else {
                    return computeValueIntOptionalSetStringReturnValue
                }
            }
            var computeValueIntOptionalSetStringOptionalCallsCount = 0
            var computeValueIntOptionalSetStringOptionalCalled: Bool {
                return computeValueIntOptionalSetStringOptionalCallsCount > 0
            }
            var computeValueIntOptionalSetStringOptionalReceivedValue: Int?
            var computeValueIntOptionalSetStringOptionalReceivedInvocations: [Int] = []
            var computeValueIntOptionalSetStringOptionalReturnValue: Set<String?>?
            var computeValueIntOptionalSetStringOptionalClosure: ((Int) -> Set<String?>?)?
            func compute(value: Int) -> Set<String?>? {
                computeValueIntOptionalSetStringOptionalCallsCount += 1
                computeValueIntOptionalSetStringOptionalReceivedValue = (value)
                computeValueIntOptionalSetStringOptionalReceivedInvocations.append((value))
                if computeValueIntOptionalSetStringOptionalClosure != nil {
                    return computeValueIntOptionalSetStringOptionalClosure!(value)
                } else {
                    return computeValueIntOptionalSetStringOptionalReturnValue
                }
            }
            var computeValueOptionalIntStringBoolCallsCount = 0
            var computeValueOptionalIntStringBoolCalled: Bool {
                return computeValueOptionalIntStringBoolCallsCount > 0
            }
            var computeValueOptionalIntStringBoolReceivedValue: Int?
            var computeValueOptionalIntStringBoolReceivedInvocations: [Int?] = []
            var computeValueOptionalIntStringBoolReturnValue: (String, Bool)!
            var computeValueOptionalIntStringBoolClosure: ((Int?) -> (String, Bool))?
            func compute(value: Int?) -> (String, Bool) {
                computeValueOptionalIntStringBoolCallsCount += 1
                computeValueOptionalIntStringBoolReceivedValue = (value)
                computeValueOptionalIntStringBoolReceivedInvocations.append((value))
                if computeValueOptionalIntStringBoolClosure != nil {
                    return computeValueOptionalIntStringBoolClosure!(value)
                } else {
                    return computeValueOptionalIntStringBoolReturnValue
                }
            }
            var computeValueOptionalIntStringStringOptionalCallsCount = 0
            var computeValueOptionalIntStringStringOptionalCalled: Bool {
                return computeValueOptionalIntStringStringOptionalCallsCount > 0
            }
            var computeValueOptionalIntStringStringOptionalReceivedValue: Int?
            var computeValueOptionalIntStringStringOptionalReceivedInvocations: [Int?] = []
            var computeValueOptionalIntStringStringOptionalReturnValue: (String, String?)!
            var computeValueOptionalIntStringStringOptionalClosure: ((Int?) -> (String, String?))?
            func compute(value: Int?) -> (String, String?) {
                computeValueOptionalIntStringStringOptionalCallsCount += 1
                computeValueOptionalIntStringStringOptionalReceivedValue = (value)
                computeValueOptionalIntStringStringOptionalReceivedInvocations.append((value))
                if computeValueOptionalIntStringStringOptionalClosure != nil {
                    return computeValueOptionalIntStringStringOptionalClosure!(value)
                } else {
                    return computeValueOptionalIntStringStringOptionalReturnValue
                }
            }
            var computeValueOptionalSetIntOptionalDictionaryIntStringCallsCount = 0
            var computeValueOptionalSetIntOptionalDictionaryIntStringCalled: Bool {
                return computeValueOptionalSetIntOptionalDictionaryIntStringCallsCount > 0
            }
            var computeValueOptionalSetIntOptionalDictionaryIntStringReceivedValue: Set<Int?>?
            var computeValueOptionalSetIntOptionalDictionaryIntStringReceivedInvocations: [Set<Int?>?] = []
            var computeValueOptionalSetIntOptionalDictionaryIntStringReturnValue: [Int: String]!
            var computeValueOptionalSetIntOptionalDictionaryIntStringClosure: ((Set<Int?>?) -> [Int: String])?
            func compute(value: Set<Int?>?) -> [Int: String] {
                computeValueOptionalSetIntOptionalDictionaryIntStringCallsCount += 1
                computeValueOptionalSetIntOptionalDictionaryIntStringReceivedValue = (value)
                computeValueOptionalSetIntOptionalDictionaryIntStringReceivedInvocations.append((value))
                if computeValueOptionalSetIntOptionalDictionaryIntStringClosure != nil {
                    return computeValueOptionalSetIntOptionalDictionaryIntStringClosure!(value)
                } else {
                    return computeValueOptionalSetIntOptionalDictionaryIntStringReturnValue
                }
            }
            var computeValueSetIntOptionalDictionaryIntStringCallsCount = 0
            var computeValueSetIntOptionalDictionaryIntStringCalled: Bool {
                return computeValueSetIntOptionalDictionaryIntStringCallsCount > 0
            }
            var computeValueSetIntOptionalDictionaryIntStringReceivedValue: Set<Int?>?
            var computeValueSetIntOptionalDictionaryIntStringReceivedInvocations: [Set<Int?>] = []
            var computeValueSetIntOptionalDictionaryIntStringReturnValue: [Int: String]!
            var computeValueSetIntOptionalDictionaryIntStringClosure: ((Set<Int?>) -> [Int: String])?
            func compute(value: Set<Int?>) -> [Int: String] {
                computeValueSetIntOptionalDictionaryIntStringCallsCount += 1
                computeValueSetIntOptionalDictionaryIntStringReceivedValue = (value)
                computeValueSetIntOptionalDictionaryIntStringReceivedInvocations.append((value))
                if computeValueSetIntOptionalDictionaryIntStringClosure != nil {
                    return computeValueSetIntOptionalDictionaryIntStringClosure!(value)
                } else {
                    return computeValueSetIntOptionalDictionaryIntStringReturnValue
                }
            }
            var computeValueSetIntDictionaryIntStringCallsCount = 0
            var computeValueSetIntDictionaryIntStringCalled: Bool {
                return computeValueSetIntDictionaryIntStringCallsCount > 0
            }
            var computeValueSetIntDictionaryIntStringReceivedValue: Set<Int>?
            var computeValueSetIntDictionaryIntStringReceivedInvocations: [Set<Int>] = []
            var computeValueSetIntDictionaryIntStringReturnValue: [Int: String]!
            var computeValueSetIntDictionaryIntStringClosure: ((Set<Int>) -> [Int: String])?
            func compute(value: Set<Int>) -> [Int: String] {
                computeValueSetIntDictionaryIntStringCallsCount += 1
                computeValueSetIntDictionaryIntStringReceivedValue = (value)
                computeValueSetIntDictionaryIntStringReceivedInvocations.append((value))
                if computeValueSetIntDictionaryIntStringClosure != nil {
                    return computeValueSetIntDictionaryIntStringClosure!(value)
                } else {
                    return computeValueSetIntDictionaryIntStringReturnValue
                }
            }
        }
        """,
      macros: sut
    )
  }

  func testPolymorphismOverloadedMethodsWithOptionalTypes() {
    let protocolDeclaration = """
      protocol OptionalTypesProtocol {
        func compute(value: Int) -> Double?
        func compute(value: Int) -> [Int]
        func compute(value: Int?) -> [Int: String]
        func compute(value: String?) -> Bool
      }
      """

    assertMacroExpansion(
      """
      @Spyable
      \(protocolDeclaration)
      """,
      expandedSource: """

        \(protocolDeclaration)

        class OptionalTypesProtocolSpy: OptionalTypesProtocol, @unchecked Sendable {
            init() {
            }
            var computeValueIntOptionalDoubleCallsCount = 0
            var computeValueIntOptionalDoubleCalled: Bool {
                return computeValueIntOptionalDoubleCallsCount > 0
            }
            var computeValueIntOptionalDoubleReceivedValue: Int?
            var computeValueIntOptionalDoubleReceivedInvocations: [Int] = []
            var computeValueIntOptionalDoubleReturnValue: Double?
            var computeValueIntOptionalDoubleClosure: ((Int) -> Double?)?
            func compute(value: Int) -> Double? {
                computeValueIntOptionalDoubleCallsCount += 1
                computeValueIntOptionalDoubleReceivedValue = (value)
                computeValueIntOptionalDoubleReceivedInvocations.append((value))
                if computeValueIntOptionalDoubleClosure != nil {
                    return computeValueIntOptionalDoubleClosure!(value)
                } else {
                    return computeValueIntOptionalDoubleReturnValue
                }
            }
            var computeValueIntArrayIntCallsCount = 0
            var computeValueIntArrayIntCalled: Bool {
                return computeValueIntArrayIntCallsCount > 0
            }
            var computeValueIntArrayIntReceivedValue: Int?
            var computeValueIntArrayIntReceivedInvocations: [Int] = []
            var computeValueIntArrayIntReturnValue: [Int]!
            var computeValueIntArrayIntClosure: ((Int) -> [Int])?
            func compute(value: Int) -> [Int] {
                computeValueIntArrayIntCallsCount += 1
                computeValueIntArrayIntReceivedValue = (value)
                computeValueIntArrayIntReceivedInvocations.append((value))
                if computeValueIntArrayIntClosure != nil {
                    return computeValueIntArrayIntClosure!(value)
                } else {
                    return computeValueIntArrayIntReturnValue
                }
            }
            var computeValueOptionalIntDictionaryIntStringCallsCount = 0
            var computeValueOptionalIntDictionaryIntStringCalled: Bool {
                return computeValueOptionalIntDictionaryIntStringCallsCount > 0
            }
            var computeValueOptionalIntDictionaryIntStringReceivedValue: Int?
            var computeValueOptionalIntDictionaryIntStringReceivedInvocations: [Int?] = []
            var computeValueOptionalIntDictionaryIntStringReturnValue: [Int: String]!
            var computeValueOptionalIntDictionaryIntStringClosure: ((Int?) -> [Int: String])?
            func compute(value: Int?) -> [Int: String] {
                computeValueOptionalIntDictionaryIntStringCallsCount += 1
                computeValueOptionalIntDictionaryIntStringReceivedValue = (value)
                computeValueOptionalIntDictionaryIntStringReceivedInvocations.append((value))
                if computeValueOptionalIntDictionaryIntStringClosure != nil {
                    return computeValueOptionalIntDictionaryIntStringClosure!(value)
                } else {
                    return computeValueOptionalIntDictionaryIntStringReturnValue
                }
            }
            var computeValueOptionalStringBoolCallsCount = 0
            var computeValueOptionalStringBoolCalled: Bool {
                return computeValueOptionalStringBoolCallsCount > 0
            }
            var computeValueOptionalStringBoolReceivedValue: String?
            var computeValueOptionalStringBoolReceivedInvocations: [String?] = []
            var computeValueOptionalStringBoolReturnValue: Bool!
            var computeValueOptionalStringBoolClosure: ((String?) -> Bool)?
            func compute(value: String?) -> Bool {
                computeValueOptionalStringBoolCallsCount += 1
                computeValueOptionalStringBoolReceivedValue = (value)
                computeValueOptionalStringBoolReceivedInvocations.append((value))
                if computeValueOptionalStringBoolClosure != nil {
                    return computeValueOptionalStringBoolClosure!(value)
                } else {
                    return computeValueOptionalStringBoolReturnValue
                }
            }
        }
        """,
      macros: sut
    )
  }

  func testPolymorphismMethodsWithGenericReturnTypes() {
    let protocolDeclaration = """
      protocol GenericReturnTypesProtocol {
        func baz(id: Int) -> any Equatable
        func baz(id: String) -> any Equatable
      }
      """

    assertMacroExpansion(
      """
      @Spyable
      \(protocolDeclaration)
      """,
      expandedSource: """

        \(protocolDeclaration)

        class GenericReturnTypesProtocolSpy: GenericReturnTypesProtocol, @unchecked Sendable {
            init() {
            }
            var bazIdIntanyEquatableCallsCount = 0
            var bazIdIntanyEquatableCalled: Bool {
                return bazIdIntanyEquatableCallsCount > 0
            }
            var bazIdIntanyEquatableReceivedId: Int?
            var bazIdIntanyEquatableReceivedInvocations: [Int] = []
            var bazIdIntanyEquatableReturnValue: (any Equatable)!
            var bazIdIntanyEquatableClosure: ((Int) -> any Equatable)?
            func baz(id: Int) -> any Equatable {
                bazIdIntanyEquatableCallsCount += 1
                bazIdIntanyEquatableReceivedId = (id)
                bazIdIntanyEquatableReceivedInvocations.append((id))
                if bazIdIntanyEquatableClosure != nil {
                    return bazIdIntanyEquatableClosure!(id)
                } else {
                    return bazIdIntanyEquatableReturnValue
                }
            }
            var bazIdStringanyEquatableCallsCount = 0
            var bazIdStringanyEquatableCalled: Bool {
                return bazIdStringanyEquatableCallsCount > 0
            }
            var bazIdStringanyEquatableReceivedId: String?
            var bazIdStringanyEquatableReceivedInvocations: [String] = []
            var bazIdStringanyEquatableReturnValue: (any Equatable)!
            var bazIdStringanyEquatableClosure: ((String) -> any Equatable)?
            func baz(id: String) -> any Equatable {
                bazIdStringanyEquatableCallsCount += 1
                bazIdStringanyEquatableReceivedId = (id)
                bazIdStringanyEquatableReceivedInvocations.append((id))
                if bazIdStringanyEquatableClosure != nil {
                    return bazIdStringanyEquatableClosure!(id)
                } else {
                    return bazIdStringanyEquatableReturnValue
                }
            }
        }
        """,
      macros: sut
    )
  }

  func testPolymorphismWithGenericConstraints() {
    let protocolDeclaration = """
      protocol GenericConstraintsProtocol {
        func process<T: Codable>(value: T)
        func process<T: Codable>(value: T) -> T
        func process<T: Codable>(value: T) -> String
        func transform<T: Codable & Hashable>(value: T)
        func transform<T: Codable & Hashable>(value: T) -> T
        func transform<T: Codable & Hashable>(value: T) -> [T]
        func convert<T>(value: T) where T: Equatable
        func convert<T>(value: T) -> T where T: Equatable
        func convert<T>(value: T) -> Bool where T: Equatable
        func convert<T, U>(value: T, other: U) where T: Equatable, U: Hashable
        func convert<T, U>(value: T, other: U) -> Bool where T: Equatable, U: Hashable
      }
      """

    assertMacroExpansion(
      """
      @Spyable
      \(protocolDeclaration)
      """,
      expandedSource: """

        \(protocolDeclaration)

        class GenericConstraintsProtocolSpy: GenericConstraintsProtocol, @unchecked Sendable {
            init() {
            }
            var processValueTCallsCount = 0
            var processValueTCalled: Bool {
                return processValueTCallsCount > 0
            }
            var processValueTReceivedValue: Any?
            var processValueTReceivedInvocations: [Any] = []
            var processValueTClosure: ((Any) -> Void)?
            func process<T: Codable>(value: T) {
                processValueTCallsCount += 1
                processValueTReceivedValue = (value)
                processValueTReceivedInvocations.append((value))
                processValueTClosure?(value)
            }
            var processValueTTCallsCount = 0
            var processValueTTCalled: Bool {
                return processValueTTCallsCount > 0
            }
            var processValueTTReceivedValue: Any?
            var processValueTTReceivedInvocations: [Any] = []
            var processValueTTReturnValue: Any!
            var processValueTTClosure: ((Any) -> Any)?
            func process<T: Codable>(value: T) -> T {
                processValueTTCallsCount += 1
                processValueTTReceivedValue = (value)
                processValueTTReceivedInvocations.append((value))
                if processValueTTClosure != nil {
                    return processValueTTClosure!(value) as! T
                } else {
                    return processValueTTReturnValue as! T
                }
            }
            var processValueTStringCallsCount = 0
            var processValueTStringCalled: Bool {
                return processValueTStringCallsCount > 0
            }
            var processValueTStringReceivedValue: Any?
            var processValueTStringReceivedInvocations: [Any] = []
            var processValueTStringReturnValue: String!
            var processValueTStringClosure: ((Any) -> String)?
            func process<T: Codable>(value: T) -> String {
                processValueTStringCallsCount += 1
                processValueTStringReceivedValue = (value)
                processValueTStringReceivedInvocations.append((value))
                if processValueTStringClosure != nil {
                    return processValueTStringClosure!(value)
                } else {
                    return processValueTStringReturnValue
                }
            }
            var transformValueTCallsCount = 0
            var transformValueTCalled: Bool {
                return transformValueTCallsCount > 0
            }
            var transformValueTReceivedValue: Any?
            var transformValueTReceivedInvocations: [Any] = []
            var transformValueTClosure: ((Any) -> Void)?
            func transform<T: Codable & Hashable>(value: T) {
                transformValueTCallsCount += 1
                transformValueTReceivedValue = (value)
                transformValueTReceivedInvocations.append((value))
                transformValueTClosure?(value)
            }
            var transformValueTTCallsCount = 0
            var transformValueTTCalled: Bool {
                return transformValueTTCallsCount > 0
            }
            var transformValueTTReceivedValue: Any?
            var transformValueTTReceivedInvocations: [Any] = []
            var transformValueTTReturnValue: Any!
            var transformValueTTClosure: ((Any) -> Any)?
            func transform<T: Codable & Hashable>(value: T) -> T {
                transformValueTTCallsCount += 1
                transformValueTTReceivedValue = (value)
                transformValueTTReceivedInvocations.append((value))
                if transformValueTTClosure != nil {
                    return transformValueTTClosure!(value) as! T
                } else {
                    return transformValueTTReturnValue as! T
                }
            }
            var transformValueTArrayTCallsCount = 0
            var transformValueTArrayTCalled: Bool {
                return transformValueTArrayTCallsCount > 0
            }
            var transformValueTArrayTReceivedValue: Any?
            var transformValueTArrayTReceivedInvocations: [Any] = []
            var transformValueTArrayTReturnValue: [Any]!
            var transformValueTArrayTClosure: ((Any) -> [Any])?
            func transform<T: Codable & Hashable>(value: T) -> [T] {
                transformValueTArrayTCallsCount += 1
                transformValueTArrayTReceivedValue = (value)
                transformValueTArrayTReceivedInvocations.append((value))
                if transformValueTArrayTClosure != nil {
                    return transformValueTArrayTClosure!(value) as! [T]
                } else {
                    return transformValueTArrayTReturnValue as! [T]
                }
            }
            var convertValueTCallsCount = 0
            var convertValueTCalled: Bool {
                return convertValueTCallsCount > 0
            }
            var convertValueTReceivedValue: Any?
            var convertValueTReceivedInvocations: [Any] = []
            var convertValueTClosure: ((Any) -> Void)?
            func convert<T>(value: T) where T: Equatable {
                convertValueTCallsCount += 1
                convertValueTReceivedValue = (value)
                convertValueTReceivedInvocations.append((value))
                convertValueTClosure?(value)
            }
            var convertValueTTCallsCount = 0
            var convertValueTTCalled: Bool {
                return convertValueTTCallsCount > 0
            }
            var convertValueTTReceivedValue: Any?
            var convertValueTTReceivedInvocations: [Any] = []
            var convertValueTTReturnValue: Any!
            var convertValueTTClosure: ((Any) -> Any)?
            func convert<T>(value: T) -> T where T: Equatable {
                convertValueTTCallsCount += 1
                convertValueTTReceivedValue = (value)
                convertValueTTReceivedInvocations.append((value))
                if convertValueTTClosure != nil {
                    return convertValueTTClosure!(value) as! T
                } else {
                    return convertValueTTReturnValue as! T
                }
            }
            var convertValueTBoolCallsCount = 0
            var convertValueTBoolCalled: Bool {
                return convertValueTBoolCallsCount > 0
            }
            var convertValueTBoolReceivedValue: Any?
            var convertValueTBoolReceivedInvocations: [Any] = []
            var convertValueTBoolReturnValue: Bool!
            var convertValueTBoolClosure: ((Any) -> Bool)?
            func convert<T>(value: T) -> Bool where T: Equatable {
                convertValueTBoolCallsCount += 1
                convertValueTBoolReceivedValue = (value)
                convertValueTBoolReceivedInvocations.append((value))
                if convertValueTBoolClosure != nil {
                    return convertValueTBoolClosure!(value)
                } else {
                    return convertValueTBoolReturnValue
                }
            }
            var convertValueTOtherUCallsCount = 0
            var convertValueTOtherUCalled: Bool {
                return convertValueTOtherUCallsCount > 0
            }
            var convertValueTOtherUReceivedArguments: (value: Any, other: Any)?
            var convertValueTOtherUReceivedInvocations: [(value: Any, other: Any)] = []
            var convertValueTOtherUClosure: ((Any, Any) -> Void)?
            func convert<T, U>(value: T, other: U) where T: Equatable, U: Hashable {
                convertValueTOtherUCallsCount += 1
                convertValueTOtherUReceivedArguments = (value, other)
                convertValueTOtherUReceivedInvocations.append((value, other))
                convertValueTOtherUClosure?(value, other)
            }
            var convertValueTOtherUBoolCallsCount = 0
            var convertValueTOtherUBoolCalled: Bool {
                return convertValueTOtherUBoolCallsCount > 0
            }
            var convertValueTOtherUBoolReceivedArguments: (value: Any, other: Any)?
            var convertValueTOtherUBoolReceivedInvocations: [(value: Any, other: Any)] = []
            var convertValueTOtherUBoolReturnValue: Bool!
            var convertValueTOtherUBoolClosure: ((Any, Any) -> Bool)?
            func convert<T, U>(value: T, other: U) -> Bool where T: Equatable, U: Hashable {
                convertValueTOtherUBoolCallsCount += 1
                convertValueTOtherUBoolReceivedArguments = (value, other)
                convertValueTOtherUBoolReceivedInvocations.append((value, other))
                if convertValueTOtherUBoolClosure != nil {
                    return convertValueTOtherUBoolClosure!(value, other)
                } else {
                    return convertValueTOtherUBoolReturnValue
                }
            }
        }
        """,
      macros: sut
    )
  }

  func testPolymorphismWithProtocolCompositions() {
    let protocolDeclaration = """
      protocol ProtocolCompositionsProtocol {
        func handle(value: Codable & Sendable)
        func handle(value: Codable & Sendable) -> String
        func handle(value: Codable & Sendable) -> Bool
        func handle(value: Codable & Hashable & Sendable)
        func handle(value: Codable & Hashable & Sendable) -> Int
        func create() -> Codable & Hashable
        func create() -> Codable & Sendable
        func create(with id: String) -> Codable & Hashable
        func create(with id: Int) -> Codable & Hashable
        func process(item: any Codable & Sendable, handler: (any Codable & Sendable) -> Void)
        func process(item: any Codable & Sendable, handler: (any Codable & Sendable) -> String)
      }
      """

    assertMacroExpansion(
      """
      @Spyable
      \(protocolDeclaration)
      """,
      expandedSource: """

        \(protocolDeclaration)

        class ProtocolCompositionsProtocolSpy: ProtocolCompositionsProtocol, @unchecked Sendable {
            init() {
            }
            var handleValueCodableSendableCallsCount = 0
            var handleValueCodableSendableCalled: Bool {
                return handleValueCodableSendableCallsCount > 0
            }
            var handleValueCodableSendableReceivedValue: Codable & Sendable?
            var handleValueCodableSendableReceivedInvocations: [Codable & Sendable] = []
            var handleValueCodableSendableClosure: ((Codable & Sendable) -> Void)?
            func handle(value: Codable & Sendable) {
                handleValueCodableSendableCallsCount += 1
                handleValueCodableSendableReceivedValue = (value)
                handleValueCodableSendableReceivedInvocations.append((value))
                handleValueCodableSendableClosure?(value)
            }
            var handleValueCodableSendableStringCallsCount = 0
            var handleValueCodableSendableStringCalled: Bool {
                return handleValueCodableSendableStringCallsCount > 0
            }
            var handleValueCodableSendableStringReceivedValue: Codable & Sendable?
            var handleValueCodableSendableStringReceivedInvocations: [Codable & Sendable] = []
            var handleValueCodableSendableStringReturnValue: String!
            var handleValueCodableSendableStringClosure: ((Codable & Sendable) -> String)?
            func handle(value: Codable & Sendable) -> String {
                handleValueCodableSendableStringCallsCount += 1
                handleValueCodableSendableStringReceivedValue = (value)
                handleValueCodableSendableStringReceivedInvocations.append((value))
                if handleValueCodableSendableStringClosure != nil {
                    return handleValueCodableSendableStringClosure!(value)
                } else {
                    return handleValueCodableSendableStringReturnValue
                }
            }
            var handleValueCodableSendableBoolCallsCount = 0
            var handleValueCodableSendableBoolCalled: Bool {
                return handleValueCodableSendableBoolCallsCount > 0
            }
            var handleValueCodableSendableBoolReceivedValue: Codable & Sendable?
            var handleValueCodableSendableBoolReceivedInvocations: [Codable & Sendable] = []
            var handleValueCodableSendableBoolReturnValue: Bool!
            var handleValueCodableSendableBoolClosure: ((Codable & Sendable) -> Bool)?
            func handle(value: Codable & Sendable) -> Bool {
                handleValueCodableSendableBoolCallsCount += 1
                handleValueCodableSendableBoolReceivedValue = (value)
                handleValueCodableSendableBoolReceivedInvocations.append((value))
                if handleValueCodableSendableBoolClosure != nil {
                    return handleValueCodableSendableBoolClosure!(value)
                } else {
                    return handleValueCodableSendableBoolReturnValue
                }
            }
            var handleValueCodableHashableSendableCallsCount = 0
            var handleValueCodableHashableSendableCalled: Bool {
                return handleValueCodableHashableSendableCallsCount > 0
            }
            var handleValueCodableHashableSendableReceivedValue: Codable & Hashable & Sendable?
            var handleValueCodableHashableSendableReceivedInvocations: [Codable & Hashable & Sendable] = []
            var handleValueCodableHashableSendableClosure: ((Codable & Hashable & Sendable) -> Void)?
            func handle(value: Codable & Hashable & Sendable) {
                handleValueCodableHashableSendableCallsCount += 1
                handleValueCodableHashableSendableReceivedValue = (value)
                handleValueCodableHashableSendableReceivedInvocations.append((value))
                handleValueCodableHashableSendableClosure?(value)
            }
            var handleValueCodableHashableSendableIntCallsCount = 0
            var handleValueCodableHashableSendableIntCalled: Bool {
                return handleValueCodableHashableSendableIntCallsCount > 0
            }
            var handleValueCodableHashableSendableIntReceivedValue: Codable & Hashable & Sendable?
            var handleValueCodableHashableSendableIntReceivedInvocations: [Codable & Hashable & Sendable] = []
            var handleValueCodableHashableSendableIntReturnValue: Int!
            var handleValueCodableHashableSendableIntClosure: ((Codable & Hashable & Sendable) -> Int)?
            func handle(value: Codable & Hashable & Sendable) -> Int {
                handleValueCodableHashableSendableIntCallsCount += 1
                handleValueCodableHashableSendableIntReceivedValue = (value)
                handleValueCodableHashableSendableIntReceivedInvocations.append((value))
                if handleValueCodableHashableSendableIntClosure != nil {
                    return handleValueCodableHashableSendableIntClosure!(value)
                } else {
                    return handleValueCodableHashableSendableIntReturnValue
                }
            }
            var createCodableHashableCallsCount = 0
            var createCodableHashableCalled: Bool {
                return createCodableHashableCallsCount > 0
            }
            var createCodableHashableReturnValue: Codable & Hashable!
            var createCodableHashableClosure: (() -> Codable & Hashable)?
            func create() -> Codable & Hashable {
                createCodableHashableCallsCount += 1
                if createCodableHashableClosure != nil {
                    return createCodableHashableClosure!()
                } else {
                    return createCodableHashableReturnValue
                }
            }
            var createCodableSendableCallsCount = 0
            var createCodableSendableCalled: Bool {
                return createCodableSendableCallsCount > 0
            }
            var createCodableSendableReturnValue: Codable & Sendable!
            var createCodableSendableClosure: (() -> Codable & Sendable)?
            func create() -> Codable & Sendable {
                createCodableSendableCallsCount += 1
                if createCodableSendableClosure != nil {
                    return createCodableSendableClosure!()
                } else {
                    return createCodableSendableReturnValue
                }
            }
            var createWithStringCodableHashableCallsCount = 0
            var createWithStringCodableHashableCalled: Bool {
                return createWithStringCodableHashableCallsCount > 0
            }
            var createWithStringCodableHashableReceivedId: String?
            var createWithStringCodableHashableReceivedInvocations: [String] = []
            var createWithStringCodableHashableReturnValue: Codable & Hashable!
            var createWithStringCodableHashableClosure: ((String) -> Codable & Hashable)?
            func create(with id: String) -> Codable & Hashable {
                createWithStringCodableHashableCallsCount += 1
                createWithStringCodableHashableReceivedId = (id)
                createWithStringCodableHashableReceivedInvocations.append((id))
                if createWithStringCodableHashableClosure != nil {
                    return createWithStringCodableHashableClosure!(id)
                } else {
                    return createWithStringCodableHashableReturnValue
                }
            }
            var createWithIntCodableHashableCallsCount = 0
            var createWithIntCodableHashableCalled: Bool {
                return createWithIntCodableHashableCallsCount > 0
            }
            var createWithIntCodableHashableReceivedId: Int?
            var createWithIntCodableHashableReceivedInvocations: [Int] = []
            var createWithIntCodableHashableReturnValue: Codable & Hashable!
            var createWithIntCodableHashableClosure: ((Int) -> Codable & Hashable)?
            func create(with id: Int) -> Codable & Hashable {
                createWithIntCodableHashableCallsCount += 1
                createWithIntCodableHashableReceivedId = (id)
                createWithIntCodableHashableReceivedInvocations.append((id))
                if createWithIntCodableHashableClosure != nil {
                    return createWithIntCodableHashableClosure!(id)
                } else {
                    return createWithIntCodableHashableReturnValue
                }
            }
            var processItemanyCodableSendableHandleranyCodableSendableVoidCallsCount = 0
            var processItemanyCodableSendableHandleranyCodableSendableVoidCalled: Bool {
                return processItemanyCodableSendableHandleranyCodableSendableVoidCallsCount > 0
            }
            var processItemanyCodableSendableHandleranyCodableSendableVoidClosure: ((any Codable & Sendable, (any Codable & Sendable) -> Void) -> Void)?
            func process(item: any Codable & Sendable, handler: (any Codable & Sendable) -> Void) {
                processItemanyCodableSendableHandleranyCodableSendableVoidCallsCount += 1
                processItemanyCodableSendableHandleranyCodableSendableVoidClosure?(item, handler)
            }
            var processItemanyCodableSendableHandleranyCodableSendableStringCallsCount = 0
            var processItemanyCodableSendableHandleranyCodableSendableStringCalled: Bool {
                return processItemanyCodableSendableHandleranyCodableSendableStringCallsCount > 0
            }
            var processItemanyCodableSendableHandleranyCodableSendableStringClosure: ((any Codable & Sendable, (any Codable & Sendable) -> String) -> Void)?
            func process(item: any Codable & Sendable, handler: (any Codable & Sendable) -> String) {
                processItemanyCodableSendableHandleranyCodableSendableStringCallsCount += 1
                processItemanyCodableSendableHandleranyCodableSendableStringClosure?(item, handler)
            }
        }
        """,
      macros: sut
    )
  }

  func testPolymorphismWithAssociatedTypes() {
    let protocolDeclaration = """
      protocol AssociatedTypesProtocol {
        associatedtype Item
        associatedtype Container: Collection
        
        func process(item: Item)
        func process(item: Item) -> Item
        func process(item: Item) -> String
        func process(items: [Item])
        func process(items: [Item]) -> [Item]
        func transform(container: Container)
        func transform(container: Container) -> Container
        func transform(container: Container) -> Int
        func handle(item: Self)
        func handle(item: Self) -> Self
        func handle(item: Self) -> Bool
        func compare(first: Item, second: Item) -> Bool
        func compare(first: Item, second: Item) -> Item
      }
      """

    assertMacroExpansion(
      """
      @Spyable
      \(protocolDeclaration)
      """,
      expandedSource: """

        \(protocolDeclaration)

        class AssociatedTypesProtocolSpy<Item, Container: Collection>: AssociatedTypesProtocol, @unchecked Sendable {
            init() {
            }
            var processItemItemCallsCount = 0
            var processItemItemCalled: Bool {
                return processItemItemCallsCount > 0
            }
            var processItemItemReceivedItem: Item?
            var processItemItemReceivedInvocations: [Item] = []
            var processItemItemClosure: ((Item) -> Void)?

            func process(item: Item) {
                processItemItemCallsCount += 1
                processItemItemReceivedItem = (item)
                processItemItemReceivedInvocations.append((item))
                processItemItemClosure?(item)
            }
            var processItemItemItemCallsCount = 0
            var processItemItemItemCalled: Bool {
                return processItemItemItemCallsCount > 0
            }
            var processItemItemItemReceivedItem: Item?
            var processItemItemItemReceivedInvocations: [Item] = []
            var processItemItemItemReturnValue: Item!
            var processItemItemItemClosure: ((Item) -> Item)?
            func process(item: Item) -> Item {
                processItemItemItemCallsCount += 1
                processItemItemItemReceivedItem = (item)
                processItemItemItemReceivedInvocations.append((item))
                if processItemItemItemClosure != nil {
                    return processItemItemItemClosure!(item)
                } else {
                    return processItemItemItemReturnValue
                }
            }
            var processItemItemStringCallsCount = 0
            var processItemItemStringCalled: Bool {
                return processItemItemStringCallsCount > 0
            }
            var processItemItemStringReceivedItem: Item?
            var processItemItemStringReceivedInvocations: [Item] = []
            var processItemItemStringReturnValue: String!
            var processItemItemStringClosure: ((Item) -> String)?
            func process(item: Item) -> String {
                processItemItemStringCallsCount += 1
                processItemItemStringReceivedItem = (item)
                processItemItemStringReceivedInvocations.append((item))
                if processItemItemStringClosure != nil {
                    return processItemItemStringClosure!(item)
                } else {
                    return processItemItemStringReturnValue
                }
            }
            var processItemsArrayItemCallsCount = 0
            var processItemsArrayItemCalled: Bool {
                return processItemsArrayItemCallsCount > 0
            }
            var processItemsArrayItemReceivedItems: [Item]?
            var processItemsArrayItemReceivedInvocations: [[Item]] = []
            var processItemsArrayItemClosure: (([Item]) -> Void)?
            func process(items: [Item]) {
                processItemsArrayItemCallsCount += 1
                processItemsArrayItemReceivedItems = (items)
                processItemsArrayItemReceivedInvocations.append((items))
                processItemsArrayItemClosure?(items)
            }
            var processItemsArrayItemArrayItemCallsCount = 0
            var processItemsArrayItemArrayItemCalled: Bool {
                return processItemsArrayItemArrayItemCallsCount > 0
            }
            var processItemsArrayItemArrayItemReceivedItems: [Item]?
            var processItemsArrayItemArrayItemReceivedInvocations: [[Item]] = []
            var processItemsArrayItemArrayItemReturnValue: [Item]!
            var processItemsArrayItemArrayItemClosure: (([Item]) -> [Item])?
            func process(items: [Item]) -> [Item] {
                processItemsArrayItemArrayItemCallsCount += 1
                processItemsArrayItemArrayItemReceivedItems = (items)
                processItemsArrayItemArrayItemReceivedInvocations.append((items))
                if processItemsArrayItemArrayItemClosure != nil {
                    return processItemsArrayItemArrayItemClosure!(items)
                } else {
                    return processItemsArrayItemArrayItemReturnValue
                }
            }
            var transformContainerContainerCallsCount = 0
            var transformContainerContainerCalled: Bool {
                return transformContainerContainerCallsCount > 0
            }
            var transformContainerContainerReceivedContainer: Container?
            var transformContainerContainerReceivedInvocations: [Container] = []
            var transformContainerContainerClosure: ((Container) -> Void)?
            func transform(container: Container) {
                transformContainerContainerCallsCount += 1
                transformContainerContainerReceivedContainer = (container)
                transformContainerContainerReceivedInvocations.append((container))
                transformContainerContainerClosure?(container)
            }
            var transformContainerContainerContainerCallsCount = 0
            var transformContainerContainerContainerCalled: Bool {
                return transformContainerContainerContainerCallsCount > 0
            }
            var transformContainerContainerContainerReceivedContainer: Container?
            var transformContainerContainerContainerReceivedInvocations: [Container] = []
            var transformContainerContainerContainerReturnValue: Container!
            var transformContainerContainerContainerClosure: ((Container) -> Container)?
            func transform(container: Container) -> Container {
                transformContainerContainerContainerCallsCount += 1
                transformContainerContainerContainerReceivedContainer = (container)
                transformContainerContainerContainerReceivedInvocations.append((container))
                if transformContainerContainerContainerClosure != nil {
                    return transformContainerContainerContainerClosure!(container)
                } else {
                    return transformContainerContainerContainerReturnValue
                }
            }
            var transformContainerContainerIntCallsCount = 0
            var transformContainerContainerIntCalled: Bool {
                return transformContainerContainerIntCallsCount > 0
            }
            var transformContainerContainerIntReceivedContainer: Container?
            var transformContainerContainerIntReceivedInvocations: [Container] = []
            var transformContainerContainerIntReturnValue: Int!
            var transformContainerContainerIntClosure: ((Container) -> Int)?
            func transform(container: Container) -> Int {
                transformContainerContainerIntCallsCount += 1
                transformContainerContainerIntReceivedContainer = (container)
                transformContainerContainerIntReceivedInvocations.append((container))
                if transformContainerContainerIntClosure != nil {
                    return transformContainerContainerIntClosure!(container)
                } else {
                    return transformContainerContainerIntReturnValue
                }
            }
            var handleItemSelfCallsCount = 0
            var handleItemSelfCalled: Bool {
                return handleItemSelfCallsCount > 0
            }
            var handleItemSelfReceivedItem: Self?
            var handleItemSelfReceivedInvocations: [Self] = []
            var handleItemSelfClosure: ((Self) -> Void)?
            func handle(item: Self) {
                handleItemSelfCallsCount += 1
                handleItemSelfReceivedItem = (item)
                handleItemSelfReceivedInvocations.append((item))
                handleItemSelfClosure?(item)
            }
            var handleItemSelfSelfCallsCount = 0
            var handleItemSelfSelfCalled: Bool {
                return handleItemSelfSelfCallsCount > 0
            }
            var handleItemSelfSelfReceivedItem: Self?
            var handleItemSelfSelfReceivedInvocations: [Self] = []
            var handleItemSelfSelfReturnValue: Self!
            var handleItemSelfSelfClosure: ((Self) -> Self)?
            func handle(item: Self) -> Self {
                handleItemSelfSelfCallsCount += 1
                handleItemSelfSelfReceivedItem = (item)
                handleItemSelfSelfReceivedInvocations.append((item))
                if handleItemSelfSelfClosure != nil {
                    return handleItemSelfSelfClosure!(item)
                } else {
                    return handleItemSelfSelfReturnValue
                }
            }
            var handleItemSelfBoolCallsCount = 0
            var handleItemSelfBoolCalled: Bool {
                return handleItemSelfBoolCallsCount > 0
            }
            var handleItemSelfBoolReceivedItem: Self?
            var handleItemSelfBoolReceivedInvocations: [Self] = []
            var handleItemSelfBoolReturnValue: Bool!
            var handleItemSelfBoolClosure: ((Self) -> Bool)?
            func handle(item: Self) -> Bool {
                handleItemSelfBoolCallsCount += 1
                handleItemSelfBoolReceivedItem = (item)
                handleItemSelfBoolReceivedInvocations.append((item))
                if handleItemSelfBoolClosure != nil {
                    return handleItemSelfBoolClosure!(item)
                } else {
                    return handleItemSelfBoolReturnValue
                }
            }
            var compareFirstItemSecondItemBoolCallsCount = 0
            var compareFirstItemSecondItemBoolCalled: Bool {
                return compareFirstItemSecondItemBoolCallsCount > 0
            }
            var compareFirstItemSecondItemBoolReceivedArguments: (first: Item, second: Item)?
            var compareFirstItemSecondItemBoolReceivedInvocations: [(first: Item, second: Item)] = []
            var compareFirstItemSecondItemBoolReturnValue: Bool!
            var compareFirstItemSecondItemBoolClosure: ((Item, Item) -> Bool)?
            func compare(first: Item, second: Item) -> Bool {
                compareFirstItemSecondItemBoolCallsCount += 1
                compareFirstItemSecondItemBoolReceivedArguments = (first, second)
                compareFirstItemSecondItemBoolReceivedInvocations.append((first, second))
                if compareFirstItemSecondItemBoolClosure != nil {
                    return compareFirstItemSecondItemBoolClosure!(first, second)
                } else {
                    return compareFirstItemSecondItemBoolReturnValue
                }
            }
            var compareFirstItemSecondItemItemCallsCount = 0
            var compareFirstItemSecondItemItemCalled: Bool {
                return compareFirstItemSecondItemItemCallsCount > 0
            }
            var compareFirstItemSecondItemItemReceivedArguments: (first: Item, second: Item)?
            var compareFirstItemSecondItemItemReceivedInvocations: [(first: Item, second: Item)] = []
            var compareFirstItemSecondItemItemReturnValue: Item!
            var compareFirstItemSecondItemItemClosure: ((Item, Item) -> Item)?
            func compare(first: Item, second: Item) -> Item {
                compareFirstItemSecondItemItemCallsCount += 1
                compareFirstItemSecondItemItemReceivedArguments = (first, second)
                compareFirstItemSecondItemItemReceivedInvocations.append((first, second))
                if compareFirstItemSecondItemItemClosure != nil {
                    return compareFirstItemSecondItemItemClosure!(first, second)
                } else {
                    return compareFirstItemSecondItemItemReturnValue
                }
            }
        }
        """,
      macros: sut
    )
  }
  
  func testPolymorphismWithFunctionAttributes() {
    let protocolDeclaration = """
      protocol FunctionAttributesProtocol {
        // @escaping vs non-escaping closures
        func process(handler: () -> Void)
        func process(handler: @escaping () -> Void)
        func process(handler: @escaping () -> Void) -> String
        
        // @Sendable closures  
        func handle(action: () -> Void)
        func handle(action: @Sendable () -> Void)
        
        // @autoclosure parameters
        func evaluate(_ expression: String)
        func evaluate(_ expression: @autoclosure () -> String)
        
        // Mixed scenarios with closures and @escaping/@Sendable
        func transform(converter: (String) -> Int)
        func transform(converter: @escaping (String) -> Int)
        func transform(converter: @Sendable (String) -> Int)
      }
      """

    // Just test that it compiles without syntax errors - the exact output format may vary
    // but we want to ensure function attributes are properly handled in polymorphic scenarios
    assertMacroExpansion(
      """
      @Spyable
      \(protocolDeclaration)
      """,
      expandedSource: """

        \(protocolDeclaration)

        class FunctionAttributesProtocolSpy: FunctionAttributesProtocol, @unchecked Sendable {
            init() {
            }
            var processHandlerVoidCallsCount = 0
            var processHandlerVoidCalled: Bool {
                return processHandlerVoidCallsCount > 0
            }
            var processHandlerVoidClosure: ((() -> Void) -> Void)?
            // @escaping vs non-escaping closures
            func process(handler: () -> Void) {
                processHandlerVoidCallsCount += 1
                processHandlerVoidClosure?(handler)
            }
            var processHandlerescapingVoidCallsCount = 0
            var processHandlerescapingVoidCalled: Bool {
                return processHandlerescapingVoidCallsCount > 0
            }
            var processHandlerescapingVoidReceivedHandler: (() -> Void)?
            var processHandlerescapingVoidReceivedInvocations: [() -> Void] = []
            var processHandlerescapingVoidClosure: ((@escaping () -> Void) -> Void)?
            func process(handler: @escaping () -> Void) {
                processHandlerescapingVoidCallsCount += 1
                processHandlerescapingVoidReceivedHandler = (handler)
                processHandlerescapingVoidReceivedInvocations.append((handler))
                processHandlerescapingVoidClosure?(handler)
            }
            var processHandlerescapingVoidStringCallsCount = 0
            var processHandlerescapingVoidStringCalled: Bool {
                return processHandlerescapingVoidStringCallsCount > 0
            }
            var processHandlerescapingVoidStringReceivedHandler: (() -> Void)?
            var processHandlerescapingVoidStringReceivedInvocations: [() -> Void] = []
            var processHandlerescapingVoidStringReturnValue: String!
            var processHandlerescapingVoidStringClosure: ((@escaping () -> Void) -> String)?
            func process(handler: @escaping () -> Void) -> String {
                processHandlerescapingVoidStringCallsCount += 1
                processHandlerescapingVoidStringReceivedHandler = (handler)
                processHandlerescapingVoidStringReceivedInvocations.append((handler))
                if processHandlerescapingVoidStringClosure != nil {
                    return processHandlerescapingVoidStringClosure!(handler)
                } else {
                    return processHandlerescapingVoidStringReturnValue
                }
            }
            var handleActionVoidCallsCount = 0
            var handleActionVoidCalled: Bool {
                return handleActionVoidCallsCount > 0
            }
            var handleActionVoidClosure: ((() -> Void) -> Void)?

            // @Sendable closures  
            func handle(action: () -> Void) {
                handleActionVoidCallsCount += 1
                handleActionVoidClosure?(action)
            }
            var handleActionSendableVoidCallsCount = 0
            var handleActionSendableVoidCalled: Bool {
                return handleActionSendableVoidCallsCount > 0
            }
            var handleActionSendableVoidClosure: ((@Sendable () -> Void) -> Void)?
            func handle(action: @Sendable () -> Void) {
                handleActionSendableVoidCallsCount += 1
                handleActionSendableVoidClosure?(action)
            }
            var evaluateCallsCount = 0
            var evaluateCalled: Bool {
                return evaluateCallsCount > 0
            }
            var evaluateReceivedExpression: String?
            var evaluateReceivedInvocations: [String] = []
            var evaluateClosure: ((String) -> Void)?

            // @autoclosure parameters
            func evaluate(_ expression: String) {
                evaluateCallsCount += 1
                evaluateReceivedExpression = (expression)
                evaluateReceivedInvocations.append((expression))
                evaluateClosure?(expression)
            }
            var evaluateCallsCount = 0
            var evaluateCalled: Bool {
                return evaluateCallsCount > 0
            }
            var evaluateClosure: ((@autoclosure () -> String) -> Void)?
            func evaluate(_ expression: @autoclosure () -> String) {
                evaluateCallsCount += 1
                evaluateClosure?(expression())
            }
            var transformConverterStringIntCallsCount = 0
            var transformConverterStringIntCalled: Bool {
                return transformConverterStringIntCallsCount > 0
            }
            var transformConverterStringIntClosure: (((String) -> Int) -> Void)?

            // Mixed scenarios with closures and @escaping/@Sendable
            func transform(converter: (String) -> Int) {
                transformConverterStringIntCallsCount += 1
                transformConverterStringIntClosure?(converter)
            }
            var transformConverterescapingStringIntCallsCount = 0
            var transformConverterescapingStringIntCalled: Bool {
                return transformConverterescapingStringIntCallsCount > 0
            }
            var transformConverterescapingStringIntReceivedConverter: ((String) -> Int)?
            var transformConverterescapingStringIntReceivedInvocations: [(String) -> Int] = []
            var transformConverterescapingStringIntClosure: ((@escaping (String) -> Int) -> Void)?
            func transform(converter: @escaping (String) -> Int) {
                transformConverterescapingStringIntCallsCount += 1
                transformConverterescapingStringIntReceivedConverter = (converter)
                transformConverterescapingStringIntReceivedInvocations.append((converter))
                transformConverterescapingStringIntClosure?(converter)
            }
            var transformConverterSendableStringIntCallsCount = 0
            var transformConverterSendableStringIntCalled: Bool {
                return transformConverterSendableStringIntCallsCount > 0
            }
            var transformConverterSendableStringIntClosure: ((@Sendable (String) -> Int) -> Void)?
            func transform(converter: @Sendable (String) -> Int) {
                transformConverterSendableStringIntCallsCount += 1
                transformConverterSendableStringIntClosure?(converter)
            }
        }
        """,
      macros: sut
    )
  }

  func testPolymorphismWithAsyncThrowingCombinations() {
    let protocolDeclaration = """
      protocol AsyncThrowingPolymorphismProtocol {
        // Valid polymorphic functions with different parameter types and async/throwing combinations
        func fetch(immediate: Bool)
        func fetch(from url: String) async
        func fetch(resource id: Int) throws 
        func fetch(withTimeout timeout: Double) async throws
        
        // Functions with return types and different parameter signatures
        func load() -> String
        func load(async priority: Int) async -> String
        func load(throwing validation: Bool) throws -> String
        func load(timeout: TimeInterval) async throws -> String
        
        // Functions with different parameter count and async/throwing combinations
        func process(id: Int)
        func process(id: Int, priority: Int) async
        func process(id: Int, with config: String) throws
        func process(id: Int, priority: Int, timeout: Double) async throws
        func process(id: Int) -> Bool
        func process(id: Int, flag: Bool) async -> Bool
        func process(id: Int, options: [String]) throws -> Bool
        func process(id: Int, flag: Bool, timeout: TimeInterval) async throws -> Bool
      }
      """

    assertMacroExpansion(
      """
      @Spyable
      \(protocolDeclaration)
      """,
      expandedSource: """
        \(protocolDeclaration)

        class AsyncThrowingPolymorphismProtocolSpy: AsyncThrowingPolymorphismProtocol, @unchecked Sendable {
            init() {
            }
            var fetchImmediateCallsCount = 0
            var fetchImmediateCalled: Bool {
                return fetchImmediateCallsCount > 0
            }
            var fetchImmediateReceivedImmediate: Bool?
            var fetchImmediateReceivedInvocations: [Bool] = []
            var fetchImmediateClosure: ((Bool) -> Void)?
            // Valid polymorphic functions with different parameter types and async/throwing combinations
            func fetch(immediate: Bool) {
                fetchImmediateCallsCount += 1
                fetchImmediateReceivedImmediate = (immediate)
                fetchImmediateReceivedInvocations.append((immediate))
                fetchImmediateClosure?(immediate)
            }
            var fetchFromCallsCount = 0
            var fetchFromCalled: Bool {
                return fetchFromCallsCount > 0
            }
            var fetchFromReceivedUrl: String?
            var fetchFromReceivedInvocations: [String] = []
            var fetchFromClosure: ((String) async -> Void)?
            func fetch(from url: String) async {
                fetchFromCallsCount += 1
                fetchFromReceivedUrl = (url)
                fetchFromReceivedInvocations.append((url))
                await fetchFromClosure?(url)
            }
            var fetchResourceCallsCount = 0
            var fetchResourceCalled: Bool {
                return fetchResourceCallsCount > 0
            }
            var fetchResourceReceivedId: Int?
            var fetchResourceReceivedInvocations: [Int] = []
            var fetchResourceThrowableError: (any Error)?
            var fetchResourceClosure: ((Int) throws -> Void)?
            func fetch(resource id: Int) throws {
                fetchResourceCallsCount += 1
                fetchResourceReceivedId = (id)
                fetchResourceReceivedInvocations.append((id))
                if let fetchResourceThrowableError {
                    throw fetchResourceThrowableError
                }
                try fetchResourceClosure?(id)
            }
            var fetchWithTimeoutCallsCount = 0
            var fetchWithTimeoutCalled: Bool {
                return fetchWithTimeoutCallsCount > 0
            }
            var fetchWithTimeoutReceivedTimeout: Double?
            var fetchWithTimeoutReceivedInvocations: [Double] = []
            var fetchWithTimeoutThrowableError: (any Error)?
            var fetchWithTimeoutClosure: ((Double) async throws -> Void)?
            func fetch(withTimeout timeout: Double) async throws {
                fetchWithTimeoutCallsCount += 1
                fetchWithTimeoutReceivedTimeout = (timeout)
                fetchWithTimeoutReceivedInvocations.append((timeout))
                if let fetchWithTimeoutThrowableError {
                    throw fetchWithTimeoutThrowableError
                }
                try await fetchWithTimeoutClosure?(timeout)
            }
            var loadCallsCount = 0
            var loadCalled: Bool {
                return loadCallsCount > 0
            }
            var loadReturnValue: String!
            var loadClosure: (() -> String)?

            // Functions with return types and different parameter signatures
            func load() -> String {
                loadCallsCount += 1
                if loadClosure != nil {
                    return loadClosure!()
                } else {
                    return loadReturnValue
                }
            }
            var loadAsyncCallsCount = 0
            var loadAsyncCalled: Bool {
                return loadAsyncCallsCount > 0
            }
            var loadAsyncReceivedPriority: Int?
            var loadAsyncReceivedInvocations: [Int] = []
            var loadAsyncReturnValue: String!
            var loadAsyncClosure: ((Int) async -> String)?
            func load(async priority: Int) async -> String {
                loadAsyncCallsCount += 1
                loadAsyncReceivedPriority = (priority)
                loadAsyncReceivedInvocations.append((priority))
                if loadAsyncClosure != nil {
                    return await loadAsyncClosure!(priority)
                } else {
                    return loadAsyncReturnValue
                }
            }
            var loadThrowingCallsCount = 0
            var loadThrowingCalled: Bool {
                return loadThrowingCallsCount > 0
            }
            var loadThrowingReceivedValidation: Bool?
            var loadThrowingReceivedInvocations: [Bool] = []
            var loadThrowingThrowableError: (any Error)?
            var loadThrowingReturnValue: String!
            var loadThrowingClosure: ((Bool) throws -> String)?
            func load(throwing validation: Bool) throws -> String {
                loadThrowingCallsCount += 1
                loadThrowingReceivedValidation = (validation)
                loadThrowingReceivedInvocations.append((validation))
                if let loadThrowingThrowableError {
                    throw loadThrowingThrowableError
                }
                if loadThrowingClosure != nil {
                    return try loadThrowingClosure!(validation)
                } else {
                    return loadThrowingReturnValue
                }
            }
            var loadTimeoutCallsCount = 0
            var loadTimeoutCalled: Bool {
                return loadTimeoutCallsCount > 0
            }
            var loadTimeoutReceivedTimeout: TimeInterval?
            var loadTimeoutReceivedInvocations: [TimeInterval] = []
            var loadTimeoutThrowableError: (any Error)?
            var loadTimeoutReturnValue: String!
            var loadTimeoutClosure: ((TimeInterval) async throws -> String)?
            func load(timeout: TimeInterval) async throws -> String {
                loadTimeoutCallsCount += 1
                loadTimeoutReceivedTimeout = (timeout)
                loadTimeoutReceivedInvocations.append((timeout))
                if let loadTimeoutThrowableError {
                    throw loadTimeoutThrowableError
                }
                if loadTimeoutClosure != nil {
                    return try await loadTimeoutClosure!(timeout)
                } else {
                    return loadTimeoutReturnValue
                }
            }
            var processIdIntCallsCount = 0
            var processIdIntCalled: Bool {
                return processIdIntCallsCount > 0
            }
            var processIdIntReceivedId: Int?
            var processIdIntReceivedInvocations: [Int] = []
            var processIdIntClosure: ((Int) -> Void)?

            // Functions with different parameter count and async/throwing combinations
            func process(id: Int) {
                processIdIntCallsCount += 1
                processIdIntReceivedId = (id)
                processIdIntReceivedInvocations.append((id))
                processIdIntClosure?(id)
            }
            var processIdPriorityCallsCount = 0
            var processIdPriorityCalled: Bool {
                return processIdPriorityCallsCount > 0
            }
            var processIdPriorityReceivedArguments: (id: Int, priority: Int)?
            var processIdPriorityReceivedInvocations: [(id: Int, priority: Int)] = []
            var processIdPriorityClosure: ((Int, Int) async -> Void)?
            func process(id: Int, priority: Int) async {
                processIdPriorityCallsCount += 1
                processIdPriorityReceivedArguments = (id, priority)
                processIdPriorityReceivedInvocations.append((id, priority))
                await processIdPriorityClosure?(id, priority)
            }
            var processIdWithCallsCount = 0
            var processIdWithCalled: Bool {
                return processIdWithCallsCount > 0
            }
            var processIdWithReceivedArguments: (id: Int, config: String)?
            var processIdWithReceivedInvocations: [(id: Int, config: String)] = []
            var processIdWithThrowableError: (any Error)?
            var processIdWithClosure: ((Int, String) throws -> Void)?
            func process(id: Int, with config: String) throws {
                processIdWithCallsCount += 1
                processIdWithReceivedArguments = (id, config)
                processIdWithReceivedInvocations.append((id, config))
                if let processIdWithThrowableError {
                    throw processIdWithThrowableError
                }
                try processIdWithClosure?(id, config)
            }
            var processIdPriorityTimeoutCallsCount = 0
            var processIdPriorityTimeoutCalled: Bool {
                return processIdPriorityTimeoutCallsCount > 0
            }
            var processIdPriorityTimeoutReceivedArguments: (id: Int, priority: Int, timeout: Double)?
            var processIdPriorityTimeoutReceivedInvocations: [(id: Int, priority: Int, timeout: Double)] = []
            var processIdPriorityTimeoutThrowableError: (any Error)?
            var processIdPriorityTimeoutClosure: ((Int, Int, Double) async throws -> Void)?
            func process(id: Int, priority: Int, timeout: Double) async throws {
                processIdPriorityTimeoutCallsCount += 1
                processIdPriorityTimeoutReceivedArguments = (id, priority, timeout)
                processIdPriorityTimeoutReceivedInvocations.append((id, priority, timeout))
                if let processIdPriorityTimeoutThrowableError {
                    throw processIdPriorityTimeoutThrowableError
                }
                try await processIdPriorityTimeoutClosure?(id, priority, timeout)
            }
            var processIdIntBoolCallsCount = 0
            var processIdIntBoolCalled: Bool {
                return processIdIntBoolCallsCount > 0
            }
            var processIdIntBoolReceivedId: Int?
            var processIdIntBoolReceivedInvocations: [Int] = []
            var processIdIntBoolReturnValue: Bool!
            var processIdIntBoolClosure: ((Int) -> Bool)?
            func process(id: Int) -> Bool {
                processIdIntBoolCallsCount += 1
                processIdIntBoolReceivedId = (id)
                processIdIntBoolReceivedInvocations.append((id))
                if processIdIntBoolClosure != nil {
                    return processIdIntBoolClosure!(id)
                } else {
                    return processIdIntBoolReturnValue
                }
            }
            var processIdFlagCallsCount = 0
            var processIdFlagCalled: Bool {
                return processIdFlagCallsCount > 0
            }
            var processIdFlagReceivedArguments: (id: Int, flag: Bool)?
            var processIdFlagReceivedInvocations: [(id: Int, flag: Bool)] = []
            var processIdFlagReturnValue: Bool!
            var processIdFlagClosure: ((Int, Bool) async -> Bool)?
            func process(id: Int, flag: Bool) async -> Bool {
                processIdFlagCallsCount += 1
                processIdFlagReceivedArguments = (id, flag)
                processIdFlagReceivedInvocations.append((id, flag))
                if processIdFlagClosure != nil {
                    return await processIdFlagClosure!(id, flag)
                } else {
                    return processIdFlagReturnValue
                }
            }
            var processIdOptionsCallsCount = 0
            var processIdOptionsCalled: Bool {
                return processIdOptionsCallsCount > 0
            }
            var processIdOptionsReceivedArguments: (id: Int, options: [String])?
            var processIdOptionsReceivedInvocations: [(id: Int, options: [String])] = []
            var processIdOptionsThrowableError: (any Error)?
            var processIdOptionsReturnValue: Bool!
            var processIdOptionsClosure: ((Int, [String]) throws -> Bool)?
            func process(id: Int, options: [String]) throws -> Bool {
                processIdOptionsCallsCount += 1
                processIdOptionsReceivedArguments = (id, options)
                processIdOptionsReceivedInvocations.append((id, options))
                if let processIdOptionsThrowableError {
                    throw processIdOptionsThrowableError
                }
                if processIdOptionsClosure != nil {
                    return try processIdOptionsClosure!(id, options)
                } else {
                    return processIdOptionsReturnValue
                }
            }
            var processIdFlagTimeoutCallsCount = 0
            var processIdFlagTimeoutCalled: Bool {
                return processIdFlagTimeoutCallsCount > 0
            }
            var processIdFlagTimeoutReceivedArguments: (id: Int, flag: Bool, timeout: TimeInterval)?
            var processIdFlagTimeoutReceivedInvocations: [(id: Int, flag: Bool, timeout: TimeInterval)] = []
            var processIdFlagTimeoutThrowableError: (any Error)?
            var processIdFlagTimeoutReturnValue: Bool!
            var processIdFlagTimeoutClosure: ((Int, Bool, TimeInterval) async throws -> Bool)?
            func process(id: Int, flag: Bool, timeout: TimeInterval) async throws -> Bool {
                processIdFlagTimeoutCallsCount += 1
                processIdFlagTimeoutReceivedArguments = (id, flag, timeout)
                processIdFlagTimeoutReceivedInvocations.append((id, flag, timeout))
                if let processIdFlagTimeoutThrowableError {
                    throw processIdFlagTimeoutThrowableError
                }
                if processIdFlagTimeoutClosure != nil {
                    return try await processIdFlagTimeoutClosure!(id, flag, timeout)
                } else {
                    return processIdFlagTimeoutReturnValue
                }
            }
        }
        """,
      macros: sut
    )
  }

  func testPolymorphismWithInoutParameters() {
    let protocolDeclaration = """
      protocol InoutParametersProtocol {
        func update(value: inout Int)
        func update(value: Int)
        func update(value: inout String)
        func update(value: inout Int, flag: Bool)
        func update(value: Int, flag: Bool)
        func process(data: inout Data) -> Bool
        func process(data: Data) -> Bool
        func process(data: inout Data) -> String
        func swap(first: inout Int, second: inout Int)
        func swap(first: inout String, second: inout String)
        func swap(first: inout Int, second: inout Int, third: inout Int)
        func transform(input: inout String, options: [String: Any]) -> Int
        func transform(input: String, options: [String: Any]) -> Int
        func transform(input: inout String, options: [String: Any]) -> String
        func transform(input: inout String, options: inout [String: Any]) -> String
        func configure(settings: inout [String: Any]) async throws
        func configure(settings: [String: Any]) async throws
        func configure(settings: inout [String: Any]) throws -> Bool
        func configure(settings: [String: Any]) throws -> Bool
      }
      """

    assertMacroExpansion(
      """
      @Spyable
      \(protocolDeclaration)
      """,
      expandedSource: """

        \(protocolDeclaration)

        class InoutParametersProtocolSpy: InoutParametersProtocol, @unchecked Sendable {
            init() {
            }
            var updateValueinoutIntCallsCount = 0
            var updateValueinoutIntCalled: Bool {
                return updateValueinoutIntCallsCount > 0
            }
            var updateValueinoutIntReceivedValue: Int?
            var updateValueinoutIntReceivedInvocations: [Int] = []
            var updateValueinoutIntClosure: ((inout Int) -> Void)?
            func update(value: inout Int) {
                updateValueinoutIntCallsCount += 1
                updateValueinoutIntReceivedValue = (value)
                updateValueinoutIntReceivedInvocations.append((value))
                updateValueinoutIntClosure?(&value)
            }
            var updateValueIntCallsCount = 0
            var updateValueIntCalled: Bool {
                return updateValueIntCallsCount > 0
            }
            var updateValueIntReceivedValue: Int?
            var updateValueIntReceivedInvocations: [Int] = []
            var updateValueIntClosure: ((Int) -> Void)?
            func update(value: Int) {
                updateValueIntCallsCount += 1
                updateValueIntReceivedValue = (value)
                updateValueIntReceivedInvocations.append((value))
                updateValueIntClosure?(value)
            }
            var updateValueinoutStringCallsCount = 0
            var updateValueinoutStringCalled: Bool {
                return updateValueinoutStringCallsCount > 0
            }
            var updateValueinoutStringReceivedValue: String?
            var updateValueinoutStringReceivedInvocations: [String] = []
            var updateValueinoutStringClosure: ((inout String) -> Void)?
            func update(value: inout String) {
                updateValueinoutStringCallsCount += 1
                updateValueinoutStringReceivedValue = (value)
                updateValueinoutStringReceivedInvocations.append((value))
                updateValueinoutStringClosure?(&value)
            }
            var updateValueinoutIntFlagBoolCallsCount = 0
            var updateValueinoutIntFlagBoolCalled: Bool {
                return updateValueinoutIntFlagBoolCallsCount > 0
            }
            var updateValueinoutIntFlagBoolReceivedArguments: (value: Int, flag: Bool)?
            var updateValueinoutIntFlagBoolReceivedInvocations: [(value: Int, flag: Bool)] = []
            var updateValueinoutIntFlagBoolClosure: ((inout Int, Bool) -> Void)?
            func update(value: inout Int, flag: Bool) {
                updateValueinoutIntFlagBoolCallsCount += 1
                updateValueinoutIntFlagBoolReceivedArguments = (value, flag)
                updateValueinoutIntFlagBoolReceivedInvocations.append((value, flag))
                updateValueinoutIntFlagBoolClosure?(&value, flag)
            }
            var updateValueIntFlagBoolCallsCount = 0
            var updateValueIntFlagBoolCalled: Bool {
                return updateValueIntFlagBoolCallsCount > 0
            }
            var updateValueIntFlagBoolReceivedArguments: (value: Int, flag: Bool)?
            var updateValueIntFlagBoolReceivedInvocations: [(value: Int, flag: Bool)] = []
            var updateValueIntFlagBoolClosure: ((Int, Bool) -> Void)?
            func update(value: Int, flag: Bool) {
                updateValueIntFlagBoolCallsCount += 1
                updateValueIntFlagBoolReceivedArguments = (value, flag)
                updateValueIntFlagBoolReceivedInvocations.append((value, flag))
                updateValueIntFlagBoolClosure?(value, flag)
            }
            var processDatainoutDataBoolCallsCount = 0
            var processDatainoutDataBoolCalled: Bool {
                return processDatainoutDataBoolCallsCount > 0
            }
            var processDatainoutDataBoolReceivedData: Data?
            var processDatainoutDataBoolReceivedInvocations: [Data] = []
            var processDatainoutDataBoolReturnValue: Bool!
            var processDatainoutDataBoolClosure: ((inout Data) -> Bool)?
            func process(data: inout Data) -> Bool {
                processDatainoutDataBoolCallsCount += 1
                processDatainoutDataBoolReceivedData = (data)
                processDatainoutDataBoolReceivedInvocations.append((data))
                if processDatainoutDataBoolClosure != nil {
                    return processDatainoutDataBoolClosure!(&data)
                } else {
                    return processDatainoutDataBoolReturnValue
                }
            }
            var processDataDataBoolCallsCount = 0
            var processDataDataBoolCalled: Bool {
                return processDataDataBoolCallsCount > 0
            }
            var processDataDataBoolReceivedData: Data?
            var processDataDataBoolReceivedInvocations: [Data] = []
            var processDataDataBoolReturnValue: Bool!
            var processDataDataBoolClosure: ((Data) -> Bool)?
            func process(data: Data) -> Bool {
                processDataDataBoolCallsCount += 1
                processDataDataBoolReceivedData = (data)
                processDataDataBoolReceivedInvocations.append((data))
                if processDataDataBoolClosure != nil {
                    return processDataDataBoolClosure!(data)
                } else {
                    return processDataDataBoolReturnValue
                }
            }
            var processDatainoutDataStringCallsCount = 0
            var processDatainoutDataStringCalled: Bool {
                return processDatainoutDataStringCallsCount > 0
            }
            var processDatainoutDataStringReceivedData: Data?
            var processDatainoutDataStringReceivedInvocations: [Data] = []
            var processDatainoutDataStringReturnValue: String!
            var processDatainoutDataStringClosure: ((inout Data) -> String)?
            func process(data: inout Data) -> String {
                processDatainoutDataStringCallsCount += 1
                processDatainoutDataStringReceivedData = (data)
                processDatainoutDataStringReceivedInvocations.append((data))
                if processDatainoutDataStringClosure != nil {
                    return processDatainoutDataStringClosure!(&data)
                } else {
                    return processDatainoutDataStringReturnValue
                }
            }
            var swapFirstinoutIntSecondinoutIntCallsCount = 0
            var swapFirstinoutIntSecondinoutIntCalled: Bool {
                return swapFirstinoutIntSecondinoutIntCallsCount > 0
            }
            var swapFirstinoutIntSecondinoutIntReceivedArguments: (first: Int, second: Int)?
            var swapFirstinoutIntSecondinoutIntReceivedInvocations: [(first: Int, second: Int)] = []
            var swapFirstinoutIntSecondinoutIntClosure: ((inout Int, inout Int) -> Void)?
            func swap(first: inout Int, second: inout Int) {
                swapFirstinoutIntSecondinoutIntCallsCount += 1
                swapFirstinoutIntSecondinoutIntReceivedArguments = (first, second)
                swapFirstinoutIntSecondinoutIntReceivedInvocations.append((first, second))
                swapFirstinoutIntSecondinoutIntClosure?(&first, &second)
            }
            var swapFirstinoutStringSecondinoutStringCallsCount = 0
            var swapFirstinoutStringSecondinoutStringCalled: Bool {
                return swapFirstinoutStringSecondinoutStringCallsCount > 0
            }
            var swapFirstinoutStringSecondinoutStringReceivedArguments: (first: String, second: String)?
            var swapFirstinoutStringSecondinoutStringReceivedInvocations: [(first: String, second: String)] = []
            var swapFirstinoutStringSecondinoutStringClosure: ((inout String, inout String) -> Void)?
            func swap(first: inout String, second: inout String) {
                swapFirstinoutStringSecondinoutStringCallsCount += 1
                swapFirstinoutStringSecondinoutStringReceivedArguments = (first, second)
                swapFirstinoutStringSecondinoutStringReceivedInvocations.append((first, second))
                swapFirstinoutStringSecondinoutStringClosure?(&first, &second)
            }
            var swapFirstSecondThirdCallsCount = 0
            var swapFirstSecondThirdCalled: Bool {
                return swapFirstSecondThirdCallsCount > 0
            }
            var swapFirstSecondThirdReceivedArguments: (first: Int, second: Int, third: Int)?
            var swapFirstSecondThirdReceivedInvocations: [(first: Int, second: Int, third: Int)] = []
            var swapFirstSecondThirdClosure: ((inout Int, inout Int, inout Int) -> Void)?
            func swap(first: inout Int, second: inout Int, third: inout Int) {
                swapFirstSecondThirdCallsCount += 1
                swapFirstSecondThirdReceivedArguments = (first, second, third)
                swapFirstSecondThirdReceivedInvocations.append((first, second, third))
                swapFirstSecondThirdClosure?(&first, &second, &third)
            }
            var transformInputinoutStringOptionsDictionaryStringAnyIntCallsCount = 0
            var transformInputinoutStringOptionsDictionaryStringAnyIntCalled: Bool {
                return transformInputinoutStringOptionsDictionaryStringAnyIntCallsCount > 0
            }
            var transformInputinoutStringOptionsDictionaryStringAnyIntReceivedArguments: (input: String, options: [String: Any])?
            var transformInputinoutStringOptionsDictionaryStringAnyIntReceivedInvocations: [(input: String, options: [String: Any])] = []
            var transformInputinoutStringOptionsDictionaryStringAnyIntReturnValue: Int!
            var transformInputinoutStringOptionsDictionaryStringAnyIntClosure: ((inout String, [String: Any]) -> Int)?
            func transform(input: inout String, options: [String: Any]) -> Int {
                transformInputinoutStringOptionsDictionaryStringAnyIntCallsCount += 1
                transformInputinoutStringOptionsDictionaryStringAnyIntReceivedArguments = (input, options)
                transformInputinoutStringOptionsDictionaryStringAnyIntReceivedInvocations.append((input, options))
                if transformInputinoutStringOptionsDictionaryStringAnyIntClosure != nil {
                    return transformInputinoutStringOptionsDictionaryStringAnyIntClosure!(&input, options)
                } else {
                    return transformInputinoutStringOptionsDictionaryStringAnyIntReturnValue
                }
            }
            var transformInputStringOptionsDictionaryStringAnyIntCallsCount = 0
            var transformInputStringOptionsDictionaryStringAnyIntCalled: Bool {
                return transformInputStringOptionsDictionaryStringAnyIntCallsCount > 0
            }
            var transformInputStringOptionsDictionaryStringAnyIntReceivedArguments: (input: String, options: [String: Any])?
            var transformInputStringOptionsDictionaryStringAnyIntReceivedInvocations: [(input: String, options: [String: Any])] = []
            var transformInputStringOptionsDictionaryStringAnyIntReturnValue: Int!
            var transformInputStringOptionsDictionaryStringAnyIntClosure: ((String, [String: Any]) -> Int)?
            func transform(input: String, options: [String: Any]) -> Int {
                transformInputStringOptionsDictionaryStringAnyIntCallsCount += 1
                transformInputStringOptionsDictionaryStringAnyIntReceivedArguments = (input, options)
                transformInputStringOptionsDictionaryStringAnyIntReceivedInvocations.append((input, options))
                if transformInputStringOptionsDictionaryStringAnyIntClosure != nil {
                    return transformInputStringOptionsDictionaryStringAnyIntClosure!(input, options)
                } else {
                    return transformInputStringOptionsDictionaryStringAnyIntReturnValue
                }
            }
            var transformInputinoutStringOptionsDictionaryStringAnyStringCallsCount = 0
            var transformInputinoutStringOptionsDictionaryStringAnyStringCalled: Bool {
                return transformInputinoutStringOptionsDictionaryStringAnyStringCallsCount > 0
            }
            var transformInputinoutStringOptionsDictionaryStringAnyStringReceivedArguments: (input: String, options: [String: Any])?
            var transformInputinoutStringOptionsDictionaryStringAnyStringReceivedInvocations: [(input: String, options: [String: Any])] = []
            var transformInputinoutStringOptionsDictionaryStringAnyStringReturnValue: String!
            var transformInputinoutStringOptionsDictionaryStringAnyStringClosure: ((inout String, [String: Any]) -> String)?
            func transform(input: inout String, options: [String: Any]) -> String {
                transformInputinoutStringOptionsDictionaryStringAnyStringCallsCount += 1
                transformInputinoutStringOptionsDictionaryStringAnyStringReceivedArguments = (input, options)
                transformInputinoutStringOptionsDictionaryStringAnyStringReceivedInvocations.append((input, options))
                if transformInputinoutStringOptionsDictionaryStringAnyStringClosure != nil {
                    return transformInputinoutStringOptionsDictionaryStringAnyStringClosure!(&input, options)
                } else {
                    return transformInputinoutStringOptionsDictionaryStringAnyStringReturnValue
                }
            }
            var transformInputinoutStringOptionsinoutDictionaryStringAnyStringCallsCount = 0
            var transformInputinoutStringOptionsinoutDictionaryStringAnyStringCalled: Bool {
                return transformInputinoutStringOptionsinoutDictionaryStringAnyStringCallsCount > 0
            }
            var transformInputinoutStringOptionsinoutDictionaryStringAnyStringReceivedArguments: (input: String, options: [String: Any])?
            var transformInputinoutStringOptionsinoutDictionaryStringAnyStringReceivedInvocations: [(input: String, options: [String: Any])] = []
            var transformInputinoutStringOptionsinoutDictionaryStringAnyStringReturnValue: String!
            var transformInputinoutStringOptionsinoutDictionaryStringAnyStringClosure: ((inout String, inout [String: Any]) -> String)?
            func transform(input: inout String, options: inout [String: Any]) -> String {
                transformInputinoutStringOptionsinoutDictionaryStringAnyStringCallsCount += 1
                transformInputinoutStringOptionsinoutDictionaryStringAnyStringReceivedArguments = (input, options)
                transformInputinoutStringOptionsinoutDictionaryStringAnyStringReceivedInvocations.append((input, options))
                if transformInputinoutStringOptionsinoutDictionaryStringAnyStringClosure != nil {
                    return transformInputinoutStringOptionsinoutDictionaryStringAnyStringClosure!(&input, &options)
                } else {
                    return transformInputinoutStringOptionsinoutDictionaryStringAnyStringReturnValue
                }
            }
            var configureSettingsinoutDictionaryStringAnyCallsCount = 0
            var configureSettingsinoutDictionaryStringAnyCalled: Bool {
                return configureSettingsinoutDictionaryStringAnyCallsCount > 0
            }
            var configureSettingsinoutDictionaryStringAnyReceivedSettings: [String: Any]?
            var configureSettingsinoutDictionaryStringAnyReceivedInvocations: [[String: Any]] = []
            var configureSettingsinoutDictionaryStringAnyThrowableError: (any Error)?
            var configureSettingsinoutDictionaryStringAnyClosure: ((inout [String: Any]) async throws -> Void)?
            func configure(settings: inout [String: Any]) async throws {
                configureSettingsinoutDictionaryStringAnyCallsCount += 1
                configureSettingsinoutDictionaryStringAnyReceivedSettings = (settings)
                configureSettingsinoutDictionaryStringAnyReceivedInvocations.append((settings))
                if let configureSettingsinoutDictionaryStringAnyThrowableError {
                    throw configureSettingsinoutDictionaryStringAnyThrowableError
                }
                try await configureSettingsinoutDictionaryStringAnyClosure?(&settings)
            }
            var configureSettingsDictionaryStringAnyCallsCount = 0
            var configureSettingsDictionaryStringAnyCalled: Bool {
                return configureSettingsDictionaryStringAnyCallsCount > 0
            }
            var configureSettingsDictionaryStringAnyReceivedSettings: [String: Any]?
            var configureSettingsDictionaryStringAnyReceivedInvocations: [[String: Any]] = []
            var configureSettingsDictionaryStringAnyThrowableError: (any Error)?
            var configureSettingsDictionaryStringAnyClosure: (([String: Any]) async throws -> Void)?
            func configure(settings: [String: Any]) async throws {
                configureSettingsDictionaryStringAnyCallsCount += 1
                configureSettingsDictionaryStringAnyReceivedSettings = (settings)
                configureSettingsDictionaryStringAnyReceivedInvocations.append((settings))
                if let configureSettingsDictionaryStringAnyThrowableError {
                    throw configureSettingsDictionaryStringAnyThrowableError
                }
                try await configureSettingsDictionaryStringAnyClosure?(settings)
            }
            var configureSettingsinoutDictionaryStringAnyBoolCallsCount = 0
            var configureSettingsinoutDictionaryStringAnyBoolCalled: Bool {
                return configureSettingsinoutDictionaryStringAnyBoolCallsCount > 0
            }
            var configureSettingsinoutDictionaryStringAnyBoolReceivedSettings: [String: Any]?
            var configureSettingsinoutDictionaryStringAnyBoolReceivedInvocations: [[String: Any]] = []
            var configureSettingsinoutDictionaryStringAnyBoolThrowableError: (any Error)?
            var configureSettingsinoutDictionaryStringAnyBoolReturnValue: Bool!
            var configureSettingsinoutDictionaryStringAnyBoolClosure: ((inout [String: Any]) throws -> Bool)?
            func configure(settings: inout [String: Any]) throws -> Bool {
                configureSettingsinoutDictionaryStringAnyBoolCallsCount += 1
                configureSettingsinoutDictionaryStringAnyBoolReceivedSettings = (settings)
                configureSettingsinoutDictionaryStringAnyBoolReceivedInvocations.append((settings))
                if let configureSettingsinoutDictionaryStringAnyBoolThrowableError {
                    throw configureSettingsinoutDictionaryStringAnyBoolThrowableError
                }
                if configureSettingsinoutDictionaryStringAnyBoolClosure != nil {
                    return try configureSettingsinoutDictionaryStringAnyBoolClosure!(&settings)
                } else {
                    return configureSettingsinoutDictionaryStringAnyBoolReturnValue
                }
            }
            var configureSettingsDictionaryStringAnyBoolCallsCount = 0
            var configureSettingsDictionaryStringAnyBoolCalled: Bool {
                return configureSettingsDictionaryStringAnyBoolCallsCount > 0
            }
            var configureSettingsDictionaryStringAnyBoolReceivedSettings: [String: Any]?
            var configureSettingsDictionaryStringAnyBoolReceivedInvocations: [[String: Any]] = []
            var configureSettingsDictionaryStringAnyBoolThrowableError: (any Error)?
            var configureSettingsDictionaryStringAnyBoolReturnValue: Bool!
            var configureSettingsDictionaryStringAnyBoolClosure: (([String: Any]) throws -> Bool)?
            func configure(settings: [String: Any]) throws -> Bool {
                configureSettingsDictionaryStringAnyBoolCallsCount += 1
                configureSettingsDictionaryStringAnyBoolReceivedSettings = (settings)
                configureSettingsDictionaryStringAnyBoolReceivedInvocations.append((settings))
                if let configureSettingsDictionaryStringAnyBoolThrowableError {
                    throw configureSettingsDictionaryStringAnyBoolThrowableError
                }
                if configureSettingsDictionaryStringAnyBoolClosure != nil {
                    return try configureSettingsDictionaryStringAnyBoolClosure!(settings)
                } else {
                    return configureSettingsDictionaryStringAnyBoolReturnValue
                }
            }
        }
        """,
      macros: sut
    )
  }
}
