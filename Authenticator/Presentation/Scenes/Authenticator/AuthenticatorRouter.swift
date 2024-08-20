import RxSwift
import UIKit

protocol AuthenticatorRouter {
    func showSettings()
    func showServiceDetailsScreen(with type: ServiceType, serviceDetailsModel: ServiceDetailsModel)
    func showDeleteAlert() -> Single<SimpleFlowResult>
    func showQRScanner() -> Single<FlowResult<ServiceDetailsModel>>
}

final class AuthenticatorRouterImpl: AuthenticatorRouter, AuthenticatorContentRouter {
    private weak var view: UIViewController?
    private let addNewServiceInfoBuilder: ServiceDetailsBuilder
    private let settingsBuilder: SettingsBuilder
    private let deleteAlertBuilder: DeleteAlertBuilder
    private let qrScannerBuilder: QRScannerBuilder

    init(
        view: UIViewController,
        addNewServiceInfoBuilder: ServiceDetailsBuilder,
        settingsBuilder: SettingsBuilder,
        deleteAlertBuilder: DeleteAlertBuilder,
        qrScannerBuilder: QRScannerBuilder
    ) {
        self.view = view
        self.addNewServiceInfoBuilder = addNewServiceInfoBuilder
        self.settingsBuilder = settingsBuilder
        self.deleteAlertBuilder = deleteAlertBuilder
        self.qrScannerBuilder = qrScannerBuilder
    }

    func showServiceDetailsScreen(with type: ServiceType, serviceDetailsModel: ServiceDetailsModel) {
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

    func showSettings() {
        let settingsView = settingsBuilder.build()
        let settingsNavigationView = UINavigationController(rootViewController: settingsView)
        settingsNavigationView.modalPresentationStyle = .fullScreen
        
        view?.present(settingsNavigationView, animated: true)
    }

    func showAlert(title: String?, message: String?) {
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        view?.present(alertView, animated: true, completion: { [alertView] in
            alertView.dismiss(animated: true)
        })
    }

    func showDeleteAlert() -> Single<SimpleFlowResult> {
        return .create { [weak self] single in
            guard let self = self else { return Disposables.create() }
            let alertView = self.deleteAlertBuilder.build(completion: { result in
                single(.success(result))
            })
            alertView.modalPresentationStyle = .overFullScreen
            alertView.modalTransitionStyle = .crossDissolve
            self.view?.present(alertView, animated: true)
            return Disposables.create { [weak alertView] in
                alertView?.dismiss(animated: true)
            }
        }
    }
}
