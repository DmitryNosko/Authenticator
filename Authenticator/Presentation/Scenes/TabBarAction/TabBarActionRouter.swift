import UIKit
import RxSwift

protocol TabBarActionRouter {
    func dissmis()
    func showAddNewServiceInfo(with type: ServiceType, serviceDetailsModel: ServiceDetailsModel)
    func showQRScanner() -> Single<FlowResult<ServiceDetailsModel>>
}

extension TabBarActionRouter {
    func showAddNewServiceInfo(with type: ServiceType, serviceDetailsModel: ServiceDetailsModel = ServiceDetailsModel.empty) {
        return showAddNewServiceInfo(with: type, serviceDetailsModel: serviceDetailsModel)
    }
}

final class TabBarActionRouterImpl: TabBarActionRouter {
    private weak var view: UIViewController?
    private let addNewServiceInfoBuilder: ServiceDetailsBuilder
    private let qrScannerBuilder: QRScannerBuilder

    init(view: UIViewController, addNewServiceInfoBuilder: ServiceDetailsBuilder, qrScannerBuilder: QRScannerBuilder) {
        self.view = view
        self.addNewServiceInfoBuilder = addNewServiceInfoBuilder
        self.qrScannerBuilder = qrScannerBuilder
    }

    func dissmis() {
        view?.dismiss(animated: true)
    }

    func showAddNewServiceInfo(with type: ServiceType, serviceDetailsModel: ServiceDetailsModel) {
        let addNewServiceInfoView = addNewServiceInfoBuilder.build(type, serviceDetailsModel: serviceDetailsModel)
        let addNewServiceInfoNavigationView = UINavigationController(rootViewController: addNewServiceInfoView)
        addNewServiceInfoNavigationView.modalPresentationStyle = .pageSheet
        addNewServiceInfoNavigationView.setNavigationBarHidden(true, animated: false)
        if let sheet = addNewServiceInfoNavigationView.sheetPresentationController{
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 24
        }

        view?.present(addNewServiceInfoNavigationView, animated: true)
    }

    func showQRScanner() -> Single<FlowResult<ServiceDetailsModel>> {
        return .create { [weak self] single in
            guard let self else { return Disposables.create() }

            let qrScannerView = qrScannerBuilder.build { serviceDetailsModel in
                single(.success(.finished(serviceDetailsModel)))
            } onCancel: {
                single(.success(.cancelled))
            }

            qrScannerView.modalPresentationStyle = .fullScreen

            view?.navigationController?.present(qrScannerView, animated: true)

            return Disposables.create()
        }
    }
}
