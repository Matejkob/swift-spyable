import SwiftSyntax
import SwiftSyntaxBuilder
import XCTest

@testable import SpyableMacro

final class UT_AccessLevelModifierRewriter: XCTestCase {

  // MARK: - Normal Access Level Rewriting Tests

  func test_visit_withPublicAccessLevel_shouldAddPublicModifier() {
    // Given
    let accessLevel = DeclModifierSyntax(name: .keyword(.public))
    let rewriter = AccessLevelModifierRewriter(newAccessLevel: accessLevel)
    
    let originalFunction = FunctionDeclSyntax(
      modifiers: [],
      name: .identifier("testFunction"),
      signature: FunctionSignatureSyntax(
        parameterClause: FunctionParameterClauseSyntax(parameters: [])
      )
    ) {}
    
    // When
    let rewrittenFunction = rewriter.visit(originalFunction).as(FunctionDeclSyntax.self)!
    
    // Then
    let modifiers = rewrittenFunction.modifiers
    XCTAssertEqual(modifiers.count, 1)
    XCTAssertEqual(modifiers.first?.name.text, "public")
  }

  func test_visit_withInternalAccessLevel_shouldAddInternalModifier() {
    // Given
    let accessLevel = DeclModifierSyntax(name: .keyword(.internal))
    let rewriter = AccessLevelModifierRewriter(newAccessLevel: accessLevel)
    
    let originalVariable = VariableDeclSyntax(
      modifiers: [],
      bindingSpecifier: .keyword(.var)
    ) {
      PatternBindingSyntax(
        pattern: IdentifierPatternSyntax(identifier: .identifier("testVar")),
        typeAnnotation: TypeAnnotationSyntax(type: TypeSyntax("String"))
      )
    }
    
    // When
    let rewrittenVariable = rewriter.visit(originalVariable).as(VariableDeclSyntax.self)!
    
    // Then
    let modifiers = rewrittenVariable.modifiers
    XCTAssertEqual(modifiers.count, 1)
    XCTAssertEqual(modifiers.first?.name.text, "internal")
  }

  func test_visit_withPrivateAccessLevel_shouldConvertToFileprivate() {
    // Given
    let accessLevel = DeclModifierSyntax(name: .keyword(.private))
    let rewriter = AccessLevelModifierRewriter(newAccessLevel: accessLevel)
    
    let originalFunction = FunctionDeclSyntax(
      modifiers: [],
      name: .identifier("testFunction"),
      signature: FunctionSignatureSyntax(
        parameterClause: FunctionParameterClauseSyntax(parameters: [])
      )
    ) {}
    
    // When
    let rewrittenFunction = rewriter.visit(originalFunction).as(FunctionDeclSyntax.self)!
    
    // Then
    let modifiers = rewrittenFunction.modifiers
    XCTAssertEqual(modifiers.count, 1)
    XCTAssertEqual(modifiers.first?.name.text, "fileprivate")
  }

  // MARK: - Initializer Special Case Tests

  func test_visit_withOpenAccessLevel_onInitializer_shouldUsePublicInstead() {
    // Given
    let accessLevel = DeclModifierSyntax(name: .keyword(.open))
    let rewriter = AccessLevelModifierRewriter(newAccessLevel: accessLevel)
    
    let originalInit = InitializerDeclSyntax(
      modifiers: [],
      signature: FunctionSignatureSyntax(
        parameterClause: FunctionParameterClauseSyntax(parameters: [])
      )
    ) {}
    
    // When
    let rewrittenInit = rewriter.visit(originalInit).as(InitializerDeclSyntax.self)!
    
    // Then
    let modifiers = rewrittenInit.modifiers
    XCTAssertEqual(modifiers.count, 1)
    XCTAssertEqual(modifiers.first?.name.text, "public")
  }

  func test_visit_withOpenAccessLevel_onInitializerWithOverride_shouldPreserveOverrideAndAddPublic() {
    // Given
    let accessLevel = DeclModifierSyntax(name: .keyword(.open))
    let rewriter = AccessLevelModifierRewriter(newAccessLevel: accessLevel)
    
    let originalInit = InitializerDeclSyntax(
      modifiers: [DeclModifierSyntax(name: .keyword(.override))],
      signature: FunctionSignatureSyntax(
        parameterClause: FunctionParameterClauseSyntax(parameters: [])
      )
    ) {}
    
    // When
    let rewrittenInit = rewriter.visit(originalInit).as(InitializerDeclSyntax.self)!
    
    // Then
    let modifiers = rewrittenInit.modifiers
    XCTAssertEqual(modifiers.count, 2)
    
    let modifierTexts = modifiers.map { $0.name.text }
    XCTAssertTrue(modifierTexts.contains("override"))
    XCTAssertTrue(modifierTexts.contains("public"))
  }

