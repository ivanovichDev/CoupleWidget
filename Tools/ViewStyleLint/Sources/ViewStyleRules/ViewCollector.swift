import SwiftSyntax

final class ViewCollector: SyntaxVisitor {
    private(set) var views: [StructDeclSyntax] = []

    init() {
        super.init(viewMode: .sourceAccurate)
    }

    override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
        let inheritedTypes = node.inheritanceClause?.inheritedTypes ?? []
        if inheritedTypes.contains(where: { ["View", "SwiftUI.View"].contains($0.type.trimmedDescription) }) {
            views.append(node)
        }
        return .visitChildren
    }
}
