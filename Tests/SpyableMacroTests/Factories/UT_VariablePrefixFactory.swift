import SwiftSyntax
import XCTest

@testable import SpyableMacro

final class UT_VariablePrefixFactory: XCTestCase {
  
  // MARK: - Non-Descriptive Mode Tests
  
  func testTextFunctionWithoutArguments() throws {
    try assertProtocolFunction(
      withFunctionDeclaration: "func foo() -> String",
      expectingVariableName: "foo"
    )
  }

  func testTextFunctionWithSingleArgument() throws {
    try assertProtocolFunction(
      withFunctionDeclaration: "func foo(text: String) -> String",
      expectingVariableName: "fooText"
    )
  }

  func testTextFunctionWithSingleArgumentTwoNames() throws {
    try assertProtocolFunction(
      withFunctionDeclaration: "func foo(generated text: String) -> String",
      expectingVariableName: "fooGenerated"
    )
  }

  func testTextFunctionWithSingleArgumentOnlySecondName() throws {
    try assertProtocolFunction(
      withFunctionDeclaration: "func foo(_ text: String) -> String",
      expectingVariableName: "foo"
    )
  }

  func testTextFunctionWithMultiArguments() throws {
    try assertProtocolFunction(
      withFunctionDeclaration: """
        func foo(
            text1 text2: String,
            _ count2: Int,
            product1 product2: (name: String, price: Decimal)
        ) -> String
        """,
      expectingVariableName: "fooText1Product1"
    )
  }
  
  func testTextFunctionWithMultipleUnderscoreParameters() throws {
    try assertProtocolFunction(
      withFunctionDeclaration: "func calculate(_ a: Int, _ b: Int, sum c: Int) -> Int",
      expectingVariableName: "calculateSum"
    )
  }
  
  func testTextFunctionCapitalizesParameterNames() throws {
    try assertProtocolFunction(
      withFunctionDeclaration: "func process(firstName: String, lastName: String) -> String",
      expectingVariableName: "processFirstNameLastName"
    )
  }
  
  // MARK: - Descriptive Mode Tests with Basic Return Types
  
  func testDescriptiveModeWithIntReturn() throws {
    try assertProtocolFunction(
      withFunctionDeclaration: "func calculate(value: Int) -> Int",
      expectingVariableName: "calculateValueIntInt",
      descriptive: true
    )
  }
  
  func testDescriptiveModeWithStringReturn() throws {
    try assertProtocolFunction(
      withFunctionDeclaration: "func format(text: String) -> String",
      expectingVariableName: "formatTextStringString",
      descriptive: true
    )
  }
  
  func testDescriptiveModeWithOptionalStringReturn() throws {
    try assertProtocolFunction(
      withFunctionDeclaration: "func findName(id: Int) -> String?",
      expectingVariableName: "findNameIdIntOptionalString",
      descriptive: true
    )
  }
  
  func testDescriptiveModeWithArrayReturn() throws {
    try assertProtocolFunction(
      withFunctionDeclaration: "func getItems(category: String) -> [String]",
      expectingVariableName: "getItemsCategoryStringArrayString",
      descriptive: true
    )
  }
  
  func testDescriptiveModeWithSetReturn() throws {
    try assertProtocolFunction(
      withFunctionDeclaration: "func uniqueNumbers(from: [Int]) -> Set<Int>",
      expectingVariableName: "uniqueNumbersFromArrayIntSetInt",
      descriptive: true
    )
  }
  
  func testDescriptiveModeWithDictionaryReturn() throws {
    try assertProtocolFunction(
      withFunctionDeclaration: "func mapping(keys: [String]) -> [String: Int]",
      expectingVariableName: "mappingKeysArrayStringDictionaryStringInt",
      descriptive: true
    )
  }
  
  // MARK: - Descriptive Mode Tests with Complex Types
  
  func testDescriptiveModeWithResultType() throws {
    try assertProtocolFunction(
      withFunctionDeclaration: "func fetch(url: String) -> Result<String, Error>",
      expectingVariableName: "fetchUrlStringResultStringError",
      descriptive: true
    )
  }
  
  func testDescriptiveModeWithTupleReturn() throws {
    try assertProtocolFunction(
      withFunctionDeclaration: "func parse(data: Data) -> (name: String, age: Int)",
      expectingVariableName: "parseDataDatanameStringageInt",
      descriptive: true
    )
  }
  
  func testDescriptiveModeWithNestedGenerics() throws {
    try assertProtocolFunction(
      withFunctionDeclaration: "func transform(data: [String: [Int]]) -> Dictionary<String, Array<Int>>",
      expectingVariableName: "transformDataDictionaryStringArrayIntDictionaryStringArrayInt",
      descriptive: true
    )
  }
  
  func testDescriptiveModeWithOptionalArrayReturn() throws {
    try assertProtocolFunction(
      withFunctionDeclaration: "func maybeGetItems() -> [String]?",
      expectingVariableName: "maybeGetItemsOptionalArrayString",
      descriptive: true
    )
  }
  
  func testDescriptiveModeWithDoubleOptionalReturn() throws {
    try assertProtocolFunction(
      withFunctionDeclaration: "func deepFind(key: String) -> String??",
      expectingVariableName: "deepFindKeyStringOptionalOptionalString",
      descriptive: true
    )
  }
  
  // MARK: - Descriptive Mode Tests with Parameter Types
  
  func testDescriptiveModeWithOptionalParameter() throws {
    try assertProtocolFunction(
      withFunctionDeclaration: "func process(value: Int?) -> String",
      expectingVariableName: "processValueOptionalIntString",
      descriptive: true
    )
  }
  
