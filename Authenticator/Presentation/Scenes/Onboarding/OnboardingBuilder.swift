import UIKit

protocol OnboardingBuilder {
    func build() -> UIViewController
}

final class OnboardingBuilderImpl: OnboardingBuilder {
    typealias Context = AuthenticatorContainer
        & ServiceDetailsContainer
        & ChooseIconContainer
        & SettingsContainer
        & PremiumContainer
        & OnboardingContainer
        & DashboardContainer
        & PasswordsContainer
        & TabBarActionContainer
        & DeleteAlertContainer
        & QRScannerContainer

    private let context: Context

    init(context: Context) {
        self.context = context
    }

    func build() -> UIViewController {
        let view = OnboardingView()
        let router = OnboardingRouterImpl(
            view: view,
            dashboardBuilder: DashboardBuilderImpl(context: context)
        )
        let viewModel = OnboardingViewModelImpl(
            router: router,
            userDefaultsStore: context.userDefaultsStore
        )
        view.viewModel = viewModel
        return view
    }
}
