import UIKit

protocol DashboardBuilder {
    func build() -> UIViewController
}

final class DashboardBuilderImpl: DashboardBuilder {
    typealias Context = DashboardContainer
        & AuthenticatorContainer
        & PasswordsContainer
        & ServiceDetailsContainer
        & TabBarActionContainer
        & SettingsContainer
        & PremiumContainer
        & ChooseIconContainer
        & QRScannerContainer
        & DeleteAlertContainer
        & OnboardingContainer

    private let context: Context

    init(context: Context) {
        self.context = context
    }

    func build() -> UIViewController {
        let view = DashboardView()
        let router = DashboardRouterImpl(
            view: view,
            authenticatorBuilder: AuthenticatorBuilderImpl(context: context),
            passwordsBuilder: PasswordsBuilderImpl(context: context),
            tabBarActionBuilder: TabBarActionBuilderImpl(context: context)
        )
        let viewModel = DashboardViewModelImpl(router: router)
        view.viewModel = viewModel
        return view
    }
}
