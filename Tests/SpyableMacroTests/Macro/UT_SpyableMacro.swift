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
  
  func testPolymorphism() {
    let protocolDeclaration = """
      protocol VariablePrefixTestProtocol {
        func doSomething()
        func doSomething() -> Int
        func doSomething() -> String?
        func doSomething() -> [String]
        func doSomething() -> Set<Int>
        func doSomething() -> Set<Int?>
        func doSomething() -> Set<Int>?
        func doSomething() -> Set<Int?>?
        func doSomething() -> [String: Int]
        func doSomething() -> (Int, Int)

        func compute(value: Int)
        func compute(for id: String)
        func compute(for ids: Set<String>) -> [String]
        func compute(value: Int) -> Bool
        func compute(value: Int) -> Double?
        func compute(value: Int) -> [Int]
        func compute(value: Int) -> Set<String>
        func compute(value: Int) -> Set<String?>
        func compute(value: Int) -> Set<String>?
        func compute(value: Int) -> Set<String?>?
        func compute(value: Int) -> [Int: String]
        func compute(value: Int) -> (String, Bool)
        func compute(value: String) -> Bool
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

        class VariablePrefixTestProtocolSpy: VariablePrefixTestProtocol, @unchecked Sendable {
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
            var doSomethingStringCallsCount = 0
            var doSomethingStringCalled: Bool {
                return doSomethingStringCallsCount > 0
            }
            var doSomethingStringReturnValue: [String]!
            var doSomethingStringClosure: (() -> [String])?
            func doSomething() -> [String] {
                doSomethingStringCallsCount += 1
                if doSomethingStringClosure != nil {
                    return doSomethingStringClosure!()
                } else {
                    return doSomethingStringReturnValue
                }
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
            var doSomethingStringIntCallsCount = 0
            var doSomethingStringIntCalled: Bool {
                return doSomethingStringIntCallsCount > 0
            }
            var doSomethingStringIntReturnValue: [String: Int]!
            var doSomethingStringIntClosure: (() -> [String: Int])?
            func doSomething() -> [String: Int] {
                doSomethingStringIntCallsCount += 1
                if doSomethingStringIntClosure != nil {
                    return doSomethingStringIntClosure!()
                } else {
                    return doSomethingStringIntReturnValue
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
            var computeForSetStringStringCallsCount = 0
            var computeForSetStringStringCalled: Bool {
                return computeForSetStringStringCallsCount > 0
            }
            var computeForSetStringStringReceivedIds: Set<String>?
            var computeForSetStringStringReceivedInvocations: [Set<String>] = []
            var computeForSetStringStringReturnValue: [String]!
            var computeForSetStringStringClosure: ((Set<String>) -> [String])?
            func compute(for ids: Set<String>) -> [String] {
                computeForSetStringStringCallsCount += 1
                computeForSetStringStringReceivedIds = (ids)
                computeForSetStringStringReceivedInvocations.append((ids))
                if computeForSetStringStringClosure != nil {
                    return computeForSetStringStringClosure!(ids)
                } else {
                    return computeForSetStringStringReturnValue
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
            var computeValueIntIntCallsCount = 0
            var computeValueIntIntCalled: Bool {
                return computeValueIntIntCallsCount > 0
            }
            var computeValueIntIntReceivedValue: Int?
            var computeValueIntIntReceivedInvocations: [Int] = []
            var computeValueIntIntReturnValue: [Int]!
            var computeValueIntIntClosure: ((Int) -> [Int])?
            func compute(value: Int) -> [Int] {
                computeValueIntIntCallsCount += 1
                computeValueIntIntReceivedValue = (value)
                computeValueIntIntReceivedInvocations.append((value))
                if computeValueIntIntClosure != nil {
                    return computeValueIntIntClosure!(value)
                } else {
                    return computeValueIntIntReturnValue
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
            var computeValueIntIntStringCallsCount = 0
            var computeValueIntIntStringCalled: Bool {
                return computeValueIntIntStringCallsCount > 0
            }
            var computeValueIntIntStringReceivedValue: Int?
            var computeValueIntIntStringReceivedInvocations: [Int] = []
            var computeValueIntIntStringReturnValue: [Int: String]!
            var computeValueIntIntStringClosure: ((Int) -> [Int: String])?
            func compute(value: Int) -> [Int: String] {
                computeValueIntIntStringCallsCount += 1
                computeValueIntIntStringReceivedValue = (value)
                computeValueIntIntStringReceivedInvocations.append((value))
                if computeValueIntIntStringClosure != nil {
                    return computeValueIntIntStringClosure!(value)
                } else {
                    return computeValueIntIntStringReturnValue
                }
            }
            var computeValueIntStringBoolCallsCount = 0
            var computeValueIntStringBoolCalled: Bool {
                return computeValueIntStringBoolCallsCount > 0
            }
            var computeValueIntStringBoolReceivedValue: Int?
            var computeValueIntStringBoolReceivedInvocations: [Int] = []
            var computeValueIntStringBoolReturnValue: (String, Bool)!
            var computeValueIntStringBoolClosure: ((Int) -> (String, Bool))?
            func compute(value: Int) -> (String, Bool) {
                computeValueIntStringBoolCallsCount += 1
                computeValueIntStringBoolReceivedValue = (value)
                computeValueIntStringBoolReceivedInvocations.append((value))
                if computeValueIntStringBoolClosure != nil {
                    return computeValueIntStringBoolClosure!(value)
                } else {
                    return computeValueIntStringBoolReturnValue
                }
            }
            var computeValueStringBoolCallsCount = 0
            var computeValueStringBoolCalled: Bool {
                return computeValueStringBoolCallsCount > 0
            }
            var computeValueStringBoolReceivedValue: String?
            var computeValueStringBoolReceivedInvocations: [String] = []
            var computeValueStringBoolReturnValue: Bool!
            var computeValueStringBoolClosure: ((String) -> Bool)?
            func compute(value: String) -> Bool {
                computeValueStringBoolCallsCount += 1
                computeValueStringBoolReceivedValue = (value)
                computeValueStringBoolReceivedInvocations.append((value))
                if computeValueStringBoolClosure != nil {
                    return computeValueStringBoolClosure!(value)
                } else {
                    return computeValueStringBoolReturnValue
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
}
