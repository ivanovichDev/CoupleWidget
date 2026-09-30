import Domain
import SwiftUI

public struct MainFeature {
    private let couple: CoupleID
    private let partnerName: String?
    private let quota: MessageQuota?
    private let messageQuota: MessageQuotaUseCase
    private let sendMessage: SendMessageUseCase
    private let loadPartnerName: PartnerNameUseCase

    public init(
        couple: CoupleID,
        partnerName: String?,
        quota: MessageQuota?,
        messageQuota: MessageQuotaUseCase,
        sendMessage: SendMessageUseCase,
        loadPartnerName: PartnerNameUseCase
    ) {
        self.couple = couple
        self.partnerName = partnerName
        self.quota = quota
        self.messageQuota = messageQuota
        self.sendMessage = sendMessage
        self.loadPartnerName = loadPartnerName
    }

    @ViewBuilder
    public func view(for route: MainRoute, navigator: MainNavigator) -> some View {
        switch route {
        case .home:
            HomeView(model: HomeViewModel(
                couple: couple,
                partnerName: partnerName,
                quota: quota,
                messageQuota: messageQuota,
                sendMessage: sendMessage,
                loadPartnerName: loadPartnerName,
                navigator: navigator
            ))
        }
    }
}
