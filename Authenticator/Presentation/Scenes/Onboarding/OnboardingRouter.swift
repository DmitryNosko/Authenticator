import UIKit

protocol OnboardingRouter {
    func showMainScreen()
    func showSafari(with urlString: String)
}

final class OnboardingRouterImpl: OnboardingRouter {
    private weak var view: UIViewController?
    private let dashboardBuilder: DashboardBuilder

    init(view: UIViewController, dashboardBuilder: DashboardBuilder) {
        self.view = view
        self.dashboardBuilder = dashboardBuilder
    }

    func showMainScreen() {
        let dashboardView = dashboardBuilder.build()
        dashboardView.modalPresentationStyle = .fullScreen
        view?.present(dashboardView, animated: true)
    }

    func showSafari(with urlString: String) {
        guard let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) else {
            return
        }
        UIApplication.shared.open(url)
    }
}
