import Spyable

// MARK: - Open

// Only classes and overridable class members can be declared 'open'.

// MARK: - Public

@Spyable
public protocol PublicServiceProtocol {
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

func testPublicServiceProtocol() {
  let spy = PublicServiceProtocolSpy()

  spy.name = "Spy"
}

// MARK: - Package

@Spyable
package protocol PackageServiceProtocol {
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

func testPackageServiceProtocol() {
  let spy = PackageServiceProtocolSpy()

  spy.name = "Spy"
}

// MARK: - Internal

@Spyable
internal protocol InternalServiceProtocol {
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

func testInternalServiceProtocol() {
  let spy = InternalServiceProtocolSpy()

  spy.name = "Spy"
}

// MARK: - Fileprivate

@Spyable
// swiftformat:disable:next
private protocol FileprivateServiceProtocol {
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

func testFileprivateServiceProtocol() {
  let spy = FileprivateServiceProtocolSpy()

  spy.name = "Spy"
}

// MARK: - Private

@Spyable
private protocol PrivateServiceProtocol {
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

func testPrivateServiceProtocol() {
  let spy = PrivateServiceProtocolSpy()

  spy.name = "Spy"
}
