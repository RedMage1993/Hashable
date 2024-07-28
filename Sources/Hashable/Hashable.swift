@attached(extension, conformances: Hashable, names: named(==), named(hash))
public macro Hashable() = #externalMacro(module: "HashableMacros", type: "HashableMacro")
