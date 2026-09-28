import Foundation
import ViewStyleRules

let paths = CommandLine.arguments.dropFirst().filter { $0.hasSuffix(".swift") }
var hasViolations = false

for path in paths {
    guard let source = try? String(contentsOfFile: path, encoding: .utf8) else { continue }
    for violation in ViewStyleChecker.check(source: source, fileName: path) {
        print("\(path):\(violation.line):\(violation.column): error: \(violation.message)")
        hasViolations = true
    }
}

exit(hasViolations ? 1 : 0)
