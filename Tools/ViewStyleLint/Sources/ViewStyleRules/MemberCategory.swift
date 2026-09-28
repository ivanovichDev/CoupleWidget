enum MemberCategory: Int, Comparable {
    case staticProperty
    case input
    case state
    case focusState
    case environment
    case privateProperty
    case initializer
    case computedProperty
    case body

    var label: String {
        switch self {
        case .staticProperty: "static property"
        case .input: "input property"
        case .state: "@State property"
        case .focusState: "@FocusState property"
        case .environment: "@Environment property"
        case .privateProperty: "private property"
        case .initializer: "initializer"
        case .computedProperty: "computed property"
        case .body: "body"
        }
    }

    static func < (lhs: MemberCategory, rhs: MemberCategory) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
