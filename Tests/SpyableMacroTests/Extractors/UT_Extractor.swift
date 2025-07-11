import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics
import XCTest

@testable import SpyableMacro

final class UT_Extractor: XCTestCase {
  private var mockContext: MockMacroExpansionContext!
  
  override func setUp() {
    super.setUp()
    mockContext = MockMacroExpansionContext()
  }

  func testExtractProtocolDeclarationSuccessfully() throws {
    let declaration = DeclSyntax(
      """
      protocol Foo {}
      """
    )

    XCTAssertNoThrow(_ = try Extractor().extractProtocolDeclaration(from: declaration))
  }

  func test_extractProtocolDeclaration_fails() throws {
    var receivedError: Error?

    let declaration = DeclSyntax(
      """
      struct Foo {}
      """
    )

    XCTAssertThrowsError(_ = try Extractor().extractProtocolDeclaration(from: declaration)) {
      receivedError = $0
    }
    let unwrappedReceivedError = try XCTUnwrap(receivedError as? SpyableDiagnostic)
    XCTAssertEqual(unwrappedReceivedError, .onlyApplicableToProtocol)
  }

  // MARK: - extractInheritedType Tests
  
  func test_extractInheritedType_withValidStringLiteral_returnsValue() {
    // Given
    let attribute = AttributeSyntax(
      """
      @Spyable(inheritedType: "BaseClass")
      """
    )
    
    // When
    let result = Extractor().extractInheritedType(from: attribute, in: mockContext)
    
    // Then
    XCTAssertEqual(result, "BaseClass")
    XCTAssertTrue(mockContext.diagnostics.isEmpty)
  }
  
  func test_extractInheritedType_withNoArguments_returnsNil() {
    // Given
    let attribute = AttributeSyntax(
      """
      @Spyable
      """
    )
    
    // When
    let result = Extractor().extractInheritedType(from: attribute, in: mockContext)
    
    // Then
    XCTAssertNil(result)
    XCTAssertTrue(mockContext.diagnostics.isEmpty)
  }
  
  func test_extractInheritedType_withMissingInheritedTypeArgument_returnsNil() {
    // Given
    let attribute = AttributeSyntax(
      """
      @Spyable(accessLevel: .public)
      """
    )
    
    // When
    let result = Extractor().extractInheritedType(from: attribute, in: mockContext)
    
    // Then
    XCTAssertNil(result)
    XCTAssertTrue(mockContext.diagnostics.isEmpty)
  }
  
  func test_extractInheritedType_withNonStringLiteral_returnsNilAndDiagnoses() {
    // Given
    let attribute = AttributeSyntax(
      """
      @Spyable(inheritedType: someVariable)
      """
    )
    
    // When
    let result = Extractor().extractInheritedType(from: attribute, in: mockContext)
    
    // Then
    XCTAssertNil(result)
    XCTAssertEqual(mockContext.diagnostics.count, 1)
    XCTAssertEqual(
      mockContext.diagnostics.first?.message,
      SpyableDiagnostic.inheritedTypeArgumentRequiresStaticStringLiteral.message
    )
  }
  
  func test_extractInheritedType_withEmptyString_returnsEmptyString() {
    // Given
    let attribute = AttributeSyntax(
      """
      @Spyable(inheritedType: "")
      """
    )
    
    // When
    let result = Extractor().extractInheritedType(from: attribute, in: mockContext)
    
    // Then
    XCTAssertEqual(result, "")
    XCTAssertTrue(mockContext.diagnostics.isEmpty)
  }
  
  func test_extractInheritedType_withComplexClassName_returnsValue() {
    // Given
    let attribute = AttributeSyntax(
      """
      @Spyable(inheritedType: "MyModule.BaseClass<T>")
      """
    )
    
    // When
    let result = Extractor().extractInheritedType(from: attribute, in: mockContext)
    
    // Then
    XCTAssertEqual(result, "MyModule.BaseClass<T>")
    XCTAssertTrue(mockContext.diagnostics.isEmpty)
  }
}

// MARK: - Mock Context

private class MockMacroExpansionContext: MacroExpansionContext {
  var diagnostics: [Diagnostic] = []
  
  func diagnose(_ diagnostic: Diagnostic) {
    diagnostics.append(diagnostic)
  }
  
  func location<Node: SyntaxProtocol>(
    of node: Node,
    at position: PositionInSyntaxNode,
    filePathMode: SourceLocationFilePathMode
  ) -> AbstractSourceLocation? {
    return nil
  }
  
  func location(
    for token: TokenSyntax,
    at position: PositionInSyntaxNode,
    filePathMode: SourceLocationFilePathMode
  ) -> AbstractSourceLocation? {
    return nil
  }
  
  var lexicalContext: [Syntax] = []
  
  func makeUniqueName(_ providedName: String) -> TokenSyntax {
    return TokenSyntax.identifier(providedName)
  }
}
