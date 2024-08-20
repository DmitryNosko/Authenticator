import UIKit

protocol AuthenticatorBuilder {
    func build() -> UIViewController
}

final class AuthenticatorBuilderImpl: AuthenticatorBuilder {
    typealias Context = AuthenticatorContainer
        & ServiceDetailsContainer
        & SettingsContainer
        & PremiumContainer
        & ChooseIconContainer
        & DeleteAlertContainer
        & QRScannerContainer

    private let context: Context

    init(context: Context) {
        self.context = context
    }

    func build() -> UIViewController {
        let view = AuthenticatorView()
        let router = AuthenticatorRouterImpl(
            view: view,
            addNewServiceInfoBuilder: ServiceDetailsBuilderImpl(context: context),
            settingsBuilder: SettingsBuilderImpl(context: context),
            deleteAlertBuilder: DeleteAlertBuilderImpl(context: context),
            qrScannerBuilder: QRScannerBuilderImpl(context: context)
        )
        let viewModel = AuthenticatorViewModelImpl(
            router: router,
            authenticatorsRepository: context.authenticatorsRepository,
            authenticatorService: context.authenticatorService,
            userDefaultsStore: context.userDefaultsStore
        )
        view.viewModel = viewModel
        return view
    }
}
