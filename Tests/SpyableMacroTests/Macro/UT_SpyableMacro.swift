import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import SpyableMacro

final class UT_SpyableMacro: XCTestCase {
    private let sut = ["Spyable": SpyableMacro.self]
    
    func test_foo() {
        let protocolDeclaration = """
        public protocol Foo {
            func foo(value: String) -> Int
        }
        """

        assertMacroExpansion(
            """
            @Spyable
            \(protocolDeclaration)
            """,
            expandedSource:
            """

            \(protocolDeclaration)
            class FooSpy {
                var fooWithValueCallsCount = 0
                var fooWithValueReturnValue: Int!
                    func foo(value: String) -> Int {
                    fooWithValueCallsCount += 1
                    return fooWithValueReturnValue
                }
            }
            """,
            macros: sut
        )
    }
}
