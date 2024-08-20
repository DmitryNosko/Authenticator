import UIKit

protocol PasswordsBuilder {
    func build() -> UIViewController
}

final class PasswordsBuilderImpl: PasswordsBuilder {
    typealias Context = PasswordsContainer
    & ServiceDetailsContainer
    & SettingsContainer
    & PremiumContainer
    & ChooseIconContainer
    & DeleteAlertContainer

    private let context: Context

    init(context: Context) {
        self.context = context
    }

    func build() -> UIViewController {
        let view = PasswordsView()
        let router = PasswordsRouterImpl(
            view: view,
            createNewBuilder: ServiceDetailsBuilderImpl(context: context),
            settingsBuilder: SettingsBuilderImpl(context: context),
            deleteAlertBuilder: DeleteAlertBuilderImpl(context: context)
        )
        let viewModel = PasswordsViewModelImpl(router: router, credentialsRepository: context.credentialsRepository)
        view.viewModel = viewModel
        return view
    }
}
