import UIKit

protocol ChooseIconBuilder {
    func build(onFinish: @escaping (Service) -> Void, onCancel: @escaping () -> Void) -> UIViewController
}

final class ChooseIconBuilderImpl: ChooseIconBuilder {
    typealias Context = ChooseIconContainer

    private let context: Context

    init(context: Context) {
        self.context = context
    }

    func build(onFinish: @escaping (Service) -> Void, onCancel: @escaping () -> Void) -> UIViewController {
        let view = ChooseIconView()
        let router = ChooseIconRouterImpl(
            view: view,
            onFinish: onFinish,
            onCancel: onCancel
        )
        let viewModel = ChooseIconViewModelImpl(
            router: router,
            servicesRepository: context.servicesRepository
        )
        view.viewModel = viewModel

        return view
    }
}
