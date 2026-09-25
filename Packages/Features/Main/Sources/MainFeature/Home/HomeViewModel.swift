import Domain
import Observation

@Observable
final class HomeViewModel {
    let couple: CoupleID

    private let navigator: MainNavigator

    init(couple: CoupleID, navigator: MainNavigator) {
        self.couple = couple
        self.navigator = navigator
    }
}
