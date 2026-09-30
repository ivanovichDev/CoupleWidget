import DesignSystem
import Domain
import SwiftUI

struct HomeView: View {
    @State private var model: HomeViewModel
    @State private var composerLineCount = 1
    @FocusState private var isComposerFocused: Bool

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

    private var isShowingError: Binding<Bool> {
        Binding {
            model.errorMessage != nil
        } set: { isPresented in
            if !isPresented {
                model.errorMessage = nil
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            WidgetCarousel(text: model.trimmedDraft, scale: stageScale, selection: $model.selectedWidget)
                .padding(.top, -WidgetCarousel.dynamicIslandInset)
            Spacer(minLength: 0)
            VStack(spacing: Spacing.space2) {
                QuickNotes(
                    notes: model.quickNotes,
                    selected: model.draft,
                    isEnabled: model.composerLock == nil
                ) { note in
                    model.pickQuickNote(note)
                }
                .padding(.bottom, Spacing.space1)
                NoteComposer(
                    partnerName: model.partnerName,
                    notesLeft: model.notesLeft,
                    notesLeftAccessibilityText: model.notesLeftAccessibilityLabel,
                    isLimitReached: model.isLimitReached,
                    lock: model.composerLock,
                    text: $model.draft,
                    isFocused: $isComposerFocused,
                    lineCount: $composerLineCount,
                    maxLength: HomeViewModel.maxNoteLength,
                    canSend: model.canSend
                ) {
                    Task { await model.send() }
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
        .task { await model.run() }
        .alert(String(localized: "Couldn't send the note"), isPresented: isShowingError) {
            Button(String(localized: "OK"), role: .cancel) {}
        } message: {
            Text(model.errorMessage ?? "")
        }
    }
}

#Preview("Live") {
    HomeView(model: .preview(quota: PreviewMessageQuotaUseCase.quota(left: 7, cooldownRemaining: 0)))
}

#Preview("Cooldown") {
    HomeView(model: .preview(quota: PreviewMessageQuotaUseCase.quota(left: 6, cooldownRemaining: 24)))
}

#Preview("Limit") {
    HomeView(model: .preview(quota: PreviewMessageQuotaUseCase.quota(left: 0, cooldownRemaining: 0)))
}

private extension HomeViewModel {
    static func preview(quota: MessageQuota) -> HomeViewModel {
        HomeViewModel(
            couple: CoupleID(rawValue: UUID()),
            partnerName: "Anna",
            quota: quota,
            messageQuota: PreviewMessageQuotaUseCase(),
            sendMessage: PreviewSendMessageUseCase(),
            loadPartnerName: PreviewPartnerNameUseCase(),
            navigator: .preview
        )
    }
}

private struct PreviewMessageQuotaUseCase: MessageQuotaUseCase {
    static func quota(left: Int, cooldownRemaining: TimeInterval) -> MessageQuota {
        MessageQuota(
            dailyLimit: 10,
            messagesLeft: left,
            cooldown: 30,
            cooldownRemaining: cooldownRemaining,
            resetRemaining: 34_867
        )
    }

    func callAsFunction() async throws -> MessageQuota {
        Self.quota(left: 7, cooldownRemaining: 0)
    }
}

private struct PreviewSendMessageUseCase: SendMessageUseCase {
    func callAsFunction(_ text: String) async throws -> MessageQuota {
        PreviewMessageQuotaUseCase.quota(left: 6, cooldownRemaining: 30)
    }
}

private struct PreviewPartnerNameUseCase: PartnerNameUseCase {
    func callAsFunction() async throws -> String {
        "Anna"
    }
}