  func testDescriptiveModeWithGenericParameter() throws {
    try assertProtocolFunction(
      withFunctionDeclaration: "func store(items: Array<String>) -> Bool",
      expectingVariableName: "storeItemsArrayStringBool",
      descriptive: true
    )
  }
  
  func testDescriptiveModeWithMultipleComplexParameters() throws {
    try assertProtocolFunction(
      withFunctionDeclaration: "func merge(dict1: [String: Int], dict2: [String: Int]?) -> [String: Int]",
      expectingVariableName: "mergeDict1DictionaryStringIntDict2OptionalDictionaryStringIntDictionaryStringInt",
      descriptive: true
    )
  }
  
  // MARK: - Void Return Type Tests
  
  func testDescriptiveModeWithVoidReturn() throws {
    try assertProtocolFunction(
      withFunctionDeclaration: "func log(message: String)",
      expectingVariableName: "logMessageString",
      descriptive: true
    )
  }
  
  func testDescriptiveModeWithExplicitVoidReturn() throws {
    try assertProtocolFunction(
      withFunctionDeclaration: "func notify(event: String) -> Void",
      expectingVariableName: "notifyEventStringVoid",
      descriptive: true
    )
  }
  
  func testDescriptiveModeWithEmptyTupleReturn() throws {
    try assertProtocolFunction(
      withFunctionDeclaration: "func execute() -> ()",
      expectingVariableName: "execute",
      descriptive: true
    )
  }
  
  // MARK: - Character Sanitization Tests
  
  func testRemovesSpecialCharactersInDescriptiveMode() throws {
    try assertProtocolFunction(
      withFunctionDeclaration: "func convert(from: (x: Int, y: Int)) -> [String: Any]",
      expectingVariableName: "convertFromxIntyIntDictionaryStringAny",
      descriptive: true
    )
  }
  
  func testHandlesSpacesInTypeNames() throws {
    try assertProtocolFunction(
      withFunctionDeclaration: "func transform(value: Array < String >) -> Dictionary < String , Int >",
      expectingVariableName: "transformValueArrayStringDictionaryStringInt",
      descriptive: true
    )
  }
  
  // MARK: - Edge Cases
  
  func testFunctionWithNoParametersNoReturn() throws {
    try assertProtocolFunction(
      withFunctionDeclaration: "func doSomething()",
      expectingVariableName: "doSomething"
    )
  }
  
  func testFunctionWithNoParametersNoReturnDescriptive() throws {
    try assertProtocolFunction(
      withFunctionDeclaration: "func doSomething()",
      expectingVariableName: "doSomething",
      descriptive: true
    )
  }
  
  func testFunctionWithAllUnderscoreParameters() throws {
    try assertProtocolFunction(
      withFunctionDeclaration: "func compute(_ x: Int, _ y: Int, _ z: Int) -> Int",
      expectingVariableName: "compute"
    )
  }
  
  func testFunctionWithAllUnderscoreParametersDescriptive() throws {
    try assertProtocolFunction(
      withFunctionDeclaration: "func compute(_ x: Int, _ y: Int, _ z: Int) -> Int",
      expectingVariableName: "computeInt",
      descriptive: true
    )
  }
  
  func testFunctionWithComplexNestedOptionals() throws {
    try assertProtocolFunction(
      withFunctionDeclaration: "func find(in collection: [[String?]?]) -> [String?]??",
      expectingVariableName: "findInArrayOptionalArrayOptionalStringOptionalOptionalArrayOptionalString",
      descriptive: true
    )
  }
  
  func testFunctionWithCustomTypes() throws {
    try assertProtocolFunction(
      withFunctionDeclaration: "func create(config: MyConfig, delegate: MyDelegate?) -> MyObject",
      expectingVariableName: "createConfigMyConfigDelegateOptionalMyDelegateMyObject",
      descriptive: true
    )
  }
  
  func testFunctionWithProtocolComposition() throws {
    try assertProtocolFunction(
      withFunctionDeclaration: "func combine(objects: [Codable & Hashable]) -> any Codable",
      expectingVariableName: "combineObjectsArrayCodableHashableanyCodable",
      descriptive: true
    )
  }
  
  func testFunctionWithSomeKeyword() throws {
    try assertProtocolFunction(
      withFunctionDeclaration: "func opaque() -> some View",
      expectingVariableName: "opaquesomeView",
      descriptive: true
    )
  }
  
  func testFunctionWithEscapingClosure() throws {
    try assertProtocolFunction(
      withFunctionDeclaration: "func async(completion: @escaping (Result<String, Error>) -> Void)",
      expectingVariableName: "asyncCompletionescapingResultStringErrorVoid",
      descriptive: true
    )
  }
  
  func testFunctionWithInoutParameter() throws {
    try assertProtocolFunction(
      withFunctionDeclaration: "func modify(value: inout String)",
      expectingVariableName: "modifyValueinoutString",
      descriptive: true
    )
  }
  
  // MARK: - Helper Methods for Assertions

  private func assertProtocolFunction(
    withFunctionDeclaration functionDeclaration: String,
    expectingVariableName expectedName: String,
    descriptive: Bool = false,
    file: StaticString = #file,
    line: UInt = #line
  ) throws {
    let protocolFunctionDeclaration = try FunctionDeclSyntax("\(raw: functionDeclaration)") {}

    let result = VariablePrefixFactory().text(for: protocolFunctionDeclaration, descriptive: descriptive)

    XCTAssertEqual(result, expectedName, file: file, line: line)
  }
}