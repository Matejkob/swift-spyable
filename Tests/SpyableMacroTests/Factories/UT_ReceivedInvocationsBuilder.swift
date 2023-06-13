import XCTest
@testable import SpyableMacro
import SwiftSyntax

final class UT_ReceivedInvocationsBuilder: XCTestCase {
    func testVariableDeclarationSingleArgument() throws {
        let variablePrefix = "foo"
        let functionDeclaration = try FunctionDeclSyntax(
            "func foo(bar: String?)"
        ) {}

        let result = ReceivedInvocationsBuilder().variableDeclaration(
            variablePrefix: variablePrefix,
            parameterList: functionDeclaration.signature.input.parameterList
        )

        assertBuildResult(
            result,
            """
            var fooReceivedInvocations: [String?] = []
            """
        )
    }

    func testVariableDeclarationSingleArgumentTupleType() throws {
        let variablePrefix = "functionName"
        let functionDeclaration = try FunctionDeclSyntax(
            "func foo(_ tuple: (text: String, (Decimal?, date: Date))?)"
        ) {}

        let result = ReceivedInvocationsBuilder().variableDeclaration(
            variablePrefix: variablePrefix,
            parameterList: functionDeclaration.signature.input.parameterList
        )

        assertBuildResult(
            result,
            """
            var functionNameReceivedInvocations: [(text: String, (Decimal?, date: Date))?] = []
            """
        )
    }

    func testVariableDeclarationMultiArguments() throws {
        let variablePrefix = "func_name"
        let functionDeclaration = try FunctionDeclSyntax(
            "func foo(text: String, _ count: (x: Int, UInt?)?, final price: Decimal?)"
        ) {}

        let result = ReceivedInvocationsBuilder().variableDeclaration(
            variablePrefix: variablePrefix,
            parameterList: functionDeclaration.signature.input.parameterList
        )

        assertBuildResult(
            result,
            """
            var func_nameReceivedInvocations: [(text: String, count: (x: Int, UInt?)?, price: Decimal?)] = []
            """
        )
    }

    func testAppendValueToVariableExpressionSingleArgument() throws {
        let variablePrefix = "funcName"
        let functionDeclaration = try FunctionDeclSyntax(
            "func foo(bar: String?)"
        ) {}

        let result = ReceivedInvocationsBuilder().appendValueToVariableExpression(
            variablePrefix: variablePrefix,
            parameterList: functionDeclaration.signature.input.parameterList
        )

        assertBuildResult(
            result,
            """
            funcNameReceivedInvocations.append((bar))
            """
        )
    }

    func testAppendValueToVariableExpressionSingleArgumentTupleType() throws {
        let variablePrefix = "functionName"
        let functionDeclaration = try FunctionDeclSyntax(
            "func foo(_ tuple: (text: String, (Decimal?, date: Date))?)"
        ) {}

        let result = ReceivedInvocationsBuilder().appendValueToVariableExpression(
            variablePrefix: variablePrefix,
            parameterList: functionDeclaration.signature.input.parameterList
        )

        assertBuildResult(
            result,
            """
            functionNameReceivedInvocations.append((tuple))
            """
        )
    }

    func testAppendValueToVariableExpressionMultiArguments() throws {
        let variablePrefix = "func_name"
        let functionDeclaration = try FunctionDeclSyntax(
            "func foo(text: String, _ count: (x: Int, UInt?)?, final price: Decimal?)"
        ) {}

        let result = ReceivedInvocationsBuilder().appendValueToVariableExpression(
            variablePrefix: variablePrefix,
            parameterList: functionDeclaration.signature.input.parameterList
        )

        assertBuildResult(
            result,
            """
            func_nameReceivedInvocations.append((text, count, price))
            """
        )
    }
}
