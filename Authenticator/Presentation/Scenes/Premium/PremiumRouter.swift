import UIKit
import MessageUI

protocol PremiumRouter {
    func dismiss()
}

final class PremiumRouterImpl: PremiumRouter {
    private weak var view: UIViewController?

    init(view: UIViewController) {
        self.view = view
    }

    func dismiss() {
        self.view?.dismiss(animated: true)
    }
}
