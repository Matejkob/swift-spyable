import XCTest

@testable import Examples

/// Manual test to verify polymorphism works - simplified version
final class PolymorphismManualTest: XCTestCase {

  func testPolymorphismBasicExample() {
    // This test demonstrates the key polymorphism features
    let spy = DataProcessorProtocolSpy()

    // Example 1: Different parameter types generate different spy methods
    spy.computeValueStringStringReturnValue = "String processed"
    spy.computeValueIntStringReturnValue = "Int processed"
    spy.computeValueBoolStringReturnValue = "Bool processed"

    // Call the overloaded methods
    let stringResult = spy.compute(value: "test")
    let intResult = spy.compute(value: 42)
    let boolResult = spy.compute(value: true)

    // Verify the results
    XCTAssertEqual(stringResult, "String processed")
    XCTAssertEqual(intResult, "Int processed")
    XCTAssertEqual(boolResult, "Bool processed")

    // Verify each overload was called exactly once
    XCTAssertEqual(spy.computeValueStringStringCallsCount, 1)
    XCTAssertEqual(spy.computeValueIntStringCallsCount, 1)
    XCTAssertEqual(spy.computeValueBoolStringCallsCount, 1)

    // Verify arguments were captured correctly
    XCTAssertEqual(spy.computeValueStringStringReceivedValue, "test")
    XCTAssertEqual(spy.computeValueIntStringReceivedValue, 42)
    XCTAssertEqual(spy.computeValueBoolStringReceivedValue, true)
  }

  func testPolymorphismReturnTypeDifferentiation() {
    // This test demonstrates same parameter type, different return types
    let spy = DataProcessorProtocolSpy()

    // Setup different return values for each overload
    spy.convertValueIntBoolReturnValue = true
    spy.convertValueIntStringReturnValue = "converted"
    spy.convertValueIntArrayIntReturnValue = [1, 2, 3]

    // Call the overloaded methods (same parameter, different return types)
    let boolResult: Bool = spy.convert(value: 10)
    let stringResult: String = spy.convert(value: 10)
    let arrayResult: [Int] = spy.convert(value: 10)

    // Verify the results
    XCTAssertEqual(boolResult, true)
    XCTAssertEqual(stringResult, "converted")
    XCTAssertEqual(arrayResult, [1, 2, 3])

    // Verify each overload was called exactly once
    XCTAssertEqual(spy.convertValueIntBoolCallsCount, 1)
    XCTAssertEqual(spy.convertValueIntStringCallsCount, 1)
    XCTAssertEqual(spy.convertValueIntArrayIntCallsCount, 1)
  }

  func testPolymorphismParameterNameDifferentiation() {
    // This test demonstrates same parameter type/name, different parameter labels
    let spy = DataProcessorProtocolSpy()

    // Setup different return values for each overload
    spy.processDataReturnValue = "data processed"
    spy.processItemReturnValue = "item processed"
    spy.processContentReturnValue = "content processed"

    // Call the overloaded methods (different parameter labels)
    let dataResult = spy.process(data: "test")
    let itemResult = spy.process(item: "test")
    let contentResult = spy.process(content: "test")

    // Verify the results
    XCTAssertEqual(dataResult, "data processed")
    XCTAssertEqual(itemResult, "item processed")
    XCTAssertEqual(contentResult, "content processed")

    // Verify each overload was called exactly once
    XCTAssertEqual(spy.processDataCallsCount, 1)
    XCTAssertEqual(spy.processItemCallsCount, 1)
    XCTAssertEqual(spy.processContentCallsCount, 1)

    // Verify the correct parameter was captured for each overload
    XCTAssertEqual(spy.processDataReceivedData, "test")
    XCTAssertEqual(spy.processItemReceivedItem, "test")
    XCTAssertEqual(spy.processContentReceivedContent, "test")
  }

  func testPolymorphismAsyncMethods() async {
    // This test demonstrates async method polymorphism
    let spy = DataProcessorProtocolSpy()

    // Setup return values for async methods
    spy.fetchIdStringStringReturnValue = "string fetch result"
    spy.fetchIdIntStringReturnValue = "int fetch result"

    // Call the async overloaded methods
    let stringResult = await spy.fetch(id: "test-id")
    let intResult = await spy.fetch(id: 123)

    // Verify the results
    XCTAssertEqual(stringResult, "string fetch result")
    XCTAssertEqual(intResult, "int fetch result")

    // Verify each async overload was called exactly once
    XCTAssertEqual(spy.fetchIdStringStringCallsCount, 1)
    XCTAssertEqual(spy.fetchIdIntStringCallsCount, 1)

    // Verify the correct parameters were captured
    XCTAssertEqual(spy.fetchIdStringStringReceivedId, "test-id")
    XCTAssertEqual(spy.fetchIdIntStringReceivedId, 123)
  }

  func testPolymorphismThrowingMethods() throws {
    // This test demonstrates throwing method polymorphism
    let spy = DataProcessorProtocolSpy()

    // Setup return values for throwing methods
    spy.validateInputStringBoolReturnValue = true
    spy.validateInputIntBoolReturnValue = false

    // Call the throwing overloaded methods
    let stringResult = try spy.validate(input: "valid")
    let intResult = try spy.validate(input: 42)

    // Verify the results
    XCTAssertEqual(stringResult, true)
    XCTAssertEqual(intResult, false)

    // Verify each throwing overload was called exactly once
    XCTAssertEqual(spy.validateInputStringBoolCallsCount, 1)
    XCTAssertEqual(spy.validateInputIntBoolCallsCount, 1)

    // Verify the correct parameters were captured
    XCTAssertEqual(spy.validateInputStringBoolReceivedInput, "valid")
    XCTAssertEqual(spy.validateInputIntBoolReceivedInput, 42)
  }

  func testPolymorphismThrowingErrors() {
    // This test demonstrates error throwing with polymorphic methods
    let spy = DataProcessorProtocolSpy()

    // Setup error to be thrown
    spy.validateInputStringBoolThrowableError = ProcessingError.invalidInput

    // Verify the error is thrown
    XCTAssertThrowsError(try spy.validate(input: "invalid")) { error in
      XCTAssertEqual(error as? ProcessingError, ProcessingError.invalidInput)
    }

    // Verify the method was called
    XCTAssertEqual(spy.validateInputStringBoolCallsCount, 1)
    XCTAssertEqual(spy.validateInputStringBoolReceivedInput, "invalid")
  }
}
