import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct HashableMacro: ExtensionMacro {
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, attachedTo declaration: some SwiftSyntax.DeclGroupSyntax, providingExtensionsOf type: some SwiftSyntax.TypeSyntaxProtocol, conformingTo protocols: [SwiftSyntax.TypeSyntax], in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.ExtensionDeclSyntax] {
        guard let classDecl = declaration.as(ClassDeclSyntax.self) else { return [] }

        let modifier = declaration.modifiers.first?.name.trimmed.text.appending(" ") ?? ""

        let identifiers = classDecl.memberBlock.members
            .compactMap { $0.decl.as(VariableDeclSyntax.self) }
            .compactMap { $0.bindings.first }
            .filter { $0.accessorBlock == nil }
            .compactMap { $0.pattern.as(IdentifierPatternSyntax.self) }

        let type = type.trimmed

        let equatableExpression = identifiers
            .map { "lhs.\($0) == rhs.\($0)" }
            .joined(separator: " &&\n")

        let hashExpression = identifiers
            .map { "hasher.combine(\($0))" }
            .joined(separator: "\n")

        let hashableExtension = try ExtensionDeclSyntax(
            """
            extension \(type): Hashable {
                \(raw: modifier)static func == (lhs: \(type), rhs: \(type)) -> Bool {
                    \(raw: equatableExpression)
                }

                \(raw: modifier)func hash(into hasher: inout Hasher) {
                    \(raw: hashExpression)
                }
            }
            """
        )

        return [hashableExtension]
    }
}

@main
struct HashablePlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        HashableMacro.self
    ]
}
