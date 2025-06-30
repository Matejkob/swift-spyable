# Spyable

[![GitHub Workflow Status](https://github.com/Matejkob/swift-spyable/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/Matejkob/swift-spyable/actions/workflows/ci.yml)
[![codecov](https://codecov.io/gh/Matejkob/swift-spyable/graph/badge.svg?token=YRMM1BDQ85)](https://codecov.io/gh/Matejkob/swift-spyable)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FMatejkob%2Fswift-spyable%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/Matejkob/swift-spyable)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FMatejkob%2Fswift-spyable%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/Matejkob/swift-spyable)

Spyable is a powerful tool for Swift that automates the process of creating protocol-conforming classes. Initially designed to simplify testing by generating spies, it is now widely used for various scenarios, such as SwiftUI previews or creating quick dummy implementations.

## Overview

Spyable enhances your Swift workflow with the following features:

- **Automatic Spy Generation**: Annotate a protocol with `@Spyable`, and let the macro generate a corresponding spy class.
- **Access Level Inheritance**: The generated class automatically inherits the protocol's access level.
- **Explicit Access Control**: Use the `accessLevel` argument to override the inherited access level if needed.
- **Interaction Tracking**: For testing, the generated spy tracks method calls, arguments, and return values.

## Quick Start

1. Import Spyable: `import Spyable`
2. Annotate your protocol with `@Spyable`:

```swift
@Spyable
public protocol ServiceProtocol {
  var name: String { get }
  func fetchConfig(arg: UInt8) async throws -> [String: String]
}
```

This generates a spy class named `ServiceProtocolSpy` with a `public` access level. The generated class includes properties and methods for tracking method calls, arguments, and return values.

```swift
public class ServiceProtocolSpy: ServiceProtocol {
  public var name: String {
    get { underlyingName }
    set { underlyingName = newValue }
  }
  public var underlyingName: (String)!

  public var fetchConfigArgCallsCount = 0
  public var fetchConfigArgCalled: Bool {
    return fetchConfigArgCallsCount > 0
  }
  public var fetchConfigArgReceivedArg: UInt8?
  public var fetchConfigArgReceivedInvocations: [UInt8] = []
  public var fetchConfigArgThrowableError: (any Error)?
  public var fetchConfigArgReturnValue: [String: String]!
  public var fetchConfigArgClosure: ((UInt8) async throws -> [String: String])?

  public func fetchConfig(arg: UInt8) async throws -> [String: String] {
    fetchConfigArgCallsCount += 1
    fetchConfigArgReceivedArg = (arg)
    fetchConfigArgReceivedInvocations.append((arg))
    if let fetchConfigArgThrowableError {
      throw fetchConfigArgThrowableError
    }
    if fetchConfigArgClosure != nil {
      return try await fetchConfigArgClosure!(arg)
    } else {
      return fetchConfigArgReturnValue
    }
  }
}
```

3. Use the spy in your tests:

```swift
func testFetchConfig() async throws {
  let serviceSpy = ServiceProtocolSpy()
  let sut = ViewModel(service: serviceSpy)

  serviceSpy.fetchConfigArgReturnValue = ["key": "value"]

  try await sut.fetchConfig()

  XCTAssertEqual(serviceSpy.fetchConfigArgCallsCount, 1)
  XCTAssertEqual(serviceSpy.fetchConfigArgReceivedInvocations, [1])

  try await sut.saveConfig()

  XCTAssertEqual(serviceSpy.fetchConfigArgCallsCount, 2)
  XCTAssertEqual(serviceSpy.fetchConfigArgReceivedInvocations, [1, 1])
}
```

## Advanced Usage

### Access Level Inheritance and Overrides

By default, the generated spy inherits the access level of the annotated protocol. For example:

```swift
@Spyable
internal protocol InternalProtocol {
  func doSomething()
}
```

This generates:

```swift
internal class InternalProtocolSpy: InternalProtocol {
  internal func doSomething() { ... }
}
```

You can override this behavior by explicitly specifying an access level:

```swift
@Spyable(accessLevel: .fileprivate)
public protocol CustomProtocol {
  func restrictedTask()
}
```

Generates:

```swift
fileprivate class CustomProtocolSpy: CustomProtocol {
  fileprivate func restrictedTask() { ... }
}
```

Supported values for `accessLevel` are:
- `.public`
- `.package`
- `.internal`
- `.fileprivate`
- `.private`

### Restricting Spy Availability

Use the `behindPreprocessorFlag` parameter to wrap the generated code in a preprocessor directive:

```swift
@Spyable(behindPreprocessorFlag: "DEBUG")
protocol DebugProtocol {
  func logSomething()
}
```

Generates:

```swift
#if DEBUG
internal class DebugProtocolSpy: DebugProtocol {
  internal func logSomething() { ... }
}
#endif
```

### Handling Overloaded Methods

When a protocol contains multiple functions with the same name (i.e. function overloading), `@Spyable` ensures each generated spy property remains uniquely identifiable. It does so by extending the prefix with return types and parameter types when necessary.

For example:

```swift
func loadData() -> String
func loadData() -> Int
func loadData(id: Int) -> String
func loadData(id: Int) -> String?
func loadData(id: Int?) -> [String]?
```

Will generate distinct spy identifiers like:

```
loadDataString
loadDataInt
loadDataIdIntString
loadDataIdIntOptionalString
loadDataIdIntOptionalOptionalArrayString
```

This disambiguation avoids naming collisions while preserving accurate call tracking.

## Installation

### Xcode Projects

Add Spyable as a package dependency:

```
https://github.com/Matejkob/swift-spyable
```

### Swift Package Manager

Add to your `Package.swift`:

```swift
dependencies: [
  .package(url: "https://github.com/Matejkob/swift-spyable", from: "0.3.0")
]
```

Then, add the product to your target:

```swift
.product(name: "Spyable", package: "swift-spyable"),
```

## License

This library is released under the MIT license. See [LICENSE](LICENSE) for details.
