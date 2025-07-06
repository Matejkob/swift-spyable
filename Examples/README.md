# Swift-Spyable Examples

This directory contains practical examples demonstrating the Swift-Spyable macro library features.

## Files Overview

- **ViewModel.swift** & **ViewModelTests.swift**: Basic usage with async/await and error handling
- **AccessLevels.swift**: Demonstrates spy generation with different access levels
- **Polymorphism.swift** & **PolymorphismTests.swift**: Advanced polymorphism examples

## Polymorphism Support

Swift-Spyable supports method overloading (polymorphism) by generating unique spy properties for each method signature. This allows you to independently test and mock different overloads of the same method.

### How Polymorphism Works

When you have overloaded methods in your protocol:

```swift
@Spyable
protocol DataProcessor {
    func compute(value: String) -> String
    func compute(value: Int) -> String
    func compute(value: Bool) -> String
}
```

Swift-Spyable generates unique spy properties by incorporating the parameter and return types into the property names:

```swift
class DataProcessorSpy: DataProcessor {
    // For compute(value: String) -> String
    var computeValueStringStringCallsCount = 0
    var computeValueStringStringCalled: Bool { ... }
    var computeValueStringStringReceivedValue: String?
    var computeValueStringStringReturnValue: String!
    
    // For compute(value: Int) -> String  
    var computeValueIntStringCallsCount = 0
    var computeValueIntStringCalled: Bool { ... }
    var computeValueIntStringReceivedValue: Int?
    var computeValueIntStringReturnValue: String!
    
    // For compute(value: Bool) -> String
    var computeValueBoolStringCallsCount = 0
    var computeValueBoolStringCalled: Bool { ... }
    var computeValueBoolStringReceivedValue: Bool?
    var computeValueBoolStringReturnValue: String!
}
```

### Naming Convention

The spy property names follow this pattern:
`{methodName}{ParameterName}{ParameterType}{ReturnType}{PropertyType}`

Examples:
- `computeValueStringStringReturnValue` = method `compute`, parameter `value` of type `String`, returns `String`, this is the `ReturnValue` property
- `fetchIdIntStringCallsCount` = method `fetch`, parameter `id` of type `Int`, returns `String`, this is the `CallsCount` property

### Different Types of Overloading Supported

#### 1. Different Parameter Types
```swift
func process(data: String) -> String
func process(data: Int) -> String
func process(data: Bool) -> String
```

#### 2. Same Parameter Type, Different Return Types
```swift
func convert(value: Int) -> Bool
func convert(value: Int) -> String
func convert(value: Int) -> [Int]
```

#### 3. Different Parameter Names/Labels
```swift
func process(data: String) -> String
func process(item: String) -> String
func process(content: String) -> String
```

#### 4. Async and Throwing Variants
```swift
func fetch(id: String) async -> String
func fetch(id: Int) async -> String
func validate(input: String) throws -> Bool
func validate(input: Int) throws -> Bool
```

### Testing Polymorphic Methods

Each overload is tracked independently:

```swift
func testPolymorphism() {
    let spy = DataProcessorSpy()
    
    // Setup different return values for each overload
    spy.computeValueStringStringReturnValue = "String result"
    spy.computeValueIntStringReturnValue = "Int result"
    spy.computeValueBoolStringReturnValue = "Bool result"
    
    // Call different overloads
    let stringResult = spy.compute(value: "test")
    let intResult = spy.compute(value: 42)
    let boolResult = spy.compute(value: true)
    
    // Verify each overload was called exactly once
    XCTAssertEqual(spy.computeValueStringStringCallsCount, 1)
    XCTAssertEqual(spy.computeValueIntStringCallsCount, 1)
    XCTAssertEqual(spy.computeValueBoolStringCallsCount, 1)
    
    // Verify correct arguments were captured
    XCTAssertEqual(spy.computeValueStringStringReceivedValue, "test")
    XCTAssertEqual(spy.computeValueIntStringReceivedValue, 42)
    XCTAssertEqual(spy.computeValueBoolStringReceivedValue, true)
}
```

## Key Benefits of Polymorphism Support

1. **Independent Tracking**: Each method overload is tracked separately with its own call counts, arguments, and return values
2. **Type Safety**: The generated spy properties maintain type safety for parameters and return values
3. **Comprehensive Testing**: You can test complex scenarios where the same method name behaves differently based on parameter types
4. **Real-world Compatibility**: Supports common Swift patterns like async/await, throwing functions, and generic constraints

This polymorphism support makes Swift-Spyable suitable for testing complex protocols with overloaded methods, which is common in real-world Swift applications.