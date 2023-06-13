import XCTest
@testable import SpyableMacro
import SwiftSyntax

final class UT_ReceivedArgumentsBuilder: XCTestCase {
    func testVariableDeclarationSingleArgument() throws {
        let variablePrefix = "foo"
        let functionDeclaration = try FunctionDeclSyntax(
            "func foo(bar: String)"
        ) {}

        let result = ReceivedArgumentsBuilder().variableDeclaration(
            variablePrefix: variablePrefix,
            parameterList: functionDeclaration.signature.input.parameterList
        )

        assertBuildResult(
            result,
            """
            var fooReceivedBar: String?
            """
        )
    }

    func testVariableDeclarationSingleOptionalArgument() throws {
        let variablePrefix = "foo_name"
        let functionDeclaration = try FunctionDeclSyntax(
            "func foo(_ price: Decimal?)"
        ) {}

        let result = ReceivedArgumentsBuilder().variableDeclaration(
            variablePrefix: variablePrefix,
            parameterList: functionDeclaration.signature.input.parameterList
        )

        assertBuildResult(
            result,
            """
            var foo_nameReceivedPrice: Decimal?
            """
        )
    }

    func testVariableDeclarationSingleArgumentDoubleParameterName() throws {
        let variablePrefix = "functionName"
        let functionDeclaration = try FunctionDeclSyntax(
            "func foo(firstName secondName: (String, Int))"
        ) {}

        let result = ReceivedArgumentsBuilder().variableDeclaration(
            variablePrefix: variablePrefix,
            parameterList: functionDeclaration.signature.input.parameterList
        )

        assertBuildResult(
            result,
            """
            var functionNameReceivedSecondName: (String, Int)?
            """
        )
    }

    func testVariableDeclarationMultiArguments() throws {
        let variablePrefix = "foo"
        let functionDeclaration = try FunctionDeclSyntax(
            "func foo(text: String, _ count: (x: Int, UInt?)?, final price: Decimal?)"
        ) {}

        let result = ReceivedArgumentsBuilder().variableDeclaration(
            variablePrefix: variablePrefix,
            parameterList: functionDeclaration.signature.input.parameterList
        )

        assertBuildResult(
            result,
            """
            var fooReceivedArguments: (text: String, count: (x: Int, UInt?)?, price: Decimal?)?
            """
        )
    }

    func testAssignValueToVariableExpressionSingleArgumentFirstParameterName() throws {
        let variablePrefix = "funcName"
        let functionDeclaration = try FunctionDeclSyntax(
            "func foo(text: String)"
        ) {}

        let result = ReceivedArgumentsBuilder().assignValueToVariableExpression(
            variablePrefix: variablePrefix,
            parameterList: functionDeclaration.signature.input.parameterList
        )

        assertBuildResult(
            result,
            """
            funcNameReceivedText = (text)
            """
        )
    }

    func testAssignValueToVariableExpressionSingleArgumentSecondParameterName() throws {
        let variablePrefix = "funcName"
        let functionDeclaration = try FunctionDeclSyntax(
            "func foo(_ count: Int?)"
        ) {}

        let result = ReceivedArgumentsBuilder().assignValueToVariableExpression(
            variablePrefix: variablePrefix,
            parameterList: functionDeclaration.signature.input.parameterList
        )

        assertBuildResult(
            result,
            """
            funcNameReceivedCount = (count)
            """
        )
    }

    func testAssignValueToVariableExpressionSingleArgumentDoubleParameterName() throws {
        let variablePrefix = "funcName"
        let functionDeclaration = try FunctionDeclSyntax(
            "func foo(first second: Data)"
        ) {}

        let result = ReceivedArgumentsBuilder().assignValueToVariableExpression(
            variablePrefix: variablePrefix,
            parameterList: functionDeclaration.signature.input.parameterList
        )

        assertBuildResult(
            result,
            """
            funcNameReceivedSecond = (second)
            """
        )
    }

    func testAssignValueToVariableExpressionMultiArguments() throws {
        let variablePrefix = "foo"
        let functionDeclaration = try FunctionDeclSyntax(
            "func foo(text: String, _ count: (x: Int, UInt?)?, final price: Decimal?)"
        ) {}

        let result = ReceivedArgumentsBuilder().assignValueToVariableExpression(
            variablePrefix: variablePrefix,
            parameterList: functionDeclaration.signature.input.parameterList
        )

        assertBuildResult(
            result,
            """
            fooReceivedArguments = (text, count, price)
            """
        )
    }
}
