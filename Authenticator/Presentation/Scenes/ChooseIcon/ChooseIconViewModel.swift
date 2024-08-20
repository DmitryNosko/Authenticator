import RxSwift
import RxCocoa

protocol ChooseIconViewModel {
    var didLoadTrigger: AnyObserver<Void> { get }
    var backTrigger: AnyObserver<Void> { get }
    var closeTrigger: AnyObserver<Void> { get }
    var continueTrigger: AnyObserver<Void> { get }
    var selectedTrigger: AnyObserver<IndexPath> { get }
    var isContinueButtonEnabled: Driver<Bool> { get }
    var services: Driver<[Service]> { get }
}

final class ChooseIconViewModelImpl: ChooseIconViewModel {
    private let router: ChooseIconRouter
    private let servicesRepository: ServicesRepository

    private let didLoadSubject = PublishSubject<Void>()
    private(set) lazy var didLoadTrigger: AnyObserver<Void> = {
        didLoadSubject
            .bind(to: refreshTrigger)
            .disposed(by: disposeBag)
        return didLoadSubject.asObserver()
    }()

    private let refreshSubject = PublishSubject<Void>()
    private(set) lazy var refreshTrigger: AnyObserver<Void> = {
        refreshSubject
            .bind(to: servicesRepository.refreshTrigger)
            .disposed(by: disposeBag)
        return refreshSubject.asObserver()
    }()

    private let servicesSubject = BehaviorSubject<[Service]>(value: [])
    private(set) lazy var services: Driver<[Service]> = {
        servicesRepository.services
            .bind(to: servicesSubject)
            .disposed(by: disposeBag)
        return servicesSubject.asDriver(onErrorJustReturn: [])
    }()

    private let backSubject = PublishSubject<Void>()
    private(set) lazy var backTrigger: AnyObserver<Void> = {
        backSubject
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.router.cancel()
            })
            .disposed(by: disposeBag)

        return backSubject.asObserver()
    }()

    private let closeSubject = PublishSubject<Void>()
    private(set) lazy var closeTrigger: AnyObserver<Void> = {
        closeSubject
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.router.terminate()
            })
            .disposed(by: disposeBag)

        return closeSubject.asObserver()
    }()

    private let continueSubject = PublishSubject<Void>()
    private(set) lazy var continueTrigger: AnyObserver<Void> = {
        continueSubject
            .observe(on: MainScheduler.instance)
            .withLatestFrom(selectedIcon)
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] service in
                self?.router.finish(service: service)
            })
            .disposed(by: disposeBag)
        return continueSubject.asObserver()
    }()

    private let selectedIcon = BehaviorSubject<Service?>(value: nil)

    private let selectedSubject = PublishSubject<IndexPath>()
    private(set) lazy var selectedTrigger: AnyObserver<IndexPath> = {
        selectedSubject
            .withLatestFrom(services) { ($0, $1) }
            .compactMap { [weak self] indexPath, services -> Service? in
                guard services.indices.contains(indexPath.row) else { return nil }
                return services[indexPath.row]
            }
            .bind(to: selectedIcon)
            .disposed(by: disposeBag)

        return selectedSubject.asObserver()
    }()

    private(set) lazy var isContinueButtonEnabled: Driver<Bool> = {
        return selectedIcon
            .map { $0 != nil }
            .asDriver(onErrorJustReturn: false)
    }()

    private let disposeBag = DisposeBag()

    init(
        router: ChooseIconRouter,
        servicesRepository: ServicesRepository
    ) {
        self.router = router
        self.servicesRepository = servicesRepository
    }
}
