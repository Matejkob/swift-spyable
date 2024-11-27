import SwiftSyntax
import SwiftSyntaxBuilder
import XCTest

@testable import SpyableMacro

final class UT_SpyFactory: XCTestCase {
  func testDeclarationEmptyProtocol() throws {
    try assertProtocol(
      withDeclaration: "protocol Foo {}",
      expectingClassDeclaration: """
        class FooSpy: Foo {
        }
        """
    )
  }

  func testDeclaration() throws {
    try assertProtocol(
      withDeclaration: """
        protocol Service {
            func fetch()
        }
        """,
      expectingClassDeclaration: """
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
    try assertProtocol(
      withDeclaration: """
        protocol ViewModelProtocol {
            func foo(text: String, count: Int)
        }
        """,
      expectingClassDeclaration: """
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

  func testDeclarationExistentialTypeArguments() throws {
    try assertProtocol(
      withDeclaration: """
        protocol ViewModelProtocol {
            func foo(model: any ModelProtocol)
        }
        """,
      expectingClassDeclaration: """
        class ViewModelProtocolSpy: ViewModelProtocol {
            var fooModelCallsCount = 0
            var fooModelCalled: Bool {
                return fooModelCallsCount > 0
            }
            var fooModelReceivedModel: (any ModelProtocol)?
            var fooModelReceivedInvocations: [any ModelProtocol] = []
            var fooModelClosure: ((any ModelProtocol) -> Void)?
            func foo(model: any ModelProtocol) {
                fooModelCallsCount += 1
                fooModelReceivedModel = (model)
                fooModelReceivedInvocations.append((model))
                fooModelClosure?(model)
            }
        }
        """
    )
  }

  func testDeclarationOptionalExistentialTypeArguments() throws {
    try assertProtocol(
      withDeclaration: """
        protocol ViewModelProtocol {
            func foo(model: (any ModelProtocol)?)
        }
        """,
      expectingClassDeclaration: """
        class ViewModelProtocolSpy: ViewModelProtocol {
            var fooModelCallsCount = 0
            var fooModelCalled: Bool {
                return fooModelCallsCount > 0
            }
            var fooModelReceivedModel: (any ModelProtocol)?
            var fooModelReceivedInvocations: [(any ModelProtocol)?] = []
            var fooModelClosure: (((any ModelProtocol)?) -> Void)?
            func foo(model: (any ModelProtocol)?) {
                fooModelCallsCount += 1
                fooModelReceivedModel = (model)
                fooModelReceivedInvocations.append((model))
                fooModelClosure?(model)
            }
        }
        """
    )
  }

  func testDeclarationOpaqueTypeArgument() throws {
    try assertProtocol(
      withDeclaration: """
        protocol ViewModelProtocol {
            func foo(model: some ModelProtocol)
        }
        """,
      expectingClassDeclaration: """
        class ViewModelProtocolSpy: ViewModelProtocol {
            var fooModelCallsCount = 0
            var fooModelCalled: Bool {
                return fooModelCallsCount > 0
            }
            var fooModelReceivedModel: (some ModelProtocol)?
            var fooModelReceivedInvocations: [some ModelProtocol] = []
            var fooModelClosure: ((some ModelProtocol) -> Void)?
            func foo(model: some ModelProtocol) {
                fooModelCallsCount += 1
                fooModelReceivedModel = (model)
                fooModelReceivedInvocations.append((model))
                fooModelClosure?(model)
            }
        }
        """
    )
  }

  func testDeclarationOptionalOpaqueTypeArgument() throws {
    try assertProtocol(
      withDeclaration: """
        protocol ViewModelProtocol {
            func foo(model: (some ModelProtocol)?)
        }
        """,
      expectingClassDeclaration: """
        class ViewModelProtocolSpy: ViewModelProtocol {
            var fooModelCallsCount = 0
            var fooModelCalled: Bool {
                return fooModelCallsCount > 0
            }
            var fooModelReceivedModel: (some ModelProtocol)?
            var fooModelReceivedInvocations: [(some ModelProtocol)?] = []
            var fooModelClosure: (((some ModelProtocol)?) -> Void)?
            func foo(model: (some ModelProtocol)?) {
                fooModelCallsCount += 1
                fooModelReceivedModel = (model)
                fooModelReceivedInvocations.append((model))
                fooModelClosure?(model)
            }
        }
        """
    )
  }

  func testDeclarationGenericArgument() throws {
    let declaration = DeclSyntax(
      """
      protocol ViewModelProtocol {
      func foo<T, U>(text: String, value: T) -> U
      }
      """
    )
    let protocolDeclaration = try XCTUnwrap(ProtocolDeclSyntax(declaration))

    let result = try SpyFactory().classDeclaration(for: protocolDeclaration)

    assertBuildResult(
      result,
      """
      class ViewModelProtocolSpy: ViewModelProtocol {
          var fooTextValueCallsCount = 0
          var fooTextValueCalled: Bool {
              return fooTextValueCallsCount > 0
          }
          var fooTextValueReceivedArguments: (text: String, value: Any)?
          var fooTextValueReceivedInvocations: [(text: String, value: Any)] = []
          var fooTextValueReturnValue: Any!
          var fooTextValueClosure: ((String, Any) -> Any)?
          func foo<T, U>(text: String, value: T) -> U {
              fooTextValueCallsCount += 1
              fooTextValueReceivedArguments = (text, value)
              fooTextValueReceivedInvocations.append((text, value))
              if fooTextValueClosure != nil {
                  return fooTextValueClosure!(text, value) as! U
              } else {
                  return fooTextValueReturnValue as! U
              }
          }
      }
      """
    )
  }

  func testDeclarationEscapingAutoClosureArgument() throws {
    try assertProtocol(
      withDeclaration: """
        protocol ViewModelProtocol {
            func foo(action: @escaping @autoclosure () -> Void)
        }
        """,
      expectingClassDeclaration: """
        class ViewModelProtocolSpy: ViewModelProtocol {
            var fooActionCallsCount = 0
            var fooActionCalled: Bool {
                return fooActionCallsCount > 0
            }
            var fooActionReceivedAction: (() -> Void)?
            var fooActionReceivedInvocations: [() -> Void] = []
            var fooActionClosure: ((@escaping @autoclosure () -> Void) -> Void)?
            func foo(action: @escaping @autoclosure () -> Void) {
                fooActionCallsCount += 1
                fooActionReceivedAction = (action)
                fooActionReceivedInvocations.append((action))
                fooActionClosure?(action())
            }
        }
        """
    )
  }

  func testDeclarationNonescapingClosureArgument() throws {
    try assertProtocol(
      withDeclaration: """
        protocol ViewModelProtocol {
            func foo(action: () -> Void)
        }
        """,
      expectingClassDeclaration: """
        class ViewModelProtocolSpy: ViewModelProtocol {
            var fooActionCallsCount = 0
            var fooActionCalled: Bool {
                return fooActionCallsCount > 0
            }
            var fooActionClosure: ((() -> Void) -> Void)?
            func foo(action: () -> Void) {
                fooActionCallsCount += 1
                fooActionClosure?(action)
            }
        }
        """
    )
  }

  func testDeclarationReturnValue() throws {
    try assertProtocol(
      withDeclaration: """
        protocol Bar {
            func print() -> (text: String, tuple: (count: Int?, Date))
        }
        """,
      expectingClassDeclaration: """
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
    try assertProtocol(
      withDeclaration: """
        protocol ServiceProtocol {
            func foo(text: String, count: Int) async -> Decimal
        }
        """,
      expectingClassDeclaration: """
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
    try assertProtocol(
      withDeclaration: """
        protocol ServiceProtocol {
            func foo(_ added: ((text: String) -> Void)?) throws -> (() -> Int)?
        }
        """,
      expectingClassDeclaration: """
        class ServiceProtocolSpy: ServiceProtocol {
            var fooCallsCount = 0
            var fooCalled: Bool {
                return fooCallsCount > 0
            }
            var fooReceivedAdded: ((text: String) -> Void)?
            var fooReceivedInvocations: [((text: String) -> Void)?] = []
            var fooThrowableError: (any Error)?
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

  func testDeclarationReturnsExistential() throws {
    try assertProtocol(
      withDeclaration: """
        protocol ServiceProtocol {
            func foo() -> any Codable
        }
        """,
      expectingClassDeclaration: """
        class ServiceProtocolSpy: ServiceProtocol {
            var fooCallsCount = 0
            var fooCalled: Bool {
                return fooCallsCount > 0
            }
            var fooReturnValue: (any Codable)!
            var fooClosure: (() -> any Codable)?
            func foo() -> any Codable {
                fooCallsCount += 1
                if fooClosure != nil {
                    return fooClosure!()
                } else {
                    return fooReturnValue
                }
            }
        }
        """
    )
  }

  func testDeclarationReturnsForcedUnwrappedType() throws {
    try assertProtocol(
      withDeclaration: """
        protocol ServiceProtocol {
            func foo() -> String!
        }
        """,
      expectingClassDeclaration: """
        class ServiceProtocolSpy: ServiceProtocol {
            var fooCallsCount = 0
            var fooCalled: Bool {
                return fooCallsCount > 0
            }
            var fooReturnValue: String!
            var fooClosure: (() -> String?)?
            func foo() -> String! {
                fooCallsCount += 1
                if fooClosure != nil {
                    return fooClosure!()
                } else {
                    return fooReturnValue
                }
            }
        }
        """
    )
  }

  func testDeclarationVariable() throws {
    try assertProtocol(
      withDeclaration: """
        protocol ServiceProtocol {
            var data: Data { get }
        }
        """,
      expectingClassDeclaration: """
        class ServiceProtocolSpy: ServiceProtocol {
            var data: Data {
                get {
                    underlyingData
                }
                set {
                    underlyingData = newValue
                }
            }
            var underlyingData: (Data)!
        }
        """
    )
  }

  func testDeclarationOptionalVariable() throws {
    try assertProtocol(
      withDeclaration: """
        protocol ServiceProtocol {
            var data: Data? { get set }
        }
        """,
      expectingClassDeclaration: """
        class ServiceProtocolSpy: ServiceProtocol {
            var data: Data?
        }
        """
    )
  }

  func testDeclarationForcedUnwrappedVariable() throws {
    try assertProtocol(
      withDeclaration: """
        protocol ServiceProtocol {
            var data: String! { get set }
        }
        """,
      expectingClassDeclaration: """
        class ServiceProtocolSpy: ServiceProtocol {
            var data: String!
        }
        """
    )
  }

  func testDeclarationExistentialVariable() throws {
    try assertProtocol(
      withDeclaration: """
        protocol ServiceProtocol {
            var data: any Codable { get set }
        }
        """,
      expectingClassDeclaration: """
        class ServiceProtocolSpy: ServiceProtocol {
            var data: any Codable {
                get {
                    underlyingData
                }
                set {
                    underlyingData = newValue
                }
            }
            var underlyingData: (any Codable)!
        }
        """
    )
  }

  func testDeclarationClosureVariable() throws {
    try assertProtocol(
      withDeclaration: """
        protocol ServiceProtocol {
            var completion: () -> Void { get set }
        }
        """,
      expectingClassDeclaration: """
        class ServiceProtocolSpy: ServiceProtocol {
            var completion: () -> Void {
                get {
                    underlyingCompletion
                }
                set {
                    underlyingCompletion = newValue
                }
            }
            var underlyingCompletion: (() -> Void)!
        }
        """
    )
  }

  // - MARK: Handle Protocol Associated types

  func testDeclarationAssociatedtype() throws {
    try assertProtocol(
      withDeclaration: """
        protocol Foo {
            associatedtype Key: Hashable
        }
        """,
      expectingClassDeclaration: """
        class FooSpy<Key: Hashable>: Foo {
        }
        """
    )
  }

  func testDeclarationAssociatedtypeKeyValue() throws {
    try assertProtocol(
      withDeclaration: """
        protocol Foo {
            associatedtype Key: Hashable
            associatedtype Value
        }
        """,
      expectingClassDeclaration: """
        class FooSpy<Key: Hashable, Value>: Foo {
        }
        """
    )
  }

  // MARK: - Helper Methods for Assertions

  private func assertProtocol(
    withDeclaration protocolDeclaration: String,
    expectingClassDeclaration expectedDeclaration: String,
    file: StaticString = #file,
    line: UInt = #line
  ) throws {
    let protocolDeclaration = try ProtocolDeclSyntax("\(raw: protocolDeclaration)")

    let result = try SpyFactory().classDeclaration(for: protocolDeclaration)

    assertBuildResult(result, expectedDeclaration, file: file, line: line)
  }
}
