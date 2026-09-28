import SwiftSyntax

struct ViewMember {
    let name: String
    let category: MemberCategory
    let returnsView: Bool
    let node: Syntax

    init?(_ decl: DeclSyntax) {
        if let initializer = decl.as(InitializerDeclSyntax.self) {
            name = "init"
            category = .initializer
            returnsView = false
            node = Syntax(initializer)
        } else if let variable = decl.as(VariableDeclSyntax.self), let binding = variable.bindings.first {
            name = binding.pattern.trimmedDescription
            returnsView = Self.isViewType(binding.typeAnnotation?.type)
            category = Self.category(of: variable, binding: binding, name: name)
            node = Syntax(variable)
        } else {
            return nil
        }
    }

    private static func category(
        of variable: VariableDeclSyntax,
        binding: PatternBindingSyntax,
        name: String
    ) -> MemberCategory {
        if name == "body" {
            return .body
        }
        if variable.modifiers.contains(where: { $0.name.tokenKind == .keyword(.static) }) {
            return .staticProperty
        }
        if isComputed(binding) {
            return .computedProperty
        }
        if let wrapperCategory = wrapperCategory(of: variable) {
            return wrapperCategory
        }
        let isPrivate = variable.modifiers.contains { modifier in
            [.keyword(.private), .keyword(.fileprivate)].contains(modifier.name.tokenKind)
        }
        return isPrivate ? .privateProperty : .input
    }

    private static func wrapperCategory(of variable: VariableDeclSyntax) -> MemberCategory? {
        for element in variable.attributes {
            guard let attribute = element.as(AttributeSyntax.self) else { continue }
            switch attribute.attributeName.trimmedDescription {
            case "State": return .state
            case "FocusState": return .focusState
            case "Environment": return .environment
            case "Binding", "Bindable": return .input
            default: continue
            }
        }
        return nil
    }

    private static func isComputed(_ binding: PatternBindingSyntax) -> Bool {
        switch binding.accessorBlock?.accessors {
        case .getter:
            return true
        case .accessors(let accessors):
            return accessors.contains { $0.accessorSpecifier.tokenKind == .keyword(.get) }
        case nil:
            return false
        }
    }

    private static func isViewType(_ type: TypeSyntax?) -> Bool {
        guard let type else { return false }
        return ["some View", "some SwiftUI.View"].contains(type.trimmedDescription)
    }
}
