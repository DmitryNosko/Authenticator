import RxCocoa
import RxSwift

protocol OnboardingViewModel: AnyObject {
    var didLoadTrigger: AnyObserver<Void> { get }
    var refreshTrigger: AnyObserver<Void> { get }
    var closeTrigger: AnyObserver<Void> { get }
    var restoreTrigger: AnyObserver<Void> { get }
    var continueTrigger: AnyObserver<IndexPath> { get }
    var termsOfServiceTrigger: AnyObserver<Void> { get }
    var privacyPolicyTrigger: AnyObserver<Void> { get }

    var steps: Driver<[OnboardingStep]> { get }
    var currentPage: Driver<Int> { get }
}

final class OnboardingViewModelImpl: OnboardingViewModel {
    private let router: OnboardingRouter
    private var userDefaultsStore: UserDefaultsStore

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
            .compactMap { [weak self] _ in
                return self?.onboardingItems()
            }
            .bind(to: stepsSubject)
            .disposed(by: disposeBag)
        return refreshSubject.asObserver()
    }()
    
    private let stepsSubject = BehaviorSubject<[OnboardingStep]>(value: [])
    private(set) lazy var steps: Driver<[OnboardingStep]> = {
        return stepsSubject.asDriver(onErrorJustReturn: [])
    }()

    private let currentPageSubject = BehaviorSubject<Int>(value: 0)
    private(set) lazy var currentPage: Driver<Int> = {
        return currentPageSubject.asDriver(onErrorJustReturn: 0)
    }()

    private let closeSubject = PublishSubject<Void>()
    private(set) lazy var closeTrigger: AnyObserver<Void> = {
        closeSubject
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.router.showMainScreen()
                self?.userDefaultsStore.isOnboardingFinished = true
            })
            .disposed(by: disposeBag)
        return closeSubject.asObserver()
    }()

    private let restoreSubject = PublishSubject<Void>()
    private(set) lazy var restoreTrigger: AnyObserver<Void> = {
        restoreSubject
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                print("restore")
            })
            .disposed(by: disposeBag)
        return restoreSubject.asObserver()
    }()

    private let continueSubject = PublishSubject<IndexPath>()
    private(set) lazy var continueTrigger: AnyObserver<IndexPath> = {
        continueSubject
            .observe(on: MainScheduler.instance)
            .withLatestFrom(steps) { ($0, $1) }
            .subscribe(onNext: { [weak self] (indexPath, steps) in
                if steps.indices.contains(indexPath.row + 1) {
                    self?.currentPageSubject.onNext(indexPath.row + 1)
                } else {
                    self?.router.showMainScreen()
                    self?.userDefaultsStore.isOnboardingFinished = true
                }
            })
            .disposed(by: disposeBag)
        return continueSubject.asObserver()
    }()

    private let termsOfServiceSubject = PublishSubject<Void>()
    private(set) lazy var termsOfServiceTrigger: AnyObserver<Void> = {
        termsOfServiceSubject
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.router.showSafari(with: AppConstants.Links.termsOfUse)
            })
            .disposed(by: disposeBag)
        return termsOfServiceSubject.asObserver()
    }()

    private let privacyPolicySubject = PublishSubject<Void>()
    private(set) lazy var privacyPolicyTrigger: AnyObserver<Void> = {
        privacyPolicySubject
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.router.showSafari(with: AppConstants.Links.privacyAndPolicy)
            })
            .disposed(by: disposeBag)
        return privacyPolicySubject.asObserver()
    }()

    private let disposeBag = DisposeBag()

    init(
        router: OnboardingRouter,
        userDefaultsStore: UserDefaultsStore
    ) {
        self.router = router
        self.userDefaultsStore = userDefaultsStore
    }
}

private extension OnboardingViewModelImpl {
    
    func onboardingItems() -> [OnboardingStep] {
        [OnboardingStep(
            backgroundImage: "onboardingFirst",
            title: "2FA Autheticator for your safety!",
            description: "Protect your accounts from data leaks and verify with one code at a time!",
            buttonTitle: "Continue"
        ),
         OnboardingStep(
            backgroundImage: "onboardingSecond",
            title: "Protect your code for digital safety",
            description: "Easily find any passwords you need as they are collected in one safe place",
            buttonTitle: "Continue"
         ),
         OnboardingStep(
            backgroundImage: "onboardingThird",
            title: "Access quikly with your camera",
            description: "Automatic account setup via QR code: easy to ensure your setup is accurate",
            buttonTitle: "Continue"
         ),
         OnboardingStep(
            backgroundImage: "onboardingFourth",
            title: "Accounts secured without limitations",
            description: "Easily protect all your online accounts, manage passwords for $5.99 per week",
            buttonTitle: "Continue",
            stepType: .restore
         )]
    }
}
