import Data
import Domain
import MainFeature
import OnboardingFeature
import SignInFeature
import Supabase

final class AppContainer {
    let sessionState: SessionStateUseCase
    let widgetRegistrar: WidgetRegistrar
    let partnerName: PartnerNameUseCase
    let messageQuota: MessageQuotaUseCase

    private let supabase: SupabaseClient
    private let sessionRepository: SessionRepository
    private let profileRepository: ProfileRepository
    private let coupleRepository: CoupleRepository
    private let widgetSecretRepository: WidgetSecretRepository
    private let messageRepository: MessageRepository
    private let signInWithApple: SignInWithAppleUseCase
    private let completeProfile: CompleteProfileUseCase
    private let joinCouple: JoinCoupleUseCase
    private let currentCouple: CurrentCoupleUseCase
    private let sendMessage: SendMessageUseCase

    init(configuration: AppConfiguration) {
        supabase = SupabaseClient(
            supabaseURL: configuration.supabaseURL,
            supabaseKey: configuration.supabaseKey,
            options: SupabaseClientOptions(auth: .init(emitLocalSessionAsInitialSession: true))
        )
        sessionRepository = SupabaseSessionRepository(client: supabase)
        profileRepository = SupabaseProfileRepository(client: supabase)
        coupleRepository = SupabaseCoupleRepository(client: supabase)
        widgetSecretRepository = SupabaseWidgetSecretRepository(client: supabase)
        messageRepository = SupabaseMessageRepository(client: supabase)
        sessionState = AppSessionStateUseCase(
            sessionRepository: sessionRepository,
            profileRepository: profileRepository,
            coupleRepository: coupleRepository
        )
        signInWithApple = AppSignInWithAppleUseCase(repository: sessionRepository)
        completeProfile = AppCompleteProfileUseCase(repository: profileRepository)
        joinCouple = AppJoinCoupleUseCase(repository: coupleRepository)
        currentCouple = AppCurrentCoupleUseCase(repository: coupleRepository)
        partnerName = AppPartnerNameUseCase(repository: coupleRepository)
        messageQuota = AppMessageQuotaUseCase(repository: messageRepository)
        sendMessage = AppSendMessageUseCase(repository: messageRepository)
        widgetRegistrar = WidgetRegistrar(
            registerWidgetSecret: AppRegisterWidgetSecretUseCase(repository: widgetSecretRepository)
        )
    }

    func makeSignInFeature() -> SignInFeature {
        SignInFeature(signInWithApple: signInWithApple)
    }

    func makeOnboardingFeature() -> OnboardingFeature {
        OnboardingFeature(completeProfile: completeProfile, joinCouple: joinCouple, currentCouple: currentCouple)
    }

    func makeMainFeature(session: HomeSession) -> MainFeature {
        MainFeature(
            couple: session.couple,
            partnerName: session.partnerName,
            quota: session.quota,
            messageQuota: messageQuota,
            sendMessage: sendMessage,
            loadPartnerName: partnerName
        )
    }
}
