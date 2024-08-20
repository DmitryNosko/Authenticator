import UIKit

protocol DeleteAlertBuilder {
    func build(completion: @escaping (SimpleFlowResult) -> Void) -> UIViewController
}

final class DeleteAlertBuilderImpl: DeleteAlertBuilder {
    typealias Context = DeleteAlertContainer

    private let context: Context

    init(context: Context) {
        self.context = context
    }

    func build(completion: @escaping (SimpleFlowResult) -> Void) -> UIViewController {
        let view = DeleteAlertView()
        let router = DeleteAlertRouterImpl(
            view: view,
            completion: completion
        )
        let viewModel = DeleteAlertViewModelImpl(
            router: router
        )
        view.viewModel = viewModel
        return view
    }
}
