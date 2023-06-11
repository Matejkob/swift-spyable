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

    func testFetchData() {
        let expectedData = (productName: "iPhone", count: UInt(4))

        serviceSpy.executeNetworkingRequestWithQueryReturnValue = expectedData

        sut.fetchData()

        XCTAssertEqual(sut.receivedData?.productName, expectedData.productName)
        XCTAssertEqual(sut.receivedData?.count, expectedData.count)
        XCTAssertEqual(serviceSpy.executeNetworkingRequestWithQueryCallsCount, 1)
    }
}
