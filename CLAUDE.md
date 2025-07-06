# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Swift-Spyable is a Swift macro library that generates spy/mock classes for protocols. It replaces manual test double creation with automated, type-safe spy generation using Swift macros.

## Common Commands

### Building and Testing
- `swift build` - Build the package
- `swift test` - Run all tests
- `swift test -Xswiftc -Xfrontend -Xswiftc -dump-macro-expansions --enable-code-coverage` - Run tests with coverage and macro expansion dumps
- `swift test --filter TestName` - Run specific test

### Code Formatting
- `swift format --recursive --in-place ./Package.swift ./Sources ./Tests ./Examples` - Format all code (automatically done by CI)

### Platform-Specific Testing
- macOS: Use Xcode 15.4+ or 16.2+
- Linux: Requires Swift 5.9+
- Run Examples: `cd Examples && swift test`

## Architecture

The codebase follows a clear separation between public API and implementation:

### Core Structure
- `Sources/Spyable/` - Public API (`@Spyable` macro)
- `Sources/SpyableMacro/` - Macro implementation
  - `Macro/SpyableMacro.swift` - Main macro entry point
  - `Factories/` - Code generation logic split by concern
    - `VariablePrefixFactory.swift` - Generates unique variable prefixes with polymorphism support
  - `Extractors/` - Protocol syntax extraction
  - `Extensions/` - SwiftSyntax utilities
  - `Helpers/` - Utility classes
    - `TypeSanitizer.swift` - Type name sanitization for variable naming
  - `Diagnostics/` - Error handling

### Key Design Patterns
1. **Factory Pattern**: Each aspect of spy generation (methods, properties, call tracking) has its own factory
2. **Visitor Pattern**: Uses SwiftSyntax visitors to traverse and analyze protocol declarations
3. **Builder Pattern**: Constructs spy classes incrementally through multiple factories

### Generated Spy Structure
For a protocol `MyProtocol`, the macro generates `MyProtocolSpy` with:
- `{method}Called` - Bool tracking if method was called
- `{method}CallsCount` - Int counting method calls
- `{method}ReceivedArguments` - Tuple of last received arguments
- `{method}ReceivedInvocations` - Array of all invocations
- `{method}Closure` - Optional closure for stubbing behavior
- `{method}ReturnValue` - Stubbed return value (non-void methods)
- `{method}ThrowableError` - Error to throw (throwing methods)

## Polymorphism Support

Swift-Spyable automatically handles polymorphic functions (methods with the same name but different parameter or return types) by generating descriptive variable names that include type information. This ensures each method overload gets unique spy variables without naming conflicts.

### Implementation Architecture

The polymorphism detection system consists of three main components:

#### 1. VariablePrefixFactory
Located in `Sources/SpyableMacro/Factories/VariablePrefixFactory.swift`, this factory generates unique textual representations for function declarations:

- **Non-descriptive mode** (default): Uses function name + parameter names (e.g., `displayTextName`)
- **Descriptive mode** (polymorphism detected): Includes parameter and return types (e.g., `displayTextStringNameStringString`)

The factory automatically switches to descriptive mode when `SpyFactory` detects multiple functions with the same non-descriptive prefix.

#### 2. TypeSanitizer Helper
Located in `Sources/SpyableMacro/Helpers/TypeSanitizer.swift`, this utility sanitizes Swift type names for use in variable identifiers:

- Removes forbidden characters: `[`, `]`, `<`, `>`, `(`, `)`, `,`, ` `, `-`, `&`, `:`
- Handles optionals: `String?` becomes `OptionalString`, `String??` becomes `OptionalOptionalString`
- Processes function attributes: `@escaping` becomes `escaping`, `@Sendable` becomes `Sendable`
- Sanitizes complex nested types like `[String: [Int]]` → `StringInt`

#### 3. SpyFactory Integration
The main `SpyFactory` orchestrates polymorphism detection by:

1. Pre-scanning all functions to build a frequency map of non-descriptive prefixes
2. Identifying functions that would have naming conflicts (frequency > 1)
3. Automatically enabling descriptive mode for conflicting functions
4. Generating unique variable names for each method overload

### Polymorphism Examples

Given these polymorphic methods:
```swift
protocol DisplayService {
    func display(text: Int, name: String)
    func display(text: String, name: String) 
    func display(text: String, name: String) -> String
}
```

Swift-Spyable generates:
```swift
class DisplayServiceSpy: DisplayService {
    // For display(text: Int, name: String)
    var displayTextIntNameStringCalled = false
    var displayTextIntNameStringCallsCount = 0
    // ... other spy variables
    
    // For display(text: String, name: String)
    var displayTextStringNameStringCalled = false
    var displayTextStringNameStringCallsCount = 0
    // ... other spy variables
    
    // For display(text: String, name: String) -> String
    var displayTextStringNameStringStringCalled = false
    var displayTextStringNameStringStringCallsCount = 0
    var displayTextStringNameStringStringReturnValue: String!
    // ... other spy variables
}
```

