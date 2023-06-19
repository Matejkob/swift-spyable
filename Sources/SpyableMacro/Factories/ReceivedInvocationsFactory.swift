import SwiftSyntax
import SwiftSyntaxBuilder

/// The `ReceivedInvocationsFactory` is designed to generate a representation of a Swift
/// variable declaration to keep track of the arguments passed to a certain function each time it is called.
///
/// The resulting variable is an array, where each element either corresponds to a single function parameter
/// or is a tuple of all parameters if the function has multiple parameters. The variable's name is constructed
/// by appending the word "ReceivedInvocations" to the `variablePrefix` parameter.
///
/// The factory also generates an expression that appends a tuple of parameter identifiers to the variable
/// each time the function is invoked.
///
/// The following code:
/// ```swift
/// var fooReceivedInvocations: [String] = []
///
/// fooReceivedInvocations.append(text)
/// ```
/// would be generated for a function like this:
/// ```swift
/// func foo(text: String)
/// ```
/// and an argument `variablePrefix` equal to `foo`.
///
/// For a function with multiple parameters, the factory generates an array of tuples:
/// ```swift
/// var barReceivedInvocations: [(text: String, count: Int)] = []
///
/// barReceivedInvocations.append((text, count))
/// ```
/// for a function like this:
/// ```swift
/// func bar(text: String, count: Int)
/// ```
/// and an argument `variablePrefix` equal to `bar`.
///
/// - Note: While the `ReceivedInvocationsFactory` keeps track of every individual invocation of a function
///         and the arguments passed in each invocation, the `ReceivedArgumentsFactory` only keeps track
///         of the arguments received in the last invocation of the function. If you want to test a function where the
///         order and number of invocations matter, use `ReceivedInvocationsFactory`. If you only care
///         about the arguments in the last invocation, use `ReceivedArgumentsFactory`.
struct ReceivedInvocationsFactory {
    func variableDeclaration(variablePrefix: String, parameterList: FunctionParameterListSyntax) -> VariableDeclSyntax {
        let identifier = variableIdentifier(variablePrefix: variablePrefix)
        let elementType = arrayElementType(parameterList: parameterList)

        return VariableDeclSyntax(
            bindingKeyword: .keyword(.var),
            bindingsBuilder: {
                PatternBindingSyntax(
                    pattern: IdentifierPatternSyntax(identifier: identifier),
                    typeAnnotation: TypeAnnotationSyntax(
                        type: ArrayTypeSyntax(elementType: elementType)
                    ),
                    initializer: InitializerClauseSyntax(
                        value: ArrayExprSyntax(elementsBuilder: {})
                    )
                )
            }
        )
    }

    private func arrayElementType(parameterList: FunctionParameterListSyntax) -> TypeSyntaxProtocol {
        let arrayElementType: TypeSyntaxProtocol

        if parameterList.count == 1, var onlyParameterType = parameterList.first?.type {
            if let attributedType = onlyParameterType.as(AttributedTypeSyntax.self) {
                onlyParameterType = attributedType.baseType
            }

            arrayElementType = onlyParameterType
        } else {
            let tupleElements = TupleTypeElementListSyntax {
                for parameter in parameterList {
                    TupleTypeElementSyntax(
                        name: parameter.secondName ?? parameter.firstName,
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
            arrayElementType = TupleTypeSyntax(elements: tupleElements)
        }

        return arrayElementType
    }

    func appendValueToVariableExpression(variablePrefix: String, parameterList: FunctionParameterListSyntax) -> FunctionCallExprSyntax {
        let identifier = variableIdentifier(variablePrefix: variablePrefix)
        let calledExpression = MemberAccessExprSyntax(
            base: IdentifierExprSyntax(identifier: identifier),
            dot: .periodToken(),
            name: .identifier("append")
        )
        let argument = appendArgumentExpression(parameterList: parameterList)

        return FunctionCallExprSyntax(
            calledExpression: calledExpression,
            leftParen: .leftParenToken(),
            argumentList: argument,
            rightParen: .rightParenToken()
        )
    }

    private func appendArgumentExpression(parameterList: FunctionParameterListSyntax) -> TupleExprElementListSyntax {
        let tupleArgument = TupleExprSyntax(
            elementListBuilder: {
                for parameter in parameterList {
                    TupleExprElementSyntax(
                        expression: IdentifierExprSyntax(
                            identifier: parameter.secondName ?? parameter.firstName
                        )
                    )
                }
            }
        )

        return TupleExprElementListSyntax {
            TupleExprElementSyntax(expression: tupleArgument)
        }
    }

    private func variableIdentifier(variablePrefix: String) -> TokenSyntax {
        TokenSyntax.identifier(variablePrefix + "ReceivedInvocations")
    }
}
