import RxSwift

protocol AuthenticatorsRepository {
    var refreshTrigger: AnyObserver<Void> { get }
    var authenticators: Observable<[Authenticator]> { get }

    func store(authenticator: Authenticator)
    func delete(authenticator: Authenticator)
}

final class AuthenticatorsRepositoryImpl: AuthenticatorsRepository {
    private let storage: AuthenticatorStorage
    private let servicesRepository: ServicesRepository

    private let refreshSubject = PublishSubject<Void>()
    private(set) lazy var refreshTrigger: AnyObserver<Void> = {
        refreshSubject
            .compactMap { [weak self] in
                return self?.storage.fetchAll()
            }
            .map { [weak self] authenticatorsData -> [Authenticator] in
                guard let self = self else { return [] }
                return authenticatorsData.compactMap { [weak servicesRepository] data -> Authenticator? in
                    guard let serviceName = data.serviceName else { return nil }
                    return data.toDomain(service: servicesRepository?.service(name: serviceName) ?? .default)
                }
            }
            .bind(to: authenticatorsSubject)
            .disposed(by: disposeBag)
        return refreshSubject.asObserver()
    }()

    private let authenticatorsSubject = BehaviorSubject<[Authenticator]>(value: [])
    private(set) lazy var authenticators: Observable<[Authenticator]> = {
        return authenticatorsSubject.asObservable()
    }()

    private let disposeBag = DisposeBag()

    init(
        authenticatorStorage: AuthenticatorStorage,
        servicesRepository: ServicesRepository
    ) {
        self.storage = authenticatorStorage
        self.servicesRepository = servicesRepository
    }

    func store(authenticator: Authenticator) {
        storage.store(authenticator: .from(authenticator: authenticator))
        refreshTrigger.onNext(())
    }

    func delete(authenticator: Authenticator) {
        storage.delete(authenticatorUid: authenticator.uid)
        refreshTrigger.onNext(())
    }
}
