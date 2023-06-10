import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import SpyableMacro

final class UT_SpyableMacro: XCTestCase {
    private let sut = ["Spyable": SpyableMacro.self]
    
    func test_foo() {
        let protocolDeclaration = """
        public protocol Foo {
            var number: Int {
                get
            }
            func foo(value: String) -> Int
            var text: String {
                get
            }
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
                    func foo(value: String) -> Int {
                    fooWithValueCallsCount += 1
                }
            }
            """,
            macros: sut
        )
    }
}
