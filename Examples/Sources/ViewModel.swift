import Spyable

@Spyable(behindPreprocessorFlag: "DEBUG", accessLevel: .public)
protocol ServiceProtocol {
  var name: String { get }
  var anyProtocol: any Codable { get set }
  var secondName: String? { get }
  var address: String! { get }
  var added: () -> Void { get set }
  var removed: (() -> Void)? { get set }

  func initialize(name: String, _ secondName: String?)
  func fetchConfig(arg: UInt8) async throws -> [String: String]
  func fetchData(_ name: (String, count: Int)) async -> (() -> Void)
  func save(name: any Codable, surname: any Codable)
  func insert(name: (any Codable)?, surname: (any Codable)?)
  func append(name: (any Codable) -> (any Codable)?)
  func get() async throws -> any Codable
  func read() -> String!
  func wrapDataInArray<T>(_ data: T) -> [T]
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

  func wrapData<T>(_ data: T) -> [T] {
    service.wrapDataInArray(data)
  }
}
