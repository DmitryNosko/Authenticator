import RxCocoa
import RxSwift

protocol QRScannerViewModel: AnyObject {
    var closeTrigger: AnyObserver<Void> { get }
    var scanTrigger: AnyObserver<String?> { get }
}

final class QRScannerViewModelImpl: NSObject, QRScannerViewModel {
    private let router: QRScannerRouter
    private let servicesRepository: ServicesRepository

    private let closeSubject = PublishSubject<Void>()
    private(set) lazy var closeTrigger: AnyObserver<Void> = {
        closeSubject
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.router.cancel()
            })
            .disposed(by: disposeBag)
        return closeSubject.asObserver()
    }()

    private let scanSubject = PublishSubject<String?>()
    private(set) lazy var scanTrigger: AnyObserver<String?> = {
        scanSubject
            .subscribe(onNext: { [weak self] scannedText in
                guard let urlString = scannedText,
                      let urlComponents = URLComponents(string: urlString),
                      urlComponents.scheme == "otpauth",
                      let secret = urlComponents.queryItems?.first(where: { $0.name == "secret" })?.value
                else { return }
                let issuer = urlComponents.queryItems?.first(where: { $0.name == "issuer" })?.value
                let login = urlComponents.path.components(separatedBy: ":").last
                let service = self?.servicesRepository.service(name: issuer ?? "") ?? .default
                let serviceDetailsModel = ServiceDetailsModel(
                    uid: nil,
                    serviceName: issuer,
                    key: secret,
                    login: login,
                    service: service
                )

                self?.router.finish(service: serviceDetailsModel)
            })
            .disposed(by: disposeBag)
        return scanSubject.asObserver()
    }()

    private let disposeBag = DisposeBag()

    init(router: QRScannerRouter, servicesRepository: ServicesRepository) {
        self.router = router
        self.servicesRepository = servicesRepository
        super.init()
    }
}
