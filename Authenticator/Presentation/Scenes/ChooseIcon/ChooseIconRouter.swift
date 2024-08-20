import UIKit

protocol ChooseIconRouter {
    func terminate()
    func finish(service: Service)
    func cancel()
}

final class ChooseIconRouterImpl: ChooseIconRouter {
    private weak var view: UIViewController?
    private let onFinish: (Service) -> Void
    private let onCancel: () -> Void

    init(view: UIViewController, onFinish: @escaping (Service) -> Void, onCancel: @escaping () -> Void) {
        self.view = view
        self.onFinish = onFinish
        self.onCancel = onCancel
    }

    func terminate() {
        view?.dismiss(animated: true)
    }

    func cancel() {
        onCancel()
        view?.navigationController?.popViewController(animated: true)
    }

    func finish(service: Service) {
        onFinish(service)
        view?.navigationController?.popViewController(animated: true)
    }
}
