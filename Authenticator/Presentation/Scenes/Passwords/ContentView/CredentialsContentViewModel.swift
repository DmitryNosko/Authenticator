import RxSwift
import RxCocoa

protocol CredentialsContentViewModel: AccordionViewModel {
    var selectTrigger: AnyObserver<Bool> { get }

    var credentials: Credentials { get }
}

enum CredentialsContentViewState {
    case idle
    case failed
}

final class CredentialsContentViewModelImpl: CredentialsContentViewModel {
    private let router: PasswordsRouter
    let credentials: Credentials

    private let selectSubject = PublishSubject<Bool>()
    private(set) lazy var selectTrigger: AnyObserver<Bool> = {
        selectSubject
            .subscribe()
            .disposed(by: disposeBag)
        return selectSubject.asObserver()
    }()

    private let disposeBag = DisposeBag()
    private var codeBag = DisposeBag()

    init(
        router: PasswordsRouter,
        credentials: Credentials
    ) {
        self.router = router
        self.credentials = credentials
    }
}
