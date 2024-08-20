import RxCocoa
import RxSwift

protocol DashboardViewModel: AnyObject {
    var didLoadTrigger: AnyObserver<Void> { get }
    var createTrigger: AnyObserver<Void> { get }
}

final class DashboardViewModelImpl: DashboardViewModel {
    private let router: DashboardRouter

    private let didLoadSubject = PublishSubject<Void>()
    private(set) lazy var didLoadTrigger: AnyObserver<Void> = {
        didLoadSubject
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.router.showTabs()
            })
            .disposed(by: disposeBag)
        return didLoadSubject.asObserver()
    }()

    private let createSubject = PublishSubject<Void>()
    private(set) lazy var createTrigger: AnyObserver<Void> = {
        createSubject
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.router.showCreateSubject()
            })
            .disposed(by: disposeBag)
        return createSubject.asObserver()
    }()

    private let disposeBag = DisposeBag()

    init(router: DashboardRouter) {
        self.router = router
    }
}
