import Spyable

@Spyable(behindPreprocessorFlag: "DEBUG")
protocol ServiceProtocol {
  var name: String { get }
  var anyProtocol: any Codable { get set }
  var secondName: String? { get }
  var added: () -> Void { get set }
  var removed: (() -> Void)? { get set }

  func initialize(name: String, _ secondName: String?)
  func fetchConfig(arg: UInt8) async throws -> [String: String]
  func fetchData(_ name: (String, count: Int)) async -> (() -> Void)
  func wrapDataInArray<T>(_ data: T) -> Array<T>
}

final class ViewModel {
  private let service: ServiceProtocol

  var config: [String: String] = [:]

  init(service: ServiceProtocol) {
    self.service = service
  }

  func initializeService(with name: String) {
    service.initialize(name: name, nil)
  }

  func saveConfig() async throws {
    if config.isEmpty {
      let result = try await service.fetchConfig(arg: 1)
      config = result

      return
    }

    _ = try await service.fetchConfig(arg: 2)
    config.removeAll()
  }
  
  func wrapData<T>(_ data: T) -> Array<T> {
    service.wrapDataInArray(data)
  }
}
