import UIKit

protocol QRScannerBuilder {
    func build(onFinish: @escaping (ServiceDetailsModel) -> Void, onCancel: @escaping () -> Void) -> UIViewController
}

final class QRScannerBuilderImpl: QRScannerBuilder {
    typealias Context = QRScannerContainer

    private let context: Context

    init(context: Context) {
        self.context = context
    }

    func build(onFinish: @escaping (ServiceDetailsModel) -> Void, onCancel: @escaping () -> Void) -> UIViewController {
        let view = QRScannerView()
        let router = QRScannerRouterImpl(
            view: view,
            onFinish: onFinish,
            onCancel: onCancel
        )
        let viewModel = QRScannerViewModelImpl(router: router, servicesRepository: ServicesRepositoryImpl())
        view.viewModel = viewModel

        return view
    }
}
