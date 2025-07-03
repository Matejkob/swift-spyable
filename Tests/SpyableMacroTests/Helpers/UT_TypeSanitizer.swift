import XCTest
import SwiftSyntax
import SwiftSyntaxBuilder
@testable import SpyableMacro

// MARK: - TypeSyntaxSanitizer Tests

final class UT_TypeSyntaxSanitizer: XCTestCase {
    
    // MARK: - Basic Type Tests
    
    func testSanitizeIdentifierType() {
        let stringType = IdentifierTypeSyntax(name: .identifier("String"))
        XCTAssertEqual(TypeSyntaxSanitizer.sanitize(TypeSyntax(stringType)), "String")
        
        let intType = IdentifierTypeSyntax(name: .identifier("Int"))
        XCTAssertEqual(TypeSyntaxSanitizer.sanitize(TypeSyntax(intType)), "Int")
        
        let customType = IdentifierTypeSyntax(name: .identifier("MyCustomType"))
        XCTAssertEqual(TypeSyntaxSanitizer.sanitize(TypeSyntax(customType)), "MyCustomType")
    }
    
    // MARK: - Array Type Tests
    
    func testSanitizeArrayTypes() {
        let stringArrayType = ArrayTypeSyntax(
            element: IdentifierTypeSyntax(name: .identifier("String"))
        )
        XCTAssertEqual(TypeSyntaxSanitizer.sanitize(TypeSyntax(stringArrayType)), "ArrayString")
        
        let intArrayType = ArrayTypeSyntax(
            element: IdentifierTypeSyntax(name: .identifier("Int"))
        )
        XCTAssertEqual(TypeSyntaxSanitizer.sanitize(TypeSyntax(intArrayType)), "ArrayInt")
        
        let boolArrayType = ArrayTypeSyntax(
            element: IdentifierTypeSyntax(name: .identifier("Bool"))
        )
        XCTAssertEqual(TypeSyntaxSanitizer.sanitize(TypeSyntax(boolArrayType)), "ArrayBool")
    }
    
    func testSanitizeNestedArrayTypes() {
        let nestedArrayType = ArrayTypeSyntax(
            element: ArrayTypeSyntax(
                element: IdentifierTypeSyntax(name: .identifier("String"))
            )
        )
        XCTAssertEqual(TypeSyntaxSanitizer.sanitize(TypeSyntax(nestedArrayType)), "ArrayArrayString")
    }
    
    // MARK: - Dictionary Type Tests
    
    func testSanitizeDictionaryTypes() {
        let stringIntDictType = DictionaryTypeSyntax(
            key: IdentifierTypeSyntax(name: .identifier("String")),
            value: IdentifierTypeSyntax(name: .identifier("Int"))
        )
        XCTAssertEqual(TypeSyntaxSanitizer.sanitize(TypeSyntax(stringIntDictType)), "DictionaryStringInt")
        
        let intStringDictType = DictionaryTypeSyntax(
            key: IdentifierTypeSyntax(name: .identifier("Int")),
            value: IdentifierTypeSyntax(name: .identifier("String"))
        )
        XCTAssertEqual(TypeSyntaxSanitizer.sanitize(TypeSyntax(intStringDictType)), "DictionaryIntString")
    }
    
    func testSanitizeNestedDictionaryTypes() {
        let nestedDictType = DictionaryTypeSyntax(
            key: IdentifierTypeSyntax(name: .identifier("String")),
            value: DictionaryTypeSyntax(
                key: IdentifierTypeSyntax(name: .identifier("String")),
                value: IdentifierTypeSyntax(name: .identifier("Int"))
            )
        )
        XCTAssertEqual(TypeSyntaxSanitizer.sanitize(TypeSyntax(nestedDictType)), "DictionaryStringDictionaryStringInt")
    }
    
    // MARK: - Optional Type Tests
    
    func testSanitizeOptionalTypes() {
        let optionalStringType = OptionalTypeSyntax(
            wrappedType: IdentifierTypeSyntax(name: .identifier("String"))
        )
        XCTAssertEqual(TypeSyntaxSanitizer.sanitize(TypeSyntax(optionalStringType)), "OptionalString")
        
        let optionalIntType = OptionalTypeSyntax(
            wrappedType: IdentifierTypeSyntax(name: .identifier("Int"))
        )
        XCTAssertEqual(TypeSyntaxSanitizer.sanitize(TypeSyntax(optionalIntType)), "OptionalInt")
    }
    
    func testSanitizeDoubleOptionalTypes() {
        let doubleOptionalType = OptionalTypeSyntax(
            wrappedType: OptionalTypeSyntax(
                wrappedType: IdentifierTypeSyntax(name: .identifier("String"))
            )
        )
        XCTAssertEqual(TypeSyntaxSanitizer.sanitize(TypeSyntax(doubleOptionalType)), "OptionalOptionalString")
    }
    
    func testSanitizeOptionalCollectionTypes() {
        let optionalArrayType = OptionalTypeSyntax(
            wrappedType: ArrayTypeSyntax(
                element: IdentifierTypeSyntax(name: .identifier("String"))
            )
        )
        XCTAssertEqual(TypeSyntaxSanitizer.sanitize(TypeSyntax(optionalArrayType)), "OptionalArrayString")
        
        let arrayOptionalType = ArrayTypeSyntax(
            element: OptionalTypeSyntax(
                wrappedType: IdentifierTypeSyntax(name: .identifier("String"))
            )
        )
        XCTAssertEqual(TypeSyntaxSanitizer.sanitize(TypeSyntax(arrayOptionalType)), "ArrayStringOptional")
    }
    
    // MARK: - Member Type Tests
    
    func testSanitizeMemberTypes() {
        let memberType = MemberTypeSyntax(
            baseType: IdentifierTypeSyntax(name: .identifier("Swift")),
            name: .identifier("String")
        )
        XCTAssertEqual(TypeSyntaxSanitizer.sanitize(TypeSyntax(memberType)), "SwiftString")
        
        let nestedMemberType = MemberTypeSyntax(
            baseType: MemberTypeSyntax(
                baseType: IdentifierTypeSyntax(name: .identifier("Foundation")),
                name: .identifier("Data")
            ),
            name: .identifier("Index")
        )
        XCTAssertEqual(TypeSyntaxSanitizer.sanitize(TypeSyntax(nestedMemberType)), "FoundationDataIndex")
    }
    
    // MARK: - Some/Any Type Tests
    
    func testSanitizeSomeOrAnyTypes() {
        let anyType = SomeOrAnyTypeSyntax(
            someOrAnySpecifier: .keyword(.any),
            constraint: IdentifierTypeSyntax(name: .identifier("Codable"))
        )
        XCTAssertEqual(TypeSyntaxSanitizer.sanitize(TypeSyntax(anyType)), "anyCodable")
        
        let someType = SomeOrAnyTypeSyntax(
            someOrAnySpecifier: .keyword(.some),
            constraint: IdentifierTypeSyntax(name: .identifier("Protocol"))
        )
        XCTAssertEqual(TypeSyntaxSanitizer.sanitize(TypeSyntax(someType)), "someProtocol")
    }
}
