import Domain
import Foundation
import Testing
@testable import OnboardingFeature

@MainActor
struct BirthdayViewModelTests {
    private static let calendar = Calendar(identifier: .gregorian)
    private static let now = calendar.date(from: DateComponents(year: 2026, month: 9, day: 28, hour: 12)) ?? .now

    @Test
    func rangeAllowsAgesFromThirteenToOneHundredFifty() {
        let model = makeModel(useCase: RecordingCompleteProfileUseCase(), recorder: NavigatorRecorder())

        #expect(model.range.lowerBound == Self.date(year: 1876, month: 9, day: 28))
        #expect(model.range.upperBound == Self.date(year: 2013, month: 9, day: 28))
        #expect(model.birthday == Self.date(year: 1996, month: 5, day: 14))
    }

    @Test
    func submitSavesProfileAndOpensInvite() async {
        let useCase = RecordingCompleteProfileUseCase()
        let recorder = NavigatorRecorder()
        let model = makeModel(useCase: useCase, recorder: recorder)

        await model.submit()

        #expect(useCase.received == ["Alex 1996-5-14"])
        #expect(recorder.routes == [.invite(pairingCode: "K7M2QX")])
        #expect(!model.isSaving)
    }

    @Test
    func failedSaveStaysOnScreen() async {
        let recorder = NavigatorRecorder()
        let model = makeModel(useCase: RecordingCompleteProfileUseCase(error: .unknown), recorder: recorder)

        await model.submit()

        #expect(recorder.routes.isEmpty)
        #expect(!model.isSaving)
    }

    private func makeModel(useCase: RecordingCompleteProfileUseCase, recorder: NavigatorRecorder) -> BirthdayViewModel {
        BirthdayViewModel(
            name: "Alex",
            completeProfile: useCase,
            navigator: recorder.navigator,
            now: Self.now,
            calendar: Self.calendar
        )
    }

    private static func date(year: Int, month: Int, day: Int) -> Date? {
        calendar.date(from: DateComponents(year: year, month: month, day: day))
    }
}

@MainActor
private final class RecordingCompleteProfileUseCase: CompleteProfileUseCase {
    private(set) var received: [String] = []
    private let error: CommonError?

    init(error: CommonError? = nil) {
        self.error = error
    }

    func callAsFunction(name: String, birthDate: BirthDate) async throws -> Profile {
        received.append("\(name) \(birthDate.year)-\(birthDate.month)-\(birthDate.day)")
        if let error {
            throw error
        }
        return Profile(id: UserID(rawValue: UUID()), name: name, birthDate: birthDate, pairingCode: "K7M2QX")
    }
}
