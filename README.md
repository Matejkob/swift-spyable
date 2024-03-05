# Spyable

![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/Matejkob/swift-spyable/Test_SwiftPM.yml?label=CI&logo=GitHub)
[![codecov](https://codecov.io/gh/Matejkob/swift-spyable/graph/badge.svg?token=YRMM1BDQ85)](https://codecov.io/gh/Matejkob/swift-spyable)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FMatejkob%2Fswift-spyable%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/Matejkob/swift-spyable)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FMatejkob%2Fswift-spyable%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/Matejkob/swift-spyable)

A powerful tool for Swift that simplifies and automates the process of creating spies
for testing. Using the `@Spyable` annotation on a protocol, the macro generates
a spy class that implements the same interface as the protocol and keeps track of 
interactions with its methods and properties.

## Overview

A "spy" is a specific type of test double that not only replaces a real component, but also 
records all interactions for later inspection. It's particularly useful in behavior verification,
where the interaction between objects, rather than the state, is the subject of the test.

The Spyable macro is designed to simplify and enhance the usage of spies in Swift testing. 
Traditionally, developers would need to manually create spies for each protocol in  their
codebase — a tedious and error-prone task. The Spyable macro revolutionizes this process
by automatically generating these spies.

When a protocol is annotated with `@Spyable`, the macro generates a corresponding spy class that 
implement this protocol. This spy class is capable of tracking all interactions with its methods
and properties. It records method invocations, their arguments, and returned values, providing 
a comprehensive log of interactions that occurred during the test. This data can then be used 
to make precise assertions about the behavior of the system under test.

**TL;DR**

The Spyable macro provides the following functionality: 
- **Automatic Spy Generation**: No need to manually create spy classes for each protocol.
  Just annotate the protocol with `@Spyable`, and let the macro do the rest.
- **Interaction Tracking**: The generated spy records method calls, arguments, and return
  values, making it easy to verify behavior in your tests.
- **Swift Syntax**: The macro uses Swift syntax, providing a seamless and familiar experience
  for Swift developers.

## Quick start

To get started, import Spyable: `import Spyable`, annotate your protocol with `@Spyable`:

```swift
@Spyable
protocol ServiceProtocol {
    var name: String { get }
    func fetchConfig(arg: UInt8) async throws -> [String: String]
}
```

This will generate a spy class named `ServiceProtocolSpy` that implements `ServiceProtocol`.
The generated class includes properties and methods for tracking the number of method calls,
the arguments passed, and whether the method was called.

```swift
class ServiceProtocolSpy: ServiceProtocol {
    var name: String {
        get { underlyingName }
        set { underlyingName = newValue }
    }
    var underlyingName: (String)!
    
    var fetchConfigArgCallsCount = 0
    var fetchConfigArgCalled: Bool {
        return fetchConfigArgCallsCount > 0
    }
    var fetchConfigArgReceivedArg: UInt8?
    var fetchConfigArgReceivedInvocations: [UInt8] = []
    var fetchConfigArgReturnValue: [String: String]!
    var fetchConfigArgClosure: ((UInt8) async throws -> [String: String])?

    func fetchConfig(arg: UInt8) async throws -> [String: String] {
        fetchConfigArgCallsCount += 1
        fetchConfigArgReceivedArg = (arg)
        fetchConfigArgReceivedInvocations.append((arg))
        if fetchConfigArgClosure != nil {
            return try await fetchConfigArgClosure!(arg)
        } else {
            return fetchConfigArgReturnValue
        }
    }
}
```

Then, in your tests, you can use the spy to verify that your code is interacting
with the `service` dependency of type `ServiceProtocol` correctly:

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

### Restricting the Availability of Spies

If you wish, you can limit where `Spyable`'s generated code can be used from. This can be useful if you want to prevent spies from being used in user-facing production code.

To apply this conditional compilation, use the `behindPreprocessorFlag: String?` parameter within the `@Spyable` attribute. This parameter accepts a **static string literal** representing the compilation flag that controls the inclusion of the generated spy code.

Example usage with the `DEBUG` flag:

```swift
@Spyable(behindPreprocessorFlag: "DEBUG")
protocol MyService {
    func fetchData() async
}
```

With `behindPreprocessorFlag` specified as `DEBUG`, the macro expansion will be wrapped in an `#if DEBUG` preprocessor macro, preventing its use anywhere that the `DEBUG` flag is not defined:

```swift
#if DEBUG
class MyServiceSpy: MyService {
    var fetchDataCallsCount = 0
    var fetchDataCalled: Bool {
        return fetchDataCallsCount > 0
    }
    var fetchDataClosure: (() async -> Void)?

    func fetchData() async {
        fetchDataCallsCount += 1
        await fetchDataClosure?()
    }
}
#endif
```

This approach allows for great flexibility, enabling you to define any flag (e.g., `TESTS`) and configure your build settings to include the spy code only in specific targets (like test or preview targets) by defining the appropriate flag under "Active Compilation Conditions" in your project's build settings.

> [!IMPORTANT]
> When specifying the `behindPreprocessorFlag` argument, it is crucial to use a static string literal. This requirement ensures that the preprocessor flag's integrity is maintained and that conditional compilation behaves as expected. The Spyable system will provide a diagnostic message if the argument does not meet this requirement, guiding you to correct the implementation.

#### A Caveat Regarding Xcode Previews

Limiting the availability of spy implementations through conditional compilation can impact the usability of spies in Xcode Previews. If you rely on spies within your previews while also wanting to exclude them from production builds, consider defining a separate compilation flag (e.g., `SPIES_ENABLED`) for preview and test targets:

```
-- MyFeature (`SPIES_ENABLED = 0`)
---- MyFeatureTests (`SPIES_ENABLED = 1`)
---- MyFeaturePreviews (`SPIES_ENABLED = 1`)
```

Set this custom flag under the "Active Compilation Conditions" for both your `MyFeatureTests` and `MyFeaturePreviews` targets to seamlessly integrate spy functionality where needed without affecting production code.

## Examples

This repo comes with an example of how to use Spyable. You can find it [here](./Examples).

## Documentation

The latest documentation for this library is available [here](https://swiftpackageindex.com/Matejkob/swift-spyable/0.1.2/documentation/spyable).

## Installation

### Integrating with Xcode Projects

To incorporate Spyable into your Xcode project, add it as a package dependency:

```
https://github.com/Matejkob/swift-spyable
```

### Using with Swift Package Manager (SwiftPM)

For projects utilizing Swift Package Manager, you can include Spyable by modifying your `Package.swift` file. Add the following to your `dependencies` array:

```swift
dependencies: [
  .package(url: "https://github.com/Matejkob/swift-spyable", from: "0.3.0")
]
```

Next, to use Spyable in your project, append the product to the appropriate target(s) in your `Package.swift`:

```swift
.product(name: "Spyable", package: "swift-spyable"),
```

## License

This library is released under the MIT license. See [LICENSE](LICENSE) for details.
