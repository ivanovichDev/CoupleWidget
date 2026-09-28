import SwiftParser
import SwiftSyntax

public enum ViewStyleChecker {
    public static func check(source: String, fileName: String) -> [Violation] {
        let tree = Parser.parse(source: source)
        let converter = SourceLocationConverter(fileName: fileName, tree: tree)
        let collector = ViewCollector()
        collector.walk(tree)

        var violations = fileViolations(views: collector.views, fileName: fileName, converter: converter)
        for view in collector.views {
            violations += memberViolations(view: view, converter: converter)
        }
        return violations
    }

    private static func fileViolations(
        views: [StructDeclSyntax],
        fileName: String,
        converter: SourceLocationConverter
    ) -> [Violation] {
        let baseName = fileName.split(separator: "/").last.map(String.init) ?? fileName
        if let first = views.first, views.count == 1, baseName != "\(first.name.text).swift" {
            let message = "View `\(first.name.text)` must be declared in `\(first.name.text).swift`"
            return [violation(first, message, converter)]
        }
        return views.dropFirst().map { view in
            violation(view, "File declares more than one view; move `\(view.name.text)` into its own file", converter)
        }
    }

    private static func memberViolations(view: StructDeclSyntax, converter: SourceLocationConverter) -> [Violation] {
        let viewName = view.name.text
        var violations: [Violation] = []
        var latest: ViewMember?

        for item in view.memberBlock.members {
            if let function = item.decl.as(FunctionDeclSyntax.self) {
                let message = "View `\(viewName)` declares method `\(function.name.text)`; views have no methods"
                violations.append(violation(function, message, converter))
                continue
            }
            guard let member = ViewMember(item.decl) else { continue }
            if member.returnsView, member.category != .body {
                let message = "Only `body` may return a view; extract `\(member.name)` into a separate view"
                violations.append(violation(member.node, message, converter))
            }
            if let previous = latest, member.category < previous.category {
                let message = "\(member.category.label) `\(member.name)` must be declared before "
                    + "\(previous.category.label) `\(previous.name)`"
                violations.append(violation(member.node, message, converter))
            } else {
                latest = member
            }
        }
        return violations
    }

    private static func violation(
        _ node: some SyntaxProtocol,
        _ message: String,
        _ converter: SourceLocationConverter
    ) -> Violation {
        let location = node.startLocation(converter: converter)
        return Violation(line: location.line, column: location.column, message: message)
    }
}
