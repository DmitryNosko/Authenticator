import RxSwift

protocol CredentialsRepository {
    var refreshTrigger: AnyObserver<Void> { get }
    var credentials: Observable<[Credentials]> { get }

    func store(credentials: Credentials)
    func delete(credentials: Credentials)
}

final class CredentialsRepositoryImpl: CredentialsRepository {
    private let storage: CredentialsStorage
    private let servicesRepository: ServicesRepository

    private let refreshSubject = PublishSubject<Void>()
    private(set) lazy var refreshTrigger: AnyObserver<Void> = {
        refreshSubject
            .compactMap { [weak self] in
                return self?.storage.fetchAll()
            }
            .map { [weak self] credentialsData -> [Credentials] in
                guard let self = self else { return [] }
                return credentialsData.compactMap { [weak servicesRepository] data -> Credentials? in
                    guard let serviceName = data.serviceName else { return nil }
                    return data.toDomain(service: servicesRepository?.service(name: serviceName) ?? .default)
                }
            }
            .bind(to: credentialsSubject)
            .disposed(by: disposeBag)
        return refreshSubject.asObserver()
    }()

    private let credentialsSubject = BehaviorSubject<[Credentials]>(value: [])
    private(set) lazy var credentials: Observable<[Credentials]> = {
        return credentialsSubject.asObservable()
    }()

    private let disposeBag = DisposeBag()

    init(
        credentialsStorage: CredentialsStorage,
        servicesRepository: ServicesRepository
    ) {
        self.storage = credentialsStorage
        self.servicesRepository = servicesRepository
    }

    func store(credentials: Credentials) {
        storage.store(credentials: .from(credentials: credentials))
        refreshTrigger.onNext(())
    }

    func delete(credentials: Credentials) {
        storage.delete(credentialsUid: credentials.uid)
        refreshTrigger.onNext(())
    }
}
