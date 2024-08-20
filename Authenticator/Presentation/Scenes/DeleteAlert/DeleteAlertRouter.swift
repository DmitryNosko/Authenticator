import UIKit

protocol DeleteAlertRouter {
    func finish()
    func cancel()
}

final class DeleteAlertRouterImpl: DeleteAlertRouter {
    private weak var view: UIViewController?
    private let completion: (SimpleFlowResult) -> Void

    init(view: UIViewController, completion: @escaping (SimpleFlowResult) -> Void) {
        self.view = view
        self.completion = completion
    }

    func finish() {
        view?.dismiss(animated: true, completion: { [weak self] in
            self?.completion(.finished)
        })
    }

    func cancel() {
        view?.dismiss(animated: true, completion: { [weak self] in
            self?.completion(.cancelled)
        })
    }
}
