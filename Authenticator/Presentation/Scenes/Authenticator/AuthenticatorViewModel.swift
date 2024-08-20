import RxCocoa
import RxSwift

protocol AuthenticatorViewModel: AnyObject {
    var willAppearTrigger: AnyObserver<Void> { get }
    var refreshTrigger: AnyObserver<Void> { get }
    var manualInputTrigger: AnyObserver<Void> { get }
    var settingsTrigger: AnyObserver<Void> { get }
    var searchQuery: AnyObserver<String?> { get }
    var editTrigger: AnyObserver<IndexPath> { get }
    var deleteTrigger: AnyObserver<IndexPath> { get }
    var scanTrigger: AnyObserver<Void> { get }

    var authenticators: Driver<[Authenticator]> { get }

    func authenticatorViewModel(_ authenticator: Authenticator) -> AuthenticatorContentViewModel
}

final class AuthenticatorViewModelImpl: AuthenticatorViewModel {
    typealias Router = AuthenticatorRouter & AuthenticatorContentRouter

    private let router: Router
    private let authenticatorsRepository: AuthenticatorsRepository
    private let authenticatorService: AuthenticatorService
    private let userDefaultsStore: UserDefaultsStore

    private let willAppearSubject = PublishSubject<Void>()
    private(set) lazy var willAppearTrigger: AnyObserver<Void> = {
        willAppearSubject
            .bind(to: refreshTrigger)
            .disposed(by: disposeBag)
        return willAppearSubject.asObserver()
    }()

    private let refreshSubject = PublishSubject<Void>()
    private(set) lazy var refreshTrigger: AnyObserver<Void> = {
        refreshSubject
            .bind(to: authenticatorsRepository.refreshTrigger)
            .disposed(by: disposeBag)
        return refreshSubject.asObserver()
    }()

    private let authenticatorsSubject = BehaviorSubject<[Authenticator]>(value: [])
    private(set) lazy var authenticators: Driver<[Authenticator]> = {
        Observable.combineLatest(authenticatorsRepository.authenticators, searchQuerySubject)
            .map { authenticators, searchQuery in
                guard let searchQuery = searchQuery, !searchQuery.isEmpty else { return authenticators }
                return authenticators.filter {
                    $0.email.localizedCaseInsensitiveContains(searchQuery)
                    || $0.name.localizedCaseInsensitiveContains(searchQuery)
                    || $0.service.serviceName.localizedCaseInsensitiveContains(searchQuery)
                }
            }
            .bind(to: authenticatorsSubject)
            .disposed(by: disposeBag)
        return authenticatorsSubject.asDriver(onErrorJustReturn: [])
    }()

    private let manualInputSubject = PublishSubject<Void>()
    private(set) lazy var manualInputTrigger: AnyObserver<Void> = {
        manualInputSubject
            .observe(on: MainScheduler.instance)
            .bind { [weak self] _ in
                self?.router.showServiceDetailsScreen(
                    with: .authenticator("Add account", "Add account"),
                    serviceDetailsModel: ServiceDetailsModel.empty
                )
            }
            .disposed(by: disposeBag)

        return manualInputSubject.asObserver()
    }()
    
    private let settingsSubject = PublishSubject<Void>()
    private(set) lazy var settingsTrigger: AnyObserver<Void> = {
        settingsSubject
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.router.showSettings()
            })
            .disposed(by: disposeBag)
        return settingsSubject.asObserver()
    }()

    private let searchQuerySubject = PublishSubject<String?>()
    private(set) lazy var searchQuery: AnyObserver<String?> = {
        return searchQuerySubject.asObserver()
    }()

    private let editSubject = PublishSubject<IndexPath>()
    private(set) lazy var editTrigger: AnyObserver<IndexPath> = {
        editSubject
            .withLatestFrom(authenticators) { ($0, $1) }
            .compactMap { indexPath, authenticators -> Authenticator? in
                guard authenticators.indices.contains(indexPath.row) else { return nil }
                return authenticators[indexPath.row]
            }
            .subscribe(onNext: { [weak self] authenticator in
                let serviceDetailsModel = ServiceDetailsModel(
                    uid: authenticator.uid,
                    serviceName: authenticator.name,
                    key: authenticator.secret,
                    login: authenticator.email,
                    service: authenticator.service
                )
                self?.router.showServiceDetailsScreen(
                    with: .authenticator("Edit Data", "Save changes"),
                    serviceDetailsModel: serviceDetailsModel
                )
            })
            .disposed(by: disposeBag)
        return editSubject.asObserver()
    }()

    private let scanSubject = PublishSubject<Void>()
    private(set) lazy var scanTrigger: AnyObserver<Void> = {
        scanSubject
            .observe(on: MainScheduler.instance)
            .flatMap{ [weak self] _ in
                self?.router.showQRScanner() ?? .never()
            }
            .subscribe(onNext: { [weak self] result in
                switch result {
                case .finished(let service):
                    self?.router.showServiceDetailsScreen(
                        with: .authenticator("Add account", "Add account"),
                        serviceDetailsModel: service
                    )
                case .cancelled:
                    print("cancellled")
                }
            })
            .disposed(by: disposeBag)

        return scanSubject.asObserver()
    }()

    private let deleteSubject = PublishSubject<IndexPath>()
    private(set) lazy var deleteTrigger: AnyObserver<IndexPath> = {
        deleteSubject
            .flatMap { [weak self] indexPath -> Single<(SimpleFlowResult, IndexPath)> in
                self?.router.showDeleteAlert()
                    .map { [indexPath] in ($0, indexPath) } ?? .never()
            }
            .filter { result, _ in
                guard case .finished = result else { return false }
                return true
            }
            .withLatestFrom(authenticators) { ($0.1, $1) }
            .compactMap { indexPath, authenticators -> Authenticator? in
                guard authenticators.indices.contains(indexPath.row) else { return nil }
                return authenticators[indexPath.row]
            }
            .subscribe(onNext: { [weak self] authenticator in
                self?.authenticatorsRepository.delete(authenticator: authenticator)
            })
            .disposed(by: disposeBag)
        return deleteSubject.asObserver()
    }()

    private let disposeBag = DisposeBag()

    init(
        router: Router,
        authenticatorsRepository: AuthenticatorsRepository,
        authenticatorService: AuthenticatorService,
        userDefaultsStore: UserDefaultsStore
    ) {
        self.router = router
        self.authenticatorsRepository = authenticatorsRepository
        self.authenticatorService = authenticatorService
        self.userDefaultsStore = userDefaultsStore
    }

    func authenticatorViewModel(_ authenticator: Authenticator) -> AuthenticatorContentViewModel {
        return AuthenticatorContentViewModelImpl(
            router: router,
            authenticatorService: authenticatorService,
            authenticator: authenticator
        )
    }
}
