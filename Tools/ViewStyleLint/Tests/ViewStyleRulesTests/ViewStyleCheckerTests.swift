import Testing
@testable import ViewStyleRules

struct ViewStyleCheckerTests {
    @Test
    func validViewHasNoViolations() {
        let source = """
        struct Card: View {
            static let inset: CGFloat = 8
            let title: String
            @Binding var isOn: Bool
            @State private var isPressed = false
            @FocusState private var isFocused: Bool
            @Environment(\\.displayScale)
            private var displayScale
            private let spacing: CGFloat = 4

            init(title: String, isOn: Binding<Bool>) {
                self.title = title
                _isOn = isOn
            }

            private var opacity: Double { isOn ? 1 : 0.5 }

            var body: some View {
                Text(title)
            }
        }
        """

        #expect(ViewStyleChecker.check(source: source, fileName: "Card.swift").isEmpty)
    }

    @Test
    func environmentBeforeStateIsReported() {
        let source = """
        struct Card: View {
            @Environment(\\.displayScale)
            private var displayScale
            @State private var isPressed = false

            var body: some View {
                Text("")
            }
        }
        """

        let messages = ViewStyleChecker.check(source: source, fileName: "Card.swift").map(\.message)

        let expected = "@State property `isPressed` must be declared before @Environment property `displayScale`"
        #expect(messages == [expected])
    }

    @Test
    func memberAfterBodyIsReported() {
        let source = """
        struct Card: View {
            var body: some View {
                Text(title)
            }

            private var title: String { "" }
        }
        """

        let messages = ViewStyleChecker.check(source: source, fileName: "Card.swift").map(\.message)

        #expect(messages == ["computed property `title` must be declared before body `body`"])
    }

    @Test
    func methodIsReported() {
        let source = """
        struct Card: View {
            var body: some View {
                Text("")
            }

            private func send() {}
        }
        """

        let messages = ViewStyleChecker.check(source: source, fileName: "Card.swift").map(\.message)

        #expect(messages == ["View `Card` declares method `send`; views have no methods"])
    }

    @Test
    func viewPropertyOtherThanBodyIsReported() {
        let source = """
        struct Card: View {
            private var line: some View {
                Rectangle()
            }

            var body: some View {
                line
            }
        }
        """

        let messages = ViewStyleChecker.check(source: source, fileName: "Card.swift").map(\.message)

        #expect(messages == ["Only `body` may return a view; extract `line` into a separate view"])
    }

    @Test
    func secondViewInFileIsReported() {
        let source = """
        struct Card: View {
            var body: some View {
                Badge()
            }
        }

        private struct Badge: View {
            var body: some View {
                Text("")
            }
        }
        """

        let messages = ViewStyleChecker.check(source: source, fileName: "Card.swift").map(\.message)

        #expect(messages == ["File declares more than one view; move `Badge` into its own file"])
    }

    @Test
    func fileNameMismatchIsReported() {
        let source = """
        struct Card: View {
            var body: some View {
                Text("")
            }
        }
        """

        let messages = ViewStyleChecker.check(source: source, fileName: "Components/Tile.swift").map(\.message)

        #expect(messages == ["View `Card` must be declared in `Card.swift`"])
    }

    @Test
    func viewModifiersAndRepresentablesAreIgnored() {
        let source = """
        struct Lift: ViewModifier {
            func body(content: Content) -> some View {
                content
            }
        }

        struct Container: UIViewControllerRepresentable {
            func makeUIViewController(context: Context) -> UIViewController {
                UIViewController()
            }
        }
        """

        #expect(ViewStyleChecker.check(source: source, fileName: "Lift.swift").isEmpty)
    }
}
