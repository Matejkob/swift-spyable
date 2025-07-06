# Swift-Spyable Naming Convention Algorithm

## Overview

The Swift-Spyable macro generates unique variable names for tracking method calls, arguments, and return values in spy classes. This document details the complete algorithm for generating these names, including conflict detection, resolution strategies, and known limitations.

## Algorithm Components

### 1. Base Variable Prefix Generation

The `VariablePrefixFactory` generates variable prefixes using a two-mode approach:

#### Non-Descriptive Mode (Default)
```
functionName + CapitalizedParameterFirstNames
```

Example:
```swift
func display(text: String, name: String) -> String
// Generates: "displayTextName"
```

#### Descriptive Mode (Used for Conflict Resolution)
```
functionName + CapitalizedParameterFirstNamesWithTypes + SanitizedReturnType
```

Example:
```swift
func display(text: String, name: String) -> String
// Generates: "displayTextStringNameStringString"
```

### 2. Parameter Name Extraction Rules

1. **First Parameter Names**: Uses the first (external) parameter name
   ```swift
   func foo(external internal: String)  // Uses "external"
   ```

2. **Underscore Parameters**: Ignored completely
   ```swift
   func foo(_ text: String, name: String)  // Generates: "fooName"
   ```

3. **Capitalization**: First letter of each parameter name is capitalized
   ```swift
   func process(firstName: String)  // Generates: "processFirstName"
   ```

### 3. Type Sanitization

The `TypeSanitizer` class handles type string conversion with these rules:

#### Collection Type Conversion
Before removing forbidden characters, the sanitizer converts collection shorthand syntax:
- `[Type]` becomes `ArrayType`
- `[Key: Value]` becomes `DictionaryKeyValue`

This ensures consistency between shorthand syntax (`[String]`) and generic syntax (`Array<String>`).

#### Forbidden Characters Removal
The following characters are removed from type names:
- `:` (colon)
- `[` and `]` (brackets)  
- `<` and `>` (angle brackets)
- `(` and `)` (parentheses)
- `,` (comma)
- ` ` (space)
- `-` (hyphen)
- `&` (ampersand)

#### Optional Type Handling
- Trailing `?` marks are converted to `Optional` prefix
- Multiple optionals are handled recursively

Examples:
```swift
String?           → OptionalString
String??          → OptionalOptionalString
[String]?         → OptionalArrayString
[String?]?        → OptionalArrayOptionalString
[String: Int]?    → OptionalDictionaryStringInt
```

#### Function Attribute Handling
Function attributes are converted to their non-attributed form:
- `@escaping` → `escaping`
- `@Sendable` → `Sendable`
- `@autoclosure` → `autoclosure`
- `@MainActor` → `MainActor`
- Other `@` symbols are removed

### 4. Polymorphism Detection and Resolution

The `PolymorphismDetector` class handles methods with identical names but different signatures:

1. **Detection Phase**: 
   - Generates base (non-descriptive) prefixes for all methods
   - Groups methods by their base prefix
   - Identifies conflicts where multiple methods share the same prefix

2. **Resolution Phase**:
   - Methods with unique prefixes use non-descriptive mode
   - Methods with conflicts automatically switch to descriptive mode

Example:
```swift
protocol DataProcessor {
    func compute(value: String) -> String  // computeValueStringString
    func compute(value: Int) -> String     // computeValueIntString
    func compute(value: Bool) -> String    // computeValueBoolString
}
```

### 5. Complete Variable Name Generation

For each method, the following variables are generated using the computed prefix:

```swift
{prefix}Called: Bool                    // Whether method was called
{prefix}CallsCount: Int                 // Number of times called
{prefix}ReceivedArguments: (...)        // Last received arguments
{prefix}ReceivedInvocations: [(...)]    // All invocations
{prefix}ReturnValue: ReturnType         // Stubbed return value
{prefix}ThrowableError: Error?          // Error to throw
{prefix}Closure: ((...) -> ReturnType)? // Custom implementation
```

## Step-by-Step Algorithm

1. **Extract Function Components**
   - Function name
   - Parameter list with names and types
   - Return type (if any)

2. **Generate Base Prefix**
   - Start with function name
   - For each parameter:
     - Skip if parameter name is `_`
     - Capitalize first letter of parameter name
     - Append to prefix

3. **Check for Conflicts**
   - Compare with other methods in protocol
   - If duplicate prefix exists, enable descriptive mode

