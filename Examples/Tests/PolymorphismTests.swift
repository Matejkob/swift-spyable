import XCTest

@testable import Examples

final class PolymorphismTests: XCTestCase {
  var processorSpy: DataProcessorProtocolSpy!
  var sut: DataProcessor!

  override func setUp() {
    super.setUp()
    processorSpy = DataProcessorProtocolSpy()
    sut = DataProcessor(processor: processorSpy)
  }

  // MARK: - Compute Methods with Different Parameter Types

  func testComputeStringValue() {
    let inputValue = "test string"
    let expectedResult = "processed: test string"

    // Setup spy return value
    processorSpy.computeValueStringStringReturnValue = expectedResult

    // Execute
    let result = sut.computeStringValue(inputValue)

    // Verify
    XCTAssertEqual(result, expectedResult)
    XCTAssertTrue(processorSpy.computeValueStringStringCalled)
    XCTAssertEqual(processorSpy.computeValueStringStringCallsCount, 1)
    XCTAssertEqual(processorSpy.computeValueStringStringReceivedValue, inputValue)
    XCTAssertEqual(processorSpy.computeValueStringStringReceivedInvocations, [inputValue])
  }

  func testComputeIntValue() {
    let inputValue = 42
    let expectedResult = "processed: 42"

    // Setup spy return value
    processorSpy.computeValueIntStringReturnValue = expectedResult

    // Execute
    let result = sut.computeIntValue(inputValue)

    // Verify
    XCTAssertEqual(result, expectedResult)
    XCTAssertTrue(processorSpy.computeValueIntStringCalled)
    XCTAssertEqual(processorSpy.computeValueIntStringCallsCount, 1)
    XCTAssertEqual(processorSpy.computeValueIntStringReceivedValue, inputValue)
    XCTAssertEqual(processorSpy.computeValueIntStringReceivedInvocations, [inputValue])
  }

  func testComputeBoolValue() {
    let inputValue = true
    let expectedResult = "processed: true"

    // Setup spy return value
    processorSpy.computeValueBoolStringReturnValue = expectedResult

    // Execute
    let result = sut.computeBoolValue(inputValue)

    // Verify
    XCTAssertEqual(result, expectedResult)
    XCTAssertTrue(processorSpy.computeValueBoolStringCalled)
    XCTAssertEqual(processorSpy.computeValueBoolStringCallsCount, 1)
    XCTAssertEqual(processorSpy.computeValueBoolStringReceivedValue, inputValue)
    XCTAssertEqual(processorSpy.computeValueBoolStringReceivedInvocations, [inputValue])
  }

  // MARK: - Convert Methods with Same Parameter Type, Different Return Types

  func testConvertToBool() {
    let inputValue = 1
    let expectedResult = true

    // Setup spy return value
    processorSpy.convertValueIntBoolReturnValue = expectedResult

    // Execute
    let result = sut.convertToBool(inputValue)

    // Verify
    XCTAssertEqual(result, expectedResult)
    XCTAssertTrue(processorSpy.convertValueIntBoolCalled)
    XCTAssertEqual(processorSpy.convertValueIntBoolCallsCount, 1)
    XCTAssertEqual(processorSpy.convertValueIntBoolReceivedValue, inputValue)
    XCTAssertEqual(processorSpy.convertValueIntBoolReceivedInvocations, [inputValue])
  }

  func testConvertToString() {
    let inputValue = 123
    let expectedResult = "123"

    // Setup spy return value
    processorSpy.convertValueIntStringReturnValue = expectedResult

    // Execute
    let result = sut.convertToString(inputValue)

    // Verify
    XCTAssertEqual(result, expectedResult)
    XCTAssertTrue(processorSpy.convertValueIntStringCalled)
    XCTAssertEqual(processorSpy.convertValueIntStringCallsCount, 1)
    XCTAssertEqual(processorSpy.convertValueIntStringReceivedValue, inputValue)
    XCTAssertEqual(processorSpy.convertValueIntStringReceivedInvocations, [inputValue])
  }

  func testConvertToArray() {
    let inputValue = 5
    let expectedResult = [1, 2, 3, 4, 5]

    // Setup spy return value
    processorSpy.convertValueIntArrayIntReturnValue = expectedResult

    // Execute
    let result = sut.convertToArray(inputValue)

    // Verify
    XCTAssertEqual(result, expectedResult)
    XCTAssertTrue(processorSpy.convertValueIntArrayIntCalled)
    XCTAssertEqual(processorSpy.convertValueIntArrayIntCallsCount, 1)
    XCTAssertEqual(processorSpy.convertValueIntArrayIntReceivedValue, inputValue)
    XCTAssertEqual(processorSpy.convertValueIntArrayIntReceivedInvocations, [inputValue])
  }

  // MARK: - Async Methods with Different Parameter Types

