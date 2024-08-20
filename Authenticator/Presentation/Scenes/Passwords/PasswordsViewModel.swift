import RxCocoa
import RxSwift

protocol PasswordsViewModel: AnyObject {
    var didLoadTrigger: AnyObserver<Void> { get }
    var willAppearTrigger: AnyObserver<Void> { get }
    var settingsTrigger: AnyObserver<Void> { get }
    var newPasswordTrigger: AnyObserver<Void> { get }
    var searchQuery: AnyObserver<String?> { get }
    var editTrigger: AnyObserver<IndexPath> { get }
    var deleteTrigger: AnyObserver<IndexPath> { get }

    var credentials: Driver<[Credentials]> { get }

    func credentialsViewModel(_ credentials: Credentials) -> CredentialsContentViewModel
}

final class PasswordsViewModelImpl: PasswordsViewModel {
    private let router: PasswordsRouter
    private let credentialsRepository: CredentialsRepository

    private let didLoadSubject = PublishSubject<Void>()
    private(set) lazy var didLoadTrigger: AnyObserver<Void> = {
        return didLoadSubject.asObserver()
    }()

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
            .bind(to: credentialsRepository.refreshTrigger)
            .disposed(by: disposeBag)
        return refreshSubject.asObserver()
    }()

    private let credentialsSubject = BehaviorSubject<[Credentials]>(value: [])
    private(set) lazy var credentials: Driver<[Credentials]> = {
        Observable.combineLatest(credentialsRepository.credentials, searchQuerySubject)
            .map { credentials, searchQuery in
                guard let searchQuery = searchQuery, !searchQuery.isEmpty else { return credentials }
                return credentials.filter {
                    $0.email.localizedCaseInsensitiveContains(searchQuery)
                    || $0.name.localizedCaseInsensitiveContains(searchQuery)
                    || $0.service.serviceName.localizedCaseInsensitiveContains(searchQuery)
                }
            }
            .bind(to: credentialsSubject)
            .disposed(by: disposeBag)
        return credentialsSubject.asDriver(onErrorJustReturn: [])
    }()

    private let newPasswordSubject = PublishSubject<Void>()
    private(set) lazy var newPasswordTrigger: AnyObserver<Void> = {
        newPasswordSubject
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.router.showServiceDetailsScreen(
                    with: .password("New password", "Continue"),
                    serviceDetailsModel: ServiceDetailsModel.empty
                )
            })
            .disposed(by: disposeBag)

        return newPasswordSubject.asObserver()
    }()

    private let searchQuerySubject = PublishSubject<String?>()
    private(set) lazy var searchQuery: AnyObserver<String?> = {
        return searchQuerySubject.asObserver()
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
            .withLatestFrom(credentials) { ($0.1, $1) }
            .compactMap { indexPath, credentials -> Credentials? in
                guard credentials.indices.contains(indexPath.row) else { return nil }
                return credentials[indexPath.row]
            }
            .subscribe(onNext: { [weak self] credentials in
                self?.credentialsRepository.delete(credentials: credentials)
            })
            .disposed(by: disposeBag)
        return deleteSubject.asObserver()
    }()

    private let editSubject = PublishSubject<IndexPath>()
    private(set) lazy var editTrigger: AnyObserver<IndexPath> = {
        editSubject
            .withLatestFrom(credentials) { ($0, $1) }
            .compactMap { indexPath, credentials -> Credentials? in
                guard credentials.indices.contains(indexPath.row) else { return nil }
                return credentials[indexPath.row]
            }
            .subscribe(onNext: { [weak self] credentials in
                let serviceDetailsModel = ServiceDetailsModel(
                    uid: credentials.uid,
                    serviceName: credentials.name,
                    key: credentials.password,
                    login: credentials.email,
                    service: credentials.service
                )
                self?.router.showServiceDetailsScreen(with: .password("Edit Data", "Save changes"), serviceDetailsModel: serviceDetailsModel)
            })
            .disposed(by: disposeBag)
        return editSubject.asObserver()
    }()

    private let disposeBag = DisposeBag()

    init(router: PasswordsRouter, credentialsRepository: CredentialsRepository) {
        self.router = router
        self.credentialsRepository = credentialsRepository
    }

    func credentialsViewModel(_ credentials: Credentials) -> any CredentialsContentViewModel {
        return CredentialsContentViewModelImpl(
            router: router,
            credentials: credentials
        )
    }

}