### Testing Strategy for Polymorphic Functions

#### Unit Tests
- `Tests/SpyableMacroTests/Factories/UT_VariablePrefixFactory.swift` - Comprehensive tests for variable prefix generation
- `Tests/SpyableMacroTests/Helpers/UT_TypeSanitizer.swift` - Type sanitization edge cases

#### Test Categories
1. **Basic Polymorphism**: Same function name with different parameter types
2. **Return Type Polymorphism**: Same signature with different return types
3. **Complex Type Handling**: Generics, optionals, collections, protocol compositions
4. **Edge Cases**: Function attributes (`@escaping`, `@Sendable`), nested optionals, custom types

#### Integration Testing
The Examples project provides real-world usage scenarios for polymorphic protocols, ensuring the generated spies compile and work correctly in practice.

### Common Edge Cases and Solutions

#### 1. Nested Generics and Collections
```swift
func transform(data: [String: [Int]]) -> Dictionary<String, Array<Int>>
```
Generates: `transformDataStringIntDictionaryStringArrayInt`

#### 2. Multiple Optionals
```swift  
func find(key: String) -> String??
```
Generates: `findKeyStringOptionalOptionalString`

#### 3. Protocol Compositions
```swift
func combine(objects: [Codable & Hashable]) -> any Codable  
```
Generates: `combineObjectsCodableHashableanyCodable`

#### 4. Function Attributes
```swift
func async(completion: @escaping (Result<String, Error>) -> Void)
```  
Generates: `asyncCompletionescapingResultStringErrorVoid`

### Developer Guidelines for Polymorphism Features

#### When Adding New Type Support:
1. Update `TypeSanitizer.sanitize()` method for new forbidden characters or type patterns
2. Add corresponding test cases in `UT_TypeSanitizer.swift`
3. Test both `sanitize()` and `sanitizeWithOptionalHandling()` methods
4. Verify integration with `VariablePrefixFactory` descriptive mode

#### When Modifying Variable Generation:
1. Ensure changes work in both descriptive and non-descriptive modes
2. Test with complex nested types and protocol compositions  
3. Verify no regression in non-polymorphic scenarios
4. Update `UT_VariablePrefixFactory.swift` with new test cases

#### Debugging Polymorphism Issues:
1. Use `swift test -Xswiftc -Xfrontend -Xswiftc -dump-macro-expansions` to see generated variable names
2. Check if `SpyFactory` correctly detects naming conflicts in the frequency map
3. Verify `TypeSanitizer` properly handles the specific type patterns causing issues
4. Test with isolated minimal examples to isolate the problem

## Development Workflow

### Adding New Features
1. Identify which factory needs modification or if a new factory is needed
2. Update the factory implementation in `Sources/SpyableMacro/Factories/`
3. Add corresponding tests in `Tests/SpyableMacroTests/`
4. Update `SpyFactory.createSpy()` if adding a new factory
5. Test with Examples project to ensure real-world usage works

### Testing Strategy
- Unit tests use `assertBuildResult` for macro expansion testing
- Each factory has dedicated test files (e.g., `UT_CalledFactory.swift`)
- Integration tests live in the Examples project
- Always test edge cases: generics, async/throws, access levels, polymorphism
- Polymorphism-specific tests:
  - `UT_VariablePrefixFactory.swift` - Tests both descriptive and non-descriptive modes
  - `UT_TypeSanitizer.swift` - Tests type name sanitization for complex Swift types
  - Focus on edge cases: nested generics, multiple optionals, function attributes

### Debugging Macros
1. Use `swift test -Xswiftc -Xfrontend -Xswiftc -dump-macro-expansions` to see generated code
2. Add diagnostic messages in macro implementation using `context.diagnose()`
3. Check `SpyableDiagnostic` for existing error types

## Important Considerations

### Swift Syntax
- The project heavily uses SwiftSyntax for AST manipulation
- When modifying syntax generation, ensure proper formatting and indentation
- Use `DeclSyntax`, `TokenSyntax`, and related types from SwiftSyntax

### Compatibility
- Maintains compatibility with Swift 5.9+
- Must work across macOS, Linux, and iOS platforms
- Windows support is experimental (CI disabled)

### Code Generation Rules
1. Generated code respects the original protocol's access level
2. Property spies include both getter and setter tracking
3. Methods with multiple parameters generate tuple types for arguments
4. Generic constraints are preserved in generated spies
5. Associated types are handled but may require manual implementation
6. Polymorphic methods automatically generate unique variable names using type information
7. Type names are sanitized to create valid Swift identifiers (removing special characters, handling optionals)

### CI/CD
- GitHub Actions automatically formats code on main branch pushes
- PRs are created for formatting changes
- Matrix testing ensures compatibility across platforms and Swift versions
- Code coverage is tracked via Codecov