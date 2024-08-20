import UIKit
import RxSwift

protocol QRScannerRouter {
    func finish(service: ServiceDetailsModel)
    func cancel()
}

final class QRScannerRouterImpl: QRScannerRouter {
    private weak var view: UIViewController?
    private let onFinish: (ServiceDetailsModel) -> Void
    private let onCancel: () -> Void

    init
    (
        view: UIViewController,
        onFinish: @escaping (ServiceDetailsModel) -> Void,
        onCancel: @escaping () -> Void)
    {
        self.view = view
        self.onFinish = onFinish
        self.onCancel = onCancel
    }

    func cancel() {
        onCancel()
        view?.dismiss(animated: true)
    }

    func finish(service: ServiceDetailsModel) {
        view?.dismiss(animated: true, completion: { [weak self] in
            self?.onFinish(service)
        })
    }
}
