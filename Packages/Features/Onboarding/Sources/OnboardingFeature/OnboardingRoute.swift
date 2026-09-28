public enum OnboardingRoute: Hashable {
    case name
    case birthday(name: String)
    case invite(pairingCode: String)
}
