import XCTest

@testable import Examples

final class ViewModelTests: XCTestCase {
  var serviceSpy: ServiceProtocolSpy!
  var sut: ViewModel!

  override func setUp() {
    super.setUp()
    serviceSpy = ServiceProtocolSpy()
    sut = ViewModel(service: serviceSpy)
  }

  func testInitializeService() {
    let serviceName = "service_name"

    sut.initializeService(with: serviceName)

    XCTAssertTrue(serviceSpy.initializeNameCalled)
    XCTAssertEqual(serviceSpy.initializeNameReceivedArguments?.name, serviceName)
  }

  func testSaveConfig() async throws {
    let expectedConfig = ["key": "value"]

    serviceSpy.fetchConfigArgReturnValue = expectedConfig

    try await sut.saveConfig()

    XCTAssertEqual(sut.config, expectedConfig)

    XCTAssertEqual(serviceSpy.fetchConfigArgCallsCount, 1)
    XCTAssertEqual(serviceSpy.fetchConfigArgReceivedInvocations, [1])

    try await sut.saveConfig()

    XCTAssertTrue(sut.config.isEmpty)

    XCTAssertEqual(serviceSpy.fetchConfigArgCallsCount, 2)
    XCTAssertEqual(serviceSpy.fetchConfigArgReceivedInvocations, [1, 2])
  }

  func testThrowableError() async throws {
    serviceSpy.fetchConfigArgThrowableError = CustomError.expected

    do {
      try await sut.saveConfig()
      XCTFail("An error should have been thrown by the sut")
    } catch CustomError.expected {
      XCTAssertEqual(serviceSpy.fetchConfigArgCallsCount, 1)
      XCTAssertEqual(serviceSpy.fetchConfigArgReceivedInvocations, [1])
      XCTAssertTrue(sut.config.isEmpty)
    } catch {
      XCTFail("Unexpected error catched")
    }
  }

  func testWrapData() {
    // Important: When using generics, mocked return value types must match the types that are being returned in the use of the spy.
    serviceSpy.wrapDataInArrayReturnValue = [123]
    XCTAssertEqual(sut.wrapData(1), [123])
    XCTAssertEqual(serviceSpy.wrapDataInArrayReceivedData as? Int, 1)
    
    // ⚠️ The following would cause a fatal error, because an Array<String> will be returned by wrapData(), but we provided an Array<Int> to wrapDataInArrayReturnValue. ⚠️
    // XCTAssertEqual(sut.wrapData("hi"), ["hello"])
  }
}

extension ViewModelTests {
  enum CustomError: Error {
    case expected
  }
}
