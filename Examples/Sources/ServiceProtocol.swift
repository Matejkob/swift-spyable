import Spyable

@Spyable
protocol ServiceProtocol {
    func executeNetworkingRequest(query: String) -> (productName: String, count: UInt)
}
