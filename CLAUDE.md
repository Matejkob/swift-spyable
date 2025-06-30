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
  - `Extractors/` - Protocol syntax extraction
  - `Extensions/` - SwiftSyntax utilities
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
- Always test edge cases: generics, async/throws, access levels

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

### CI/CD
- GitHub Actions automatically formats code on main branch pushes
- PRs are created for formatting changes
- Matrix testing ensures compatibility across platforms and Swift versions
- Code coverage is tracked via Codecov