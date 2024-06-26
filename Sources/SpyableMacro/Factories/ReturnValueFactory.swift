import SwiftSyntax
import SwiftSyntaxBuilder

/// The `ReturnValueFactory` is designed to generate a representation of a Swift
/// variable declaration to store the return value of a certain function.
///
/// The generated variable type is implicitly unwrapped optional if the function has a non-optional
/// return type, otherwise, the type is the same as the function's return type. The name of the variable
/// is constructed by appending the word "ReturnValue" to the `variablePrefix` parameter.
///
/// The factory also generates a return statement that uses the stored value as the return value of the function.
///
/// The following code:
/// ```swift
/// var fooReturnValue: Int!
///
/// return fooReturnValue
/// ```
/// would be generated for a function like this:
/// ```swift
/// func foo() -> Int
/// ```
/// and an argument `variablePrefix` equal to `foo`.
///
/// If the return type of the function is optional, the generated variable type is the same as the return type:
/// ```swift
/// var barReturnValue: String?
///
/// return barReturnValue
/// ```
/// for a function like this:
/// ```swift
/// func bar() -> String?
/// ```
/// and an argument `variablePrefix` equal to `bar`.
///
/// - Note: The `ReturnValueFactory` allows you to specify the return value for a function in
///         your tests. You can use it to simulate different scenarios and verify that your code reacts
///         correctly to different returned values.
struct ReturnValueFactory {
  func variableDeclaration(
    variablePrefix: String,
    functionReturnType: TypeSyntax
  ) throws -> VariableDeclSyntax {
    /*
     func f() -> String?
     */
    let typeAnnotation =
      if functionReturnType.is(OptionalTypeSyntax.self) {
        TypeAnnotationSyntax(type: functionReturnType)
        /*
     func f() -> String!
     */
      } else if functionReturnType.is(ImplicitlyUnwrappedOptionalTypeSyntax.self) {
        TypeAnnotationSyntax(type: functionReturnType)
        /*
     func f() -> any Codable
     */
      } else if functionReturnType.is(SomeOrAnyTypeSyntax.self) {
        TypeAnnotationSyntax(
          type: ImplicitlyUnwrappedOptionalTypeSyntax(
            wrappedType: TupleTypeSyntax(
              elements: TupleTypeElementListSyntax {
                TupleTypeElementSyntax(type: functionReturnType)
              }
            )
          )
        )
        /*
     func f() -> String
     */
      } else {
        TypeAnnotationSyntax(
          type: ImplicitlyUnwrappedOptionalTypeSyntax(wrappedType: functionReturnType)
        )
      }

    return try VariableDeclSyntax(
      """
      var \(variableIdentifier(variablePrefix: variablePrefix))\(typeAnnotation)
      """
    )
  }

  func returnStatement(
    variablePrefix: String,
    forceCastType: TypeSyntax? = nil
  ) -> StmtSyntaxProtocol {
    var expression: ExprSyntaxProtocol = DeclReferenceExprSyntax(
      baseName: variableIdentifier(variablePrefix: variablePrefix)
    )
    if let forceCastType {
      expression = AsExprSyntax(
        expression: expression,
        questionOrExclamationMark: .exclamationMarkToken(trailingTrivia: .space),
        type: forceCastType
      )
    }
    return ReturnStmtSyntax(expression: expression)
  }

  private func variableIdentifier(variablePrefix: String) -> TokenSyntax {
    TokenSyntax.identifier(variablePrefix + "ReturnValue")
  }
}
