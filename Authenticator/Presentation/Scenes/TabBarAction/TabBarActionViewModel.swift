import RxCocoa
import RxSwift

protocol TabBarActionViewModel: AnyObject {
    var didLoadTrigger: AnyObserver<Void> { get }
    var closeTrigger: AnyObserver<Void> { get }
    var newPasswordTrigger: AnyObserver<Void> { get }
    var manualInputTrigger: AnyObserver<Void> { get }
    var qrScannerTrigger: AnyObserver<Void> { get }
}

final class TabBarActionViewModelImpl: TabBarActionViewModel {
    private let router: TabBarActionRouter

    private let didLoadSubject = PublishSubject<Void>()
    private(set) lazy var didLoadTrigger: AnyObserver<Void> = {
        return didLoadSubject.asObserver()
    }()

    private let closeSubject = PublishSubject<Void>()
    private(set) lazy var closeTrigger: AnyObserver<Void> = {
        closeSubject
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.router.dissmis()
            })
            .disposed(by: disposeBag)

        return closeSubject.asObserver()
    }()

    private let newPasswordSubject = PublishSubject<Void>()
    private(set) lazy var newPasswordTrigger: AnyObserver<Void> = {
        newPasswordSubject
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.router.showAddNewServiceInfo(with: .password("New password", "Continue"))
            })
            .disposed(by: disposeBag)

        return newPasswordSubject.asObserver()
    }()

    private let manualInputSubject = PublishSubject<Void>()
    private(set) lazy var manualInputTrigger: AnyObserver<Void> = {
        manualInputSubject
            .observe(on: MainScheduler.instance)
            .bind { [weak self] _ in
                self?.router.showAddNewServiceInfo(with: .authenticator("Add account", "Add account"))
            }
            .disposed(by: disposeBag)

        return manualInputSubject.asObserver()
    }()

    private let qrScannerSubject = PublishSubject<Void>()
    private(set) lazy var qrScannerTrigger: AnyObserver<Void> = {
        qrScannerSubject
            .observe(on: MainScheduler.instance)
            .flatMap{ [weak self] _ in
                self?.router.showQRScanner() ?? .never()
            }
            .subscribe(onNext: { [weak self] result in
                switch result {
                case .finished(let service):
                    self?.router.showAddNewServiceInfo(
                        with: .authenticator("Add account", "Add account"),
                        serviceDetailsModel: service
                    )
                case .cancelled:
                    print("cancellled")
                }
            })
            .disposed(by: disposeBag)
        return qrScannerSubject.asObserver()
    }()

    private let disposeBag = DisposeBag()

    init(router: TabBarActionRouter) {
        self.router = router
    }
}
