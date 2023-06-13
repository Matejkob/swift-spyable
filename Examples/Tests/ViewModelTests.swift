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

        XCTAssertTrue(serviceSpy.initializeWithNameSecondNameCalled)
        XCTAssertEqual(serviceSpy.initializeWithNameSecondNameReceivedArguments?.name, serviceName)
    }

    func testSaveConfig() async throws {
        let expectedConfig: [String: String] = ["key": "value"]

        serviceSpy.fetchConfigWithArgReturnValue = expectedConfig

        try await sut.saveConfig()

        XCTAssertEqual(sut.config, expectedConfig)

        XCTAssertEqual(serviceSpy.fetchConfigWithArgCallsCount, 1)
        XCTAssertEqual(serviceSpy.fetchConfigWithArgReceivedInvocations, [1])

        try await sut.saveConfig()

        XCTAssertTrue(sut.config.isEmpty)

        XCTAssertEqual(serviceSpy.fetchConfigWithArgCallsCount, 2)
        XCTAssertEqual(serviceSpy.fetchConfigWithArgReceivedInvocations, [1, 2])
    }
}
