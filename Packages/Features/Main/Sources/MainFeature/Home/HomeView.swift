import DesignSystem
import Domain
import SwiftUI

struct HomeView: View {
    @State private var model: HomeViewModel
    @FocusState private var isComposerFocused: Bool
    @State private var composerLineCount = 1

    init(model: HomeViewModel) {
        _model = State(initialValue: model)
    }

    private var stageScale: CGFloat {
        guard isComposerFocused else { return 1 }
        switch composerLineCount {
        case 1: return 0.72
        case 2: return 0.66
        default: return 0.55
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            WidgetCarousel(text: model.trimmedDraft, scale: stageScale, selection: $model.selectedWidget)
                .padding(.top, -WidgetCarousel.dynamicIslandInset)
            Spacer(minLength: 0)
            VStack(spacing: Spacing.space2) {
                QuickNotes(notes: model.quickNotes, selected: model.draft) { note in
                    model.pickQuickNote(note)
                }
                .padding(.bottom, Spacing.space1)
                NoteComposer(
                    partnerName: model.partnerName,
                    text: $model.draft,
                    isFocused: $isComposerFocused,
                    lineCount: $composerLineCount,
                    maxLength: HomeViewModel.maxNoteLength,
                    canSend: model.canSend
                ) {
                    withAnimation { model.send() }
                }
                .onChange(of: model.draft) {
                    if model.removeLineBreaks() {
                        isComposerFocused = false
                    }
                    model.limitDraft()
                }
                .onChange(of: isComposerFocused) { model.isComposerFocused = isComposerFocused }
                .onChange(of: model.isComposerFocused) { isComposerFocused = model.isComposerFocused }
                .padding(.horizontal, Spacing.space4)
            }
            .liftsAboveKeyboard(spacing: Spacing.space2)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .dismissesKeyboardOnTap()
        .ignoresKeyboardLayout()
        .ignoresSafeArea(.keyboard)
        .background { AppBackground() }
    }
}

#Preview {
    HomeView(model: HomeViewModel(couple: CoupleID(rawValue: UUID()), navigator: .preview))
}
