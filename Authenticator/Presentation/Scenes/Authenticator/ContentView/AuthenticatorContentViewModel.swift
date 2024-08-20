import RxSwift
import RxCocoa

protocol AuthenticatorContentViewModel: AccordionViewModel {
    var selectTrigger: AnyObserver<Bool> { get }
    var copyTrigger: AnyObserver<Void> { get }

    var authenticator: Authenticator { get }
    var state: Driver<AuthenticatorContentViewState> { get }
    var code: Driver<String?> { get }
    var timer: Driver<Int> { get }
}

enum AuthenticatorContentViewState {
    case idle
    case failed
}

final class AuthenticatorContentViewModelImpl: AuthenticatorContentViewModel {
    private let router: AuthenticatorContentRouter
    private let authenticatorService: AuthenticatorService
    let authenticator: Authenticator
    private let validCodeDuration: Int

    private let selectSubject = PublishSubject<Bool>()
    private(set) lazy var selectTrigger: AnyObserver<Bool> = {
        selectSubject
            .subscribe(onNext: { [weak self] isSelected in
                if isSelected {
                    self?.bindAuthenticator()
                } else {
                    self?.invalidateAuthenticator()
                }
            })
            .disposed(by: disposeBag)
        return selectSubject.asObserver()
    }()

    private let copySubject = PublishSubject<Void>()
    private(set) lazy var copyTrigger: AnyObserver<Void> = {
        copySubject
            .withLatestFrom(codeSubject)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] code in
                guard let code = code else { return }
                UIPasteboard.general.string = code
                self?.router.showAlert(title: "Code Copied", message: nil)
            })
            .disposed(by: disposeBag)
        return copySubject.asObserver()
    }()

    private let stateSubject = BehaviorSubject<AuthenticatorContentViewState>(value: .idle)
    private(set) lazy var state: Driver<AuthenticatorContentViewState> = {
        return stateSubject.asDriver(onErrorJustReturn: .failed)
    }()

    private let codeSubject = PublishSubject<String?>()
    private(set) lazy var code: Driver<String?> = codeSubject.asDriver(onErrorJustReturn: nil)

    private let timerSubject = PublishSubject<Int>()
    private(set) lazy var timer: Driver<Int> = timerSubject.asDriver(onErrorJustReturn: validCodeDuration)

    private let disposeBag = DisposeBag()
    private var codeBag = DisposeBag()

    init(
        router: AuthenticatorContentRouter,
        authenticatorService: AuthenticatorService,
        authenticator: Authenticator,
        validCodeDuration: Int = 30
    ) {
        self.router = router
        self.authenticatorService = authenticatorService
        self.authenticator = authenticator
        self.validCodeDuration = validCodeDuration
    }

    private func invalidateAuthenticator() {
        codeBag = DisposeBag()
    }

    private func bindAuthenticator() {
        invalidateAuthenticator()
        authenticatorService.oneTimePassword(authenticator: authenticator, timeInterval: validCodeDuration)
            .subscribe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] result in
                switch result {
                case .success(let oneTimePassword):
                    self?.stateSubject.onNext(.idle)
                    self?.codeSubject.onNext(oneTimePassword.code)
                    self?.timerSubject.onNext(oneTimePassword.expirationInSeconds)
                case .failure(let authenticatorError):
#if DEBUG
                    print("⚠️ AuthenticatorServiceError: \(authenticatorError)")
#endif
                    self?.stateSubject.onNext(.failed)
                }
            })
            .disposed(by: codeBag)
    }
}