4. **Generate Descriptive Prefix (if needed)**
   - Start with function name
   - For each parameter:
     - Skip if parameter name is `_`
     - Capitalize first letter of parameter name
     - Sanitize parameter type
     - Append both name and type
   - Sanitize and append return type

5. **Type Sanitization Process**
   - Remove function attributes
   - Count and remove trailing `?` marks
   - Replace remaining `?` with "Optional"
   - Remove forbidden characters
   - Prepend "Optional" for each trailing `?`

## Complex Scenarios

### 1. Multiple Overloads with Different Types
```swift
func convert(value: Int) -> Bool       // convertValueIntBool
func convert(value: Int) -> String     // convertValueIntString
func convert(value: Int) -> [Int]      // convertValueIntArrayInt
```

### 2. Generic Types
```swift
func transform(data: [String: [Int]]) -> Dictionary<String, Array<Int>>
// transformDataDictionaryStringArrayIntDictionaryStringArrayInt
```

### 3. Nested Optionals
```swift
func find(in: [[String?]?]) -> [String?]??
// findInOptionalArrayOptionalStringOptionalOptionalArrayOptionalString
```

### 4. Function Types with Attributes
```swift
func async(completion: @escaping (Result<String, Error>) -> Void)
// asyncCompletionescapingResultStringErrorVoid
```

### 5. Tuple Types
```swift
func parse(data: Data) -> (name: String, age: Int)
// parseDataDatanameStringageInt
```

## Limitations and Edge Cases

### 1. Type Ambiguity
The algorithm doesn't distinguish between:
- Type aliases vs actual types
- Module-qualified types (e.g., `Swift.String` vs `String`)

### 2. Complex Generic Constraints
Generic constraints and where clauses are lost:
```swift
func process<T: Codable & Hashable>(item: T) -> T
// Becomes: processItemTT
```

### 3. Protocol Composition
Protocol compositions are concatenated without separators:
```swift
func handle(object: Codable & Hashable)
// Becomes: handleObjectCodableHashable
```

### 4. Unnamed Tuple Elements
Tuple elements without labels are concatenated:
```swift
func process(point: (Int, Int)) -> Bool
// Becomes: processPointIntIntBool
```

### 5. Function Type Parameters
Complex function types may become hard to read:
```swift
func map(transform: (String) throws -> Int?) -> [Int]
// Becomes: mapTransformStringthrowsOptionalIntInt
```

### 6. Case Sensitivity
The algorithm is case-sensitive, so these would generate different prefixes:
```swift
func process(Data: String)  // processData
func process(data: String)  // processData (conflict!)
```

### 7. Reserved Keywords
Swift keywords used as parameter names require backticks but generate clean names:
```swift
func process(`class`: String)  // processClass
```

## Performance Considerations

1. **Lazy Evaluation**: The `PolymorphismDetector` uses lazy properties to avoid expensive computations for protocols without polymorphic methods.

2. **Early Exit Optimization**: Single-method protocols skip conflict detection entirely.

3. **Dictionary-Based Grouping**: Conflict detection uses O(n) grouping with dictionary storage.

## Best Practices for Users

1. **Avoid Parameter Name Conflicts**: Use descriptive, unique parameter names to minimize the need for descriptive mode.

2. **Consider Return Types**: When methods have the same parameters, different return types will help distinguish them in descriptive mode.

3. **Be Aware of Type Sanitization**: Complex types may produce long variable names in descriptive mode.

4. **Test Generated Names**: Always verify the generated spy to ensure variable names are as expected.

## Recent Improvements

### Collection Type Consistency (v2.x)

Previously, collection types were handled inconsistently:
```swift
// Before:
[String] → String
[String: Int] → StringInt
Array<String> → ArrayString  // Inconsistent!

// After:
[String] → ArrayString
[String: Int] → DictionaryStringInt  
Array<String> → ArrayString  // Consistent!
```

This change ensures that both shorthand and generic collection syntax produce identical variable names, making the generated code more predictable and self-documenting.

## Future Improvements

Potential enhancements to the algorithm could include:

1. **Shortened Type Names**: Using type abbreviations for common types (String → Str, Integer → Int)
2. **Module Disambiguation**: Including module names when types conflict
3. **Custom Naming Strategies**: Allowing users to provide custom naming rules
4. **Better Generic Handling**: Preserving more information about generic constraints
5. **Collision Warning**: Diagnostic messages when naming conflicts occur