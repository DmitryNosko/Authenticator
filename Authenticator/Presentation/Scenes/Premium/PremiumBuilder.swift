import UIKit

protocol PremiumBuilder {
    func build() -> UIViewController
}

final class PremiumBuilderImpl: PremiumBuilder {
    typealias Context = PremiumContainer

    private let context: Context

    init(context: Context) {
        self.context = context
    }

    func build() -> UIViewController {
        let view = PremiumView()
        let router = PremiumRouterImpl(view: view)
        let viewModel = PremiumViewModelImpl(router: router)
        view.viewModel = viewModel
        return view
    }
}
