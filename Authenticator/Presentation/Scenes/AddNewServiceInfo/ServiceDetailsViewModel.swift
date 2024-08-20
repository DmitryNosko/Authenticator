import RxCocoa
import RxSwift

struct ServiceDetailsModel {
    let uid: String?
    let serviceName: String?
    let key: String
    let login: String?
    let service: Service?

    static let empty = ServiceDetailsModel(
        uid: nil,
        serviceName: nil,
        key: "",
        login: nil,
        service: nil
    )
}

protocol ServiceDetailsViewModel: AnyObject {
    var didLoadTrigger: AnyObserver<Void> { get }
    var closeTrigger: AnyObserver<Void> { get }
    var selectIconTrigger: AnyObserver<Void> { get }
    var continueTrigger: AnyObserver<Void> { get }
    var serviceNameInputText: AnyObserver<String?> { get }
    var loginInputText: AnyObserver<String?> { get }
    var keyInputText: AnyObserver<String?> { get }
    var serviceType: ServiceType { get }
    var serviceDetailsModel: ServiceDetailsModel { get }
    var selectedService: Driver<Service?> { get }
    var isContinueButtonEnabled: Driver<Bool> { get }
}

final class ServiceDetailsViewModelImpl: ServiceDetailsViewModel {
    let serviceType: ServiceType
    let serviceDetailsModel: ServiceDetailsModel
    private let router: ServiceDetailsRouter
    private let authenticatorsRepository: AuthenticatorsRepository
    private let credentialsRepository: CredentialsRepository

    private let didLoadSubject = PublishSubject<Void>()
    private(set) lazy var didLoadTrigger: AnyObserver<Void> = {
        didLoadSubject
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: {
                self.serviceNameInputTextSubject.onNext(self.serviceDetailsModel.serviceName)
                self.keyInputTextSubject.onNext(self.serviceDetailsModel.key)
                self.loginInputTextSubject.onNext(self.serviceDetailsModel.login)
                self.selectedServiceSubject.onNext(self.serviceDetailsModel.service)
                self.uidSubject.onNext(self.serviceDetailsModel.uid)
            })
            .disposed(by: disposeBag)

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

    private let selectIconSubject = PublishSubject<Void>()
    private(set) lazy var selectIconTrigger: AnyObserver<Void> = {
        selectIconSubject
            .observe(on: MainScheduler.instance)
            .flatMap{ [weak self] _ in
                self?.router.showSelectIcon() ?? .never()
            }
            .subscribe(onNext: { [weak self] result in
                switch result {
                case .finished(let service):
                    self?.selectedServiceSubject.onNext(service)
                case .cancelled:
                    print("cancellled")
                }
            })
            .disposed(by: disposeBag)

        return selectIconSubject.asObserver()
    }()

    private var selectedServiceSubject = BehaviorSubject<Service?>(value: nil)
    private(set) lazy var selectedService: Driver<Service?> = {
        return selectedServiceSubject
            .asDriver(onErrorJustReturn: nil)
    }()

    private(set) lazy var serviceData: Observable<(String?, String?, String?, String?, Service?)> = {
        return Observable.combineLatest(
            self.uidSubject,
            self.serviceNameInputTextSubject,
            self.loginInputTextSubject,
            self.keyInputTextSubject,
            self.selectedServiceSubject
        )
    }()

    private let continueSubject = PublishSubject<Void>()
    private(set) lazy var continueTrigger: AnyObserver<Void> = {
        continueSubject
            .observe(on: MainScheduler.instance)
            .withLatestFrom(serviceData)
            .subscribe(onNext: { [weak self] uid, serviceName, login, key, service in
                guard let self, let serviceName, let login, let key, let service else { return }

                switch self.serviceType {
                case .authenticator:
                    if let uid {
                        self.authenticatorsRepository.store(
                            authenticator: Authenticator(
                                uid: uid,
                                name: serviceName,
                                email: login,
                                secret: key,
                                service: service
                            )
                        )
                    } else {
                        self.authenticatorsRepository.store(
                            authenticator: Authenticator(
                                name: serviceName,
                                email: login,
                                secret: key,
                                service: service
                            )
                        )
                    }
                case .password:
                    if let uid {
                        self.credentialsRepository.store(
                            credentials: Credentials(
                                uid: uid,
                                name: serviceName,
                                email: login,
                                password: key,
                                service: service
                            )
                        )
                    } else {
                        self.credentialsRepository.store(
                            credentials: Credentials(
                                name: serviceName,
                                email: login,
                                password: key,
                                service: service
                            )
                        )
                    }
                }
                self.router.dissmis()
            })
            .disposed(by: disposeBag)
        return continueSubject.asObserver()
    }()

    private(set) lazy var isContinueButtonEnabled: Driver<Bool> = {
        return serviceData
            .map { _, serviceName, login, key, selectedService in
                guard let serviceName, let login, let key, let selectedService else { return false }
                return !serviceName.isEmpty && !login.isEmpty && !key.isEmpty
            }
            .asDriver(onErrorJustReturn: false)
    }()

    private let serviceNameInputTextSubject = BehaviorSubject<String?>(value: nil)
    private(set) lazy var serviceNameInputText: AnyObserver<String?> = {
        return serviceNameInputTextSubject.asObserver()
    }()

    private let loginInputTextSubject = BehaviorSubject<String?>(value: nil)
    private(set) lazy var loginInputText: AnyObserver<String?> = {
        return loginInputTextSubject.asObserver()
    }()

    private let keyInputTextSubject = BehaviorSubject<String?>(value: nil)
    private(set) lazy var keyInputText: AnyObserver<String?> = {
        return keyInputTextSubject.asObserver()
    }()

    private let uidSubject = BehaviorSubject<String?>(value: nil)

    private let disposeBag = DisposeBag()

    init(
        router: ServiceDetailsRouter,
        serviceType: ServiceType,
        authenticatorsRepository: AuthenticatorsRepository,
        credentialsRepository: CredentialsRepository,
        serviceDetailsModel: ServiceDetailsModel
    ) {
        self.router = router
        self.serviceType = serviceType
        self.serviceDetailsModel = serviceDetailsModel
        self.authenticatorsRepository = authenticatorsRepository
        self.credentialsRepository = credentialsRepository
    }
}