  func testFetchStringDataAsync() async {
    let inputId = "string-id"
    let expectedResult = "fetched string data"

    // Setup spy return value
    processorSpy.fetchIdStringStringReturnValue = expectedResult

    // Execute
    let result = await sut.fetchStringData(id: inputId)

    // Verify
    XCTAssertEqual(result, expectedResult)
    XCTAssertTrue(processorSpy.fetchIdStringStringCalled)
    XCTAssertEqual(processorSpy.fetchIdStringStringCallsCount, 1)
    XCTAssertEqual(processorSpy.fetchIdStringStringReceivedId, inputId)
    XCTAssertEqual(processorSpy.fetchIdStringStringReceivedInvocations, [inputId])
  }

  func testFetchIntDataAsync() async {
    let inputId = 123
    let expectedResult = "fetched int data"

    // Setup spy return value
    processorSpy.fetchIdIntStringReturnValue = expectedResult

    // Execute
    let result = await sut.fetchIntData(id: inputId)

    // Verify
    XCTAssertEqual(result, expectedResult)
    XCTAssertTrue(processorSpy.fetchIdIntStringCalled)
    XCTAssertEqual(processorSpy.fetchIdIntStringCallsCount, 1)
    XCTAssertEqual(processorSpy.fetchIdIntStringReceivedId, inputId)
    XCTAssertEqual(processorSpy.fetchIdIntStringReceivedInvocations, [inputId])
  }

  // MARK: - Throwing Methods with Different Parameter Types

  func testValidateString() throws {
    let inputString = "valid string"
    let expectedResult = true

    // Setup spy return value
    processorSpy.validateInputStringBoolReturnValue = expectedResult

    // Execute
    let result = try sut.validateString(inputString)

    // Verify
    XCTAssertEqual(result, expectedResult)
    XCTAssertTrue(processorSpy.validateInputStringBoolCalled)
    XCTAssertEqual(processorSpy.validateInputStringBoolCallsCount, 1)
    XCTAssertEqual(processorSpy.validateInputStringBoolReceivedInput, inputString)
    XCTAssertEqual(processorSpy.validateInputStringBoolReceivedInvocations, [inputString])
  }

  func testValidateInt() throws {
    let inputInt = 42
    let expectedResult = true

    // Setup spy return value
    processorSpy.validateInputIntBoolReturnValue = expectedResult

    // Execute
    let result = try sut.validateInt(inputInt)

    // Verify
    XCTAssertEqual(result, expectedResult)
    XCTAssertTrue(processorSpy.validateInputIntBoolCalled)
    XCTAssertEqual(processorSpy.validateInputIntBoolCallsCount, 1)
    XCTAssertEqual(processorSpy.validateInputIntBoolReceivedInput, inputInt)
    XCTAssertEqual(processorSpy.validateInputIntBoolReceivedInvocations, [inputInt])
  }

  func testValidateThrowingError() {
    let inputString = "invalid"
    let expectedError = ProcessingError.invalidInput

    // Setup spy to throw error
    processorSpy.validateInputStringBoolThrowableError = expectedError

    // Execute & Verify
    XCTAssertThrowsError(try sut.validateString(inputString)) { error in
      XCTAssertEqual(error as? ProcessingError, expectedError)
    }

    XCTAssertTrue(processorSpy.validateInputStringBoolCalled)
    XCTAssertEqual(processorSpy.validateInputStringBoolCallsCount, 1)
    XCTAssertEqual(processorSpy.validateInputStringBoolReceivedInput, inputString)
  }

  // MARK: - Process Methods with Different Parameter Names

  func testProcessData() {
    let inputData = "test data"
    let expectedResult = "processed data"

    // Setup spy return value
    processorSpy.processDataReturnValue = expectedResult

    // Execute
    let result = sut.processData(inputData)

    // Verify
    XCTAssertEqual(result, expectedResult)
    XCTAssertTrue(processorSpy.processDataCalled)
    XCTAssertEqual(processorSpy.processDataCallsCount, 1)
    XCTAssertEqual(processorSpy.processDataReceivedData, inputData)
    XCTAssertEqual(processorSpy.processDataReceivedInvocations, [inputData])
  }

  func testProcessItem() {
    let inputItem = "test item"
    let expectedResult = "processed item"

    // Setup spy return value
    processorSpy.processItemReturnValue = expectedResult

    // Execute
    let result = sut.processItem(inputItem)

    // Verify
    XCTAssertEqual(result, expectedResult)
    XCTAssertTrue(processorSpy.processItemCalled)
    XCTAssertEqual(processorSpy.processItemCallsCount, 1)
    XCTAssertEqual(processorSpy.processItemReceivedItem, inputItem)
    XCTAssertEqual(processorSpy.processItemReceivedInvocations, [inputItem])
  }

  func testProcessContent() {
    let inputContent = "test content"
    let expectedResult = "processed content"

    // Setup spy return value
    processorSpy.processContentReturnValue = expectedResult

    // Execute
    let result = sut.processContent(inputContent)

    // Verify
    XCTAssertEqual(result, expectedResult)
    XCTAssertTrue(processorSpy.processContentCalled)
    XCTAssertEqual(processorSpy.processContentCallsCount, 1)
    XCTAssertEqual(processorSpy.processContentReceivedContent, inputContent)
    XCTAssertEqual(processorSpy.processContentReceivedInvocations, [inputContent])
  }

