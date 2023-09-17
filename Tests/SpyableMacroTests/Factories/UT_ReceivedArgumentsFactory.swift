import XCTest
@testable import SpyableMacro
import SwiftSyntax

final class UT_ReceivedArgumentsFactory: XCTestCase {

    // MARK: - Variable Declaration

    func testVariableDeclarationSingleArgument() throws {
        let variablePrefix = "foo"
        let functionDeclaration = try FunctionDeclSyntax(
            "func foo(bar: String)"
        ) {}

        let result = ReceivedArgumentsFactory().variableDeclaration(
            variablePrefix: variablePrefix,
            parameterList: functionDeclaration.signature.parameterClause.parameters
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

        let result = ReceivedArgumentsFactory().variableDeclaration(
            variablePrefix: variablePrefix,
            parameterList: functionDeclaration.signature.parameterClause.parameters
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

        let result = ReceivedArgumentsFactory().variableDeclaration(
            variablePrefix: variablePrefix,
            parameterList: functionDeclaration.signature.parameterClause.parameters
        )

        assertBuildResult(
            result,
            """
            var functionNameReceivedSecondName: (String, Int)?
            """
        )
    }

    func testVariableDeclarationSingleArgumentWithEscapingAttribute() throws {
        let variablePrefix = "foo"
        let functionDeclaration = try FunctionDeclSyntax(
            "func foo(completion: @escaping () -> Void)"
        ) {}

        let result = ReceivedArgumentsFactory().variableDeclaration(
            variablePrefix: variablePrefix,
            parameterList: functionDeclaration.signature.parameterClause.parameters
        )

        assertBuildResult(
            result,
            """
            var fooReceivedCompletion: (() -> Void)?
            """
        )
    }

    func testVariableDeclarationSingleArgumentWithEscapingAttributeAndTuple() throws {
        let variablePrefix = "foo"
        let functionDeclaration = try FunctionDeclSyntax(
            "func foo(completion: @escaping (() -> Void))"
        ) {}

        let result = ReceivedArgumentsFactory().variableDeclaration(
            variablePrefix: variablePrefix,
            parameterList: functionDeclaration.signature.parameterClause.parameters
        )

        assertBuildResult(
            result,
            """
            var fooReceivedCompletion: (() -> Void)?
            """
        )
    }

    func testVariableDeclarationSingleClosureArgument() throws {
        let variablePrefix = "foo"
        let functionDeclaration = try FunctionDeclSyntax(
            "func foo(completion: () -> Void)"
        ) {}

        let result = ReceivedArgumentsFactory().variableDeclaration(
            variablePrefix: variablePrefix,
            parameterList: functionDeclaration.signature.parameterClause.parameters
        )

        assertBuildResult(
            result,
            """
            var fooReceivedCompletion: (() -> Void)?
            """
        )
    }

    func testVariableDeclarationSingleOptionalClosureArgument() throws {
        let variablePrefix = "foo"
        let functionDeclaration = try FunctionDeclSyntax(
            "func foo(completion: (() -> Void)?)"
        ) {}

        let result = ReceivedArgumentsFactory().variableDeclaration(
            variablePrefix: variablePrefix,
            parameterList: functionDeclaration.signature.parameterClause.parameters
        )

        assertBuildResult(
            result,
            """
            var fooReceivedCompletion: (() -> Void)?
            """
        )
    }

    func testVariableDeclarationMultiArguments() throws {
        let variablePrefix = "foo"
        let functionDeclaration = try FunctionDeclSyntax(
            "func foo(text: String, _ count: (x: Int, UInt?)?, final price: Decimal?)"
        ) {}

        let result = ReceivedArgumentsFactory().variableDeclaration(
            variablePrefix: variablePrefix,
            parameterList: functionDeclaration.signature.parameterClause.parameters
        )

        assertBuildResult(
            result,
            """
            var fooReceivedArguments: (text: String, count: (x: Int, UInt?)?, price: Decimal?)?
            """
        )
    }

    func testVariableDeclarationMultiArgumentsWithEscapingAttribute() throws {
        let variablePrefix = "foo"
        let functionDeclaration = try FunctionDeclSyntax(
            "func foo(completion: @escaping () -> Void, _ count: (x: Int, UInt?)?, final price: Decimal?)"
        ) {}

        let result = ReceivedArgumentsFactory().variableDeclaration(
            variablePrefix: variablePrefix,
            parameterList: functionDeclaration.signature.parameterClause.parameters
        )

        assertBuildResult(
            result,
            """
            var fooReceivedArguments: (completion: () -> Void, count: (x: Int, UInt?)?, price: Decimal?)?
            """
        )
    }

    func testVariableDeclarationMultiArgumentsWithSomeClosureArgument() throws {
        let variablePrefix = "foo"
        let functionDeclaration = try FunctionDeclSyntax(
            "func foo(completion: () -> Void, _ count: (x: Int, UInt?)?, final price: Decimal?)"
        ) {}

        let result = ReceivedArgumentsFactory().variableDeclaration(
            variablePrefix: variablePrefix,
            parameterList: functionDeclaration.signature.parameterClause.parameters
        )

        assertBuildResult(
            result,
            """
            var fooReceivedArguments: (completion: () -> Void, count: (x: Int, UInt?)?, price: Decimal?)?
            """
        )
    }

    func testVariableDeclarationMultiArgumentsWithSomeOptionalClosureArgument() throws {
        let variablePrefix = "foo"
        let functionDeclaration = try FunctionDeclSyntax(
            "func foo(completion: (() -> Void)?, _ count: (x: Int, UInt?)?, final price: Decimal?)"
        ) {}

        let result = ReceivedArgumentsFactory().variableDeclaration(
            variablePrefix: variablePrefix,
            parameterList: functionDeclaration.signature.parameterClause.parameters
        )

        assertBuildResult(
            result,
            """
            var fooReceivedArguments: (completion: (() -> Void)?, count: (x: Int, UInt?)?, price: Decimal?)?
            """
        )
    }

    // MARK: - Assign Value To Variable Expression

    func testAssignValueToVariableExpressionSingleArgumentFirstParameterName() throws {
        let variablePrefix = "funcName"
        let functionDeclaration = try FunctionDeclSyntax(
            "func foo(text: String)"
        ) {}

        let result = ReceivedArgumentsFactory().assignValueToVariableExpression(
            variablePrefix: variablePrefix,
            parameterList: functionDeclaration.signature.parameterClause.parameters
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

        let result = ReceivedArgumentsFactory().assignValueToVariableExpression(
            variablePrefix: variablePrefix,
            parameterList: functionDeclaration.signature.parameterClause.parameters
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

        let result = ReceivedArgumentsFactory().assignValueToVariableExpression(
            variablePrefix: variablePrefix,
            parameterList: functionDeclaration.signature.parameterClause.parameters
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

        let result = ReceivedArgumentsFactory().assignValueToVariableExpression(
            variablePrefix: variablePrefix,
            parameterList: functionDeclaration.signature.parameterClause.parameters
        )

        assertBuildResult(
            result,
            """
            fooReceivedArguments = (text, count, price)
            """
        )
    }
}
