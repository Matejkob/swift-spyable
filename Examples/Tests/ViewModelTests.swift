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
        let expectedConfig: [String: String] = ["key": "value"]

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
}
