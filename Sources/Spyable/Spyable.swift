@attached(peer, names: arbitrary)
public macro Spyable() -> () = #externalMacro(
    module: "SpyableMacro",
    type: "SpyableMacro"
)
