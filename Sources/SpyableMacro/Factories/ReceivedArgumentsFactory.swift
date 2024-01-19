import SwiftSyntax
import SwiftSyntaxBuilder

/// The `ReceivedArgumentsFactory` is designed to generate a representation of a Swift
/// variable declaration to keep track of the arguments that are passed to a certain function.
///
/// The resulting variable's type is either the same as the type of the single parameter of the function,
/// or a tuple type of all parameters' types if the function has multiple parameters.
/// The variable is of optional type, and its name is constructed by appending the word "Received"
/// and the parameter name (with the first letter capitalized) to the `variablePrefix` parameter.
/// If the function has multiple parameters, "Arguments" is appended instead.
///
/// The factory also generates an expression that assigns a tuple of parameter identifiers to the variable.
///
/// The following code:
/// ```swift
/// var fooReceivedText: String?
///
/// fooReceivedText = text
/// ```
/// would be generated for a function like this:
/// ```swift
/// func foo(text: String)
/// ```
/// and an argument `variablePrefix` equal to `foo`.
///
/// For a function with multiple parameters, the factory generates a tuple:
/// ```swift
/// var barReceivedArguments: (text: String, count: Int)?
///
/// barReceivedArguments = (text, count)
/// ```
/// for a function like this:
/// ```swift
/// func bar(text: String, count: Int)
/// ```
/// and an argument `variablePrefix` equal to `bar`.
struct ReceivedArgumentsFactory {
  func variableDeclaration(
    modifiers: DeclModifierListSyntax,
    variablePrefix: String,
    parameterList: FunctionParameterListSyntax
  ) throws -> VariableDeclSyntax {
    let identifier = variableIdentifier(
      variablePrefix: variablePrefix,
      parameterList: parameterList
    )
    let type = variableType(parameterList: parameterList)

    var decl = try VariableDeclSyntax(
      """
      var \(identifier): \(type)
      """
    )
    decl.modifiers = modifiers
    return decl
  }

  private func variableType(parameterList: FunctionParameterListSyntax) -> TypeSyntaxProtocol {
    let variableType: TypeSyntaxProtocol

    if parameterList.count == 1, var onlyParameterType = parameterList.first?.type {
      if let attributedType = onlyParameterType.as(AttributedTypeSyntax.self) {
        onlyParameterType = attributedType.baseType
      }

      if onlyParameterType.is(OptionalTypeSyntax.self) {
        variableType = onlyParameterType
      } else if onlyParameterType.is(FunctionTypeSyntax.self) {
        variableType = OptionalTypeSyntax(
          wrappedType: TupleTypeSyntax(
            elements: TupleTypeElementListSyntax {
              TupleTypeElementSyntax(type: onlyParameterType)
            }
          ),
          questionMark: .postfixQuestionMarkToken()
        )
      } else {
        variableType = OptionalTypeSyntax(
          wrappedType: onlyParameterType,
          questionMark: .postfixQuestionMarkToken()
        )
      }
    } else {
      let tupleElements = TupleTypeElementListSyntax {
        for parameter in parameterList {
          TupleTypeElementSyntax(
            firstName: parameter.secondName ?? parameter.firstName,
            colon: .colonToken(),
            type: {
              if let attributedType = parameter.type.as(AttributedTypeSyntax.self) {
                return attributedType.baseType
              } else {
                return parameter.type
              }
            }()
          )
        }
      }
      variableType = OptionalTypeSyntax(
        wrappedType: TupleTypeSyntax(elements: tupleElements),
        questionMark: .postfixQuestionMarkToken()
      )
    }

    return variableType
  }

  func assignValueToVariableExpression(
    variablePrefix: String,
    parameterList: FunctionParameterListSyntax
  ) -> ExprSyntax {
    let identifier = variableIdentifier(
      variablePrefix: variablePrefix,
      parameterList: parameterList
    )

    let tuple = TupleExprSyntax {
      for parameter in parameterList {
        LabeledExprSyntax(
          expression: DeclReferenceExprSyntax(
            baseName: parameter.secondName ?? parameter.firstName
          )
        )
      }
    }

    return ExprSyntax(
      """
      \(identifier) = \(tuple)
      """
    )
  }

  private func variableIdentifier(
    variablePrefix: String,
    parameterList: FunctionParameterListSyntax
  ) -> TokenSyntax {
    if parameterList.count == 1, let onlyParameter = parameterList.first {
      let parameterNameToken = onlyParameter.secondName ?? onlyParameter.firstName
      let parameterNameText = parameterNameToken.text
      let capitalizedParameterName =
        parameterNameText.prefix(1).uppercased() + parameterNameText.dropFirst()

      return .identifier(variablePrefix + "Received" + capitalizedParameterName)
    } else {
      return .identifier(variablePrefix + "ReceivedArguments")
    }
  }
}
