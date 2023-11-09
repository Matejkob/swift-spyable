/// The `@Spyable` macro generates a test spy class for the protocol to which it is attached.
/// A spy is a type of test double that observes and records interactions for later verification in your tests.
///
/// The `@Spyable` macro simplifies the task of writing test spies manually. It automatically generates a new
/// class (the spy) that implements the given protocol. It tracks and exposes information about how the protocol's
/// methods and properties were used, providing valuable insight for test assertions.
///
/// Usage:
/// ```swift
/// @Spyable
/// protocol ServiceProtocol {
///     var data: Data { get }
///     func fetchData(id: String) -> Data
/// }
/// ```
///
/// This example would generate a spy class named `ServiceProtocolSpy` that implements `ServiceProtocol`.
/// The generated class includes properties and methods for tracking the number of method calls, the arguments
/// passed, whether the method was called, and so on.
///
/// Example of generated code:
/// ```swift
/// class ServiceProtocolSpy: ServiceProtocol {
///     var data: Data {
///         get { underlyingData }
///         set { underlyingData = newValue }
///     }
///     var underlyingData: Data!
///
///     var fetchDataIdCallsCount = 0
///     var fetchDataIdCalled: Bool {
///         return fetchDataIdCallsCount > 0
///     }
///     var fetchDataIdReceivedArguments: String?
///     var fetchDataIdReceivedInvocations: [String] = []
///     var fetchDataIdReturnValue: Data!
///     var fetchDataIdClosure: ((String) -> Data)?
///
///     func fetchData(id: String) -> Data {
///         fetchDataIdCallsCount += 1
///         fetchDataIdReceivedArguments = id
///         fetchDataIdReceivedInvocations.append(id)
///         if fetchDataIdClosure != nil {
///             return fetchDataIdClosure!(id)
///         } else {
///             return fetchDataIdReturnValue
///         }
///     }
/// }
/// ```
///
/// - NOTE: The `@Spyable` macro should only be applied to protocols. Applying it to other
///         declarations will result in an error.
@attached(peer, names: suffixed(Spy))
public macro Spyable() =
  #externalMacro(
    module: "SpyableMacro",
    type: "SpyableMacro"
  )
