import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import SpyableMacro

final class UT_SpyableMacro: XCTestCase {
    private let sut = ["Spyable": SpyableMacro.self]
    
    func test_foo() {
        assertMacroExpansion(
            """
            @Spyable
            protocol Foo {
                func foo(value: String) -> Int
            }
            """,
            expandedSource: """
            
            protocol Foo {
                func foo(value: String) -> Int
            }
            struct FooSpy {
            }
            """,
            macros: sut
        )
    }
}