  func test_visit_withOpenAccessLevel_onInitializerWithConvenience_shouldPreserveConvenienceAndAddPublic() {
    // Given
    let accessLevel = DeclModifierSyntax(name: .keyword(.open))
    let rewriter = AccessLevelModifierRewriter(newAccessLevel: accessLevel)
    
    let originalInit = InitializerDeclSyntax(
      modifiers: [DeclModifierSyntax(name: .keyword(.convenience))],
      signature: FunctionSignatureSyntax(
        parameterClause: FunctionParameterClauseSyntax(parameters: [])
      )
    ) {}
    
    // When
    let rewrittenInit = rewriter.visit(originalInit).as(InitializerDeclSyntax.self)!
    
    // Then
    let modifiers = rewrittenInit.modifiers
    XCTAssertEqual(modifiers.count, 2)
    
    let modifierTexts = modifiers.map { $0.name.text }
    XCTAssertTrue(modifierTexts.contains("convenience"))
    XCTAssertTrue(modifierTexts.contains("public"))
  }

  func test_visit_withOpenAccessLevel_onNonInitializer_shouldUseOpen() {
    // Given
    let accessLevel = DeclModifierSyntax(name: .keyword(.open))
    let rewriter = AccessLevelModifierRewriter(newAccessLevel: accessLevel)
    
    let originalFunction = FunctionDeclSyntax(
      modifiers: [],
      name: .identifier("testFunction"),
      signature: FunctionSignatureSyntax(
        parameterClause: FunctionParameterClauseSyntax(parameters: [])
      )
    ) {}
    
    // When
    let rewrittenFunction = rewriter.visit(originalFunction).as(FunctionDeclSyntax.self)!
    
    // Then
    let modifiers = rewrittenFunction.modifiers
    XCTAssertEqual(modifiers.count, 1)
    XCTAssertEqual(modifiers.first?.name.text, "open")
  }

  // MARK: - Preserve Existing Modifiers Tests

  func test_visit_withExistingModifiers_shouldPreserveAndAddAccessLevel() {
    // Given
    let accessLevel = DeclModifierSyntax(name: .keyword(.public))
    let rewriter = AccessLevelModifierRewriter(newAccessLevel: accessLevel)
    
    let originalFunction = FunctionDeclSyntax(
      modifiers: [
        DeclModifierSyntax(name: .keyword(.static)),
        DeclModifierSyntax(name: .keyword(.final))
      ],
      name: .identifier("testFunction"),
      signature: FunctionSignatureSyntax(
        parameterClause: FunctionParameterClauseSyntax(parameters: [])
      )
    ) {}
    
    // When
    let rewrittenFunction = rewriter.visit(originalFunction).as(FunctionDeclSyntax.self)!
    
    // Then
    let modifiers = rewrittenFunction.modifiers
    XCTAssertEqual(modifiers.count, 3)
    
    let modifierTexts = modifiers.map { $0.name.text }
    XCTAssertTrue(modifierTexts.contains("static"))
    XCTAssertTrue(modifierTexts.contains("final"))
    XCTAssertTrue(modifierTexts.contains("public"))
  }

  // MARK: - Function Parameter Tests

  func test_visit_onFunctionParameter_shouldNotModify() {
    // Given
    let accessLevel = DeclModifierSyntax(name: .keyword(.public))
    let rewriter = AccessLevelModifierRewriter(newAccessLevel: accessLevel)
    
    let parameter = FunctionParameterSyntax(
      modifiers: [],
      firstName: .identifier("param"),
      type: TypeSyntax("String")
    )
    
    // When
    let rewrittenParameter = rewriter.visit(parameter).as(FunctionParameterSyntax.self)!
    
    // Then
    XCTAssertEqual(rewrittenParameter.modifiers.count, 0)
  }

  // MARK: - Edge Cases Tests

  func test_visit_withEmptyModifierList_shouldAddAccessLevel() {
    // Given
    let accessLevel = DeclModifierSyntax(name: .keyword(.internal))
    let rewriter = AccessLevelModifierRewriter(newAccessLevel: accessLevel)
    
    let originalClass = ClassDeclSyntax(
      modifiers: [],
      name: .identifier("TestClass")
    ) {}
    
    // When
    let rewrittenClass = rewriter.visit(originalClass).as(ClassDeclSyntax.self)!
    
    // Then
    let modifiers = rewrittenClass.modifiers
    XCTAssertEqual(modifiers.count, 1)
    XCTAssertEqual(modifiers.first?.name.text, "internal")
  }

  func test_init_withPrivateAccessLevel_shouldConvertToFileprivateInInit() {
    // Given & When
    let accessLevel = DeclModifierSyntax(name: .keyword(.private))
    let rewriter = AccessLevelModifierRewriter(newAccessLevel: accessLevel)
    
    // Then
    XCTAssertEqual(rewriter.newAccessLevel.name.text, "fileprivate")
  }

  func test_init_withNonPrivateAccessLevel_shouldKeepOriginal() {
    // Given & When
    let accessLevel = DeclModifierSyntax(name: .keyword(.public))
    let rewriter = AccessLevelModifierRewriter(newAccessLevel: accessLevel)
    
    // Then
    XCTAssertEqual(rewriter.newAccessLevel.name.text, "public")
  }
}
