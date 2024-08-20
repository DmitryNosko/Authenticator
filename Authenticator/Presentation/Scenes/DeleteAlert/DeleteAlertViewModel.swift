import RxCocoa
import RxSwift

protocol DeleteAlertViewModel {
    var cancelTrigger: AnyObserver<Void> { get }
    var confirmTrigger: AnyObserver<Void> { get }
}

final class DeleteAlertViewModelImpl: DeleteAlertViewModel {
    private let router: DeleteAlertRouter

    private let cancelSubject = PublishSubject<Void>()
    private(set) lazy var cancelTrigger: AnyObserver<Void> = {
        cancelSubject
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.router.cancel()
            })
            .disposed(by: disposeBag)
        return cancelSubject.asObserver()
    }()

    private let confirmSubject = PublishSubject<Void>()
    private(set) lazy var confirmTrigger: AnyObserver<Void> = {
        confirmSubject
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.router.finish()
            })
            .disposed(by: disposeBag)
        return confirmSubject.asObserver()
    }()

    private let disposeBag = DisposeBag()

    init(router: DeleteAlertRouter) {
        self.router = router
    }
}
