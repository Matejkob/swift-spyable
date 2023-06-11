final class ViewModel {
    var receivedData: (productName: String, count: UInt)?

    private let service: ServiceProtocol

    init(service: ServiceProtocol) {
        self.service = service
    }

    func fetchData() {
        receivedData = service.executeNetworkingRequest(query: "some_query")
    }
}
