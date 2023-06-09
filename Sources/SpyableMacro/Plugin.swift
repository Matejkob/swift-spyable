#if canImport(SwiftCompilerPlugin)
import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct SpyableCompilerPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        SpyableMacro.self
    ]
}
#endif
