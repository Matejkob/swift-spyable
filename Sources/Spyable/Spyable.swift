/// The `@Spyable` macro generates a class that implements the protocol to which it is attached.
///
/// Originally designed for creating spies in testing, this macro has become a versatile tool for generating
/// protocol implementations. It is widely used for testing (as a spy that tracks and records interactions),
/// SwiftUI previews, and other scenarios where a quick, dummy implementation of a protocol is needed.
///
/// By automating the creation of protocol-conforming classes, the `@Spyable` macro saves time and ensures
/// consistency, making it an invaluable tool for testing, prototyping, and development workflows.
///
/// ### Usage:
/// ```swift
/// @Spyable
/// public protocol ServiceProtocol {
///     var data: Data { get }
///     func fetchData(id: String) -> Data
/// }
/// ```
///
/// This example generates a spy class named `ServiceProtocolSpy` that implements `ServiceProtocol`.
/// The generated class includes properties and methods for tracking the number of method calls, the arguments
/// passed, whether the method was called, and so on.
///
/// ### Example of generated code:
/// ```swift
/// public class ServiceProtocolSpy: ServiceProtocol {
///     public var data: Data {
///         get { underlyingData }
///         set { underlyingData = newValue }
///     }
///     public var underlyingData: Data!
///
///     public var fetchDataIdCallsCount = 0
///     public var fetchDataIdCalled: Bool {
///         return fetchDataIdCallsCount > 0
///     }
///     public var fetchDataIdReceivedArguments: String?
///     public var fetchDataIdReceivedInvocations: [String] = []
///     public var fetchDataIdReturnValue: Data!
///     public var fetchDataIdClosure: ((String) -> Data)?
///
///     public func fetchData(id: String) -> Data {
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
/// ### Access Level Inheritance:
/// By default, the spy class inherits the access level of the protocol. For example:
/// ```swift
/// @Spyable
/// internal protocol InternalServiceProtocol {
///     func performTask()
/// }
/// ```
/// This will generate:
/// ```swift
/// internal class InternalServiceProtocolSpy: InternalServiceProtocol {
///     internal func performTask() { ... }
/// }
/// ```
/// If the protocol is declared `private`, the spy will be generated as `fileprivate`:
/// ```swift
/// @Spyable
/// private protocol PrivateServiceProtocol {
///     func performTask()
/// }
/// ```
/// Generates:
/// ```swift
/// fileprivate class PrivateServiceProtocolSpy: PrivateServiceProtocol {
///     fileprivate func performTask() { ... }
/// }
/// ```
///
/// ### Parameters:
/// - `behindPreprocessorFlag` (optional):
///   Wraps the generated spy class in a preprocessor flag (e.g., `#if DEBUG`).
///   Defaults to `nil`.
///   Example:
///   ```swift
///   @Spyable(behindPreprocessorFlag: "DEBUG")
///   protocol DebugProtocol {
///       func debugTask()
///   }
///   ```
///   Generates:
///   ```swift
///   #if DEBUG
///   class DebugProtocolSpy: DebugProtocol {
///       func debugTask() { ... }
///   }
///   #endif
///   ```
///
/// - `accessLevel` (optional):
///   Allows explicit control over the access level of the generated spy class. If provided, this overrides
///   the access level inherited from the protocol. Supported values: `.public`, `.package`, `.internal`, `.fileprivate`, `.private`.
///   Example:
///   ```swift
///   @Spyable(accessLevel: .public)
///   protocol PublicServiceProtocol {
///       func performTask()
///   }
///   ```
///   Generates:
///   ```swift
///   public class PublicServiceProtocolSpy: PublicServiceProtocol {
///       public func performTask() { ... }
///   }
///   ```
///   Example overriding inherited access level:
///   ```swift
///   @Spyable(accessLevel: .fileprivate)
///   public protocol CustomAccessProtocol {
///       func restrictedTask()
///   }
///   ```
///   Generates:
///   ```swift
///   fileprivate class CustomAccessProtocolSpy: CustomAccessProtocol {
///       fileprivate func restrictedTask() { ... }
///   }
///   ```
///
/// ### Notes:
/// - The `@Spyable` macro should only be applied to protocols. Applying it to other declarations will result in an error.
/// - The generated spy class name is suffixed with `Spy` (e.g., `ServiceProtocolSpy`).
///
@attached(peer, names: suffixed(Spy))
public macro Spyable(
  behindPreprocessorFlag: String? = nil,
  accessLevel: SpyAccessLevel? = nil,
  inheritedTypes: String? = nil
) =
  #externalMacro(
    module: "SpyableMacro",
    type: "SpyableMacro"
  )

/// Enum defining supported access levels for the `@Spyable` macro.
public enum SpyAccessLevel {
  case `public`
  case `package`
  case `internal`
  case `fileprivate`
  case `private`
}