  // MARK: - Testing Multiple Calls to Same Overloaded Method

  func testMultipleCallsToSameOverloadedMethod() {
    let input1 = "first"
    let input2 = "second"
    let expectedResult1 = "result1"
    let expectedResult2 = "result2"

    // Setup spy return values using closure for different results
    var callCount = 0
    processorSpy.computeValueStringStringClosure = { value in
      callCount += 1
      return callCount == 1 ? expectedResult1 : expectedResult2
    }

    // Execute
    let result1 = sut.computeStringValue(input1)
    let result2 = sut.computeStringValue(input2)

    // Verify
    XCTAssertEqual(result1, expectedResult1)
    XCTAssertEqual(result2, expectedResult2)
    XCTAssertEqual(processorSpy.computeValueStringStringCallsCount, 2)
    XCTAssertEqual(processorSpy.computeValueStringStringReceivedInvocations, [input1, input2])
  }

  // MARK: - Testing Different Overloads Are Tracked Separately

  func testDifferentOverloadsAreTrackedSeparately() {
    let stringValue = "test"
    let intValue = 42
    let boolValue = true

    // Setup spy return values
    processorSpy.computeValueStringStringReturnValue = "string result"
    processorSpy.computeValueIntStringReturnValue = "int result"
    processorSpy.computeValueBoolStringReturnValue = "bool result"

    // Execute
    _ = sut.computeStringValue(stringValue)
    _ = sut.computeIntValue(intValue)
    _ = sut.computeBoolValue(boolValue)

    // Verify each overload is tracked separately
    XCTAssertEqual(processorSpy.computeValueStringStringCallsCount, 1)
    XCTAssertEqual(processorSpy.computeValueIntStringCallsCount, 1)
    XCTAssertEqual(processorSpy.computeValueBoolStringCallsCount, 1)

    XCTAssertEqual(processorSpy.computeValueStringStringReceivedValue, stringValue)
    XCTAssertEqual(processorSpy.computeValueIntStringReceivedValue, intValue)
    XCTAssertEqual(processorSpy.computeValueBoolStringReceivedValue, boolValue)
  }

  // MARK: - Testing Return Type Differentiation

  func testReturnTypeDifferentiation() {
    let inputValue = 10

    // Setup spy return values for different return types
    processorSpy.convertValueIntBoolReturnValue = true
    processorSpy.convertValueIntStringReturnValue = "converted"
    processorSpy.convertValueIntArrayIntReturnValue = [1, 2, 3]

    // Execute each overload
    let boolResult = sut.convertToBool(inputValue)
    let stringResult = sut.convertToString(inputValue)
    let arrayResult = sut.convertToArray(inputValue)

    // Verify results
    XCTAssertEqual(boolResult, true)
    XCTAssertEqual(stringResult, "converted")
    XCTAssertEqual(arrayResult, [1, 2, 3])

    // Verify each overload was called exactly once
    XCTAssertEqual(processorSpy.convertValueIntBoolCallsCount, 1)
    XCTAssertEqual(processorSpy.convertValueIntStringCallsCount, 1)
    XCTAssertEqual(processorSpy.convertValueIntArrayIntCallsCount, 1)

    // Verify same input was received by all overloads
    XCTAssertEqual(processorSpy.convertValueIntBoolReceivedValue, inputValue)
    XCTAssertEqual(processorSpy.convertValueIntStringReceivedValue, inputValue)
    XCTAssertEqual(processorSpy.convertValueIntArrayIntReceivedValue, inputValue)
  }

  // MARK: - Testing Parameter Name Differentiation

  func testParameterNameDifferentiation() {
    let inputString = "test"

    // Setup spy return values
    processorSpy.processDataReturnValue = "data processed"
    processorSpy.processItemReturnValue = "item processed"
    processorSpy.processContentReturnValue = "content processed"

    // Execute each overload
    let dataResult = sut.processData(inputString)
    let itemResult = sut.processItem(inputString)
    let contentResult = sut.processContent(inputString)

    // Verify results
    XCTAssertEqual(dataResult, "data processed")
    XCTAssertEqual(itemResult, "item processed")
    XCTAssertEqual(contentResult, "content processed")

    // Verify each overload was called exactly once
    XCTAssertEqual(processorSpy.processDataCallsCount, 1)
    XCTAssertEqual(processorSpy.processItemCallsCount, 1)
    XCTAssertEqual(processorSpy.processContentCallsCount, 1)

    // Verify same input was received by all overloads but with different parameter names
    XCTAssertEqual(processorSpy.processDataReceivedData, inputString)
    XCTAssertEqual(processorSpy.processItemReceivedItem, inputString)
    XCTAssertEqual(processorSpy.processContentReceivedContent, inputString)
  }
}
