import RxCocoa
import RxSwift

protocol SettingsViewModel: AnyObject {
    var didLoadTrigger: AnyObserver<Void> { get }
    var refreshTrigger: AnyObserver<Void> { get }
    var closeTrigger: AnyObserver<Void> { get }
    var selectTrigger: AnyObserver<IndexPath> { get }
    var biometricTrigger: AnyObserver<Bool> { get }
    
    var isBiometricEnabled: Driver<Bool> { get }
    var biometricType: Driver<BiometricType> { get }
    var settings: Driver<[SettingsModel]> { get }
}

final class SettingsViewModelImpl: SettingsViewModel {
    private let router: SettingsRouter
    private let userDefaultsStore: UserDefaultsStore
    private let biometricService: BiometricService
    
    private enum Constants {        
        enum Email {
            static let owner = "pregvanngl@gmail.com"
            static let subject = "Your topic"
            static let body = "Write your question, please."
        }
    }

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
            .compactMap { [weak self] in self?.biometricService.getBiometricType() }
            .bind(to: biometricTypeSubject)
            .disposed(by: disposeBag)
        
        refreshSubject
            .compactMap { [weak self] in self?.biometricService.isBiometricEnabled() }
            .bind(to: isBiometricEnabledSubject)
            .disposed(by: disposeBag)
        
        refreshSubject
            .compactMap { [weak self] in
                self?.userDefaultsStore.hasSubscription
            }
            .compactMap { [weak self] hasSubscription in
                var settingModels = self?.defaultItems()
                if !hasSubscription {
                    let goPremiumItem = SettingsModel(image: UIImage(named: "goPremium"), title: "Go premium", itemType: .subscriptions)
                    settingModels?.insert(goPremiumItem, at: 0)
                }
                return settingModels
            }
            .bind(to: settingsSubject)
            .disposed(by: disposeBag)
        return refreshSubject.asObserver()
    }()
    
    private let biometricTypeSubject = BehaviorSubject<BiometricType>(value: .TouchID)
    private(set) lazy var biometricType: Driver<BiometricType> = {
        return biometricTypeSubject.asDriver(onErrorJustReturn: .TouchID)
    }()
    
    private let isBiometricEnabledSubject = BehaviorSubject<Bool>(value: false)
    private(set) lazy var isBiometricEnabled: Driver<Bool> = {
        return isBiometricEnabledSubject.asDriver(onErrorJustReturn: false)
    }()
    
    private let settingsSubject = BehaviorSubject<[SettingsModel]>(value: [])
    private(set) lazy var settings: Driver<[SettingsModel]> = {
        return settingsSubject.asDriver(onErrorJustReturn: [])
    }()

    private let closeSubject = PublishSubject<Void>()
    private(set) lazy var closeTrigger: AnyObserver<Void> = {
        closeSubject
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.router.dismiss()
            })
            .disposed(by: disposeBag)
        return closeSubject.asObserver()
    }()

    private let selectSubject = PublishSubject<IndexPath>()
    private(set) lazy var selectTrigger: AnyObserver<IndexPath> = {
        selectSubject
            .withLatestFrom(settings) { ($0, $1) }
            .compactMap { indexPath, items -> SettingsModel? in
                guard items.indices.contains(indexPath.row) else {
                    return nil
                }
                return items[indexPath.row]
            }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] item in
                switch item.itemType {
                case .subscriptions:
                    self?.router.showPremium()
                case .support:
                    let ownerEmail = Constants.Email.owner
                    let subject = Constants.Email.subject
                    let body = Constants.Email.body
                    let emailUrl = self?.createEmailUrl(to: ownerEmail, subject: subject, body: body)
                    self?.router.showContactUsScreen(applicationSupportEmail: ownerEmail, subject: subject, body: body, emailURL: emailUrl)
                case .privacyPolicy:
                    self?.router.showSafari(with: AppConstants.Links.privacyAndPolicy)
                case .termsOfUse:
                    self?.router.showSafari(with: AppConstants.Links.termsOfUse)
                case .rateThisApp:
                    self?.router.showReviewView()
                case .share:
                    self?.router.showShareWithFriends(applicationLink: AppConstants.Links.application)
                }
            })
            .disposed(by: disposeBag)
        return selectSubject.asObserver()
    }()
    
    private let biometricSubject = PublishSubject<Bool>()
    private(set) lazy var biometricTrigger: AnyObserver<Bool> = {
        biometricSubject
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isOn in
                if isOn {
                    self?.router.showBiometricsSettingsAlert()
                }
                self?.biometricService.setBiometricEnabled(isOn)
            })
            .disposed(by: disposeBag)
        return biometricSubject.asObserver()
    }()

    private let disposeBag = DisposeBag()

    init(
        router: SettingsRouter,
        userDefaultsStore: UserDefaultsStore,
        biometricService: BiometricService
    ) {
        self.router = router
        self.userDefaultsStore = userDefaultsStore
        self.biometricService = biometricService
    }
}

private extension SettingsViewModelImpl {
    
    func defaultItems() -> [SettingsModel] {
        [SettingsModel(image: UIImage(named: "goPremium"), title: "Support", itemType: .support),
         SettingsModel(image: UIImage(named: "privacyPolicy"), title: "Privacy & Policy", itemType: .privacyPolicy),
         SettingsModel(image: UIImage(named: "termsOfUse"), title: "Terms of Use", itemType: .termsOfUse),
         SettingsModel(image: UIImage(named: "rateApp"), title: "Rate this APP", itemType: .rateThisApp),
         SettingsModel(image: UIImage(named: "share"), title: "Share", itemType: .share)]
    }
    
    func createEmailUrl(to: String, subject: String, body: String) -> URL? {
        let subjectEncoded = subject.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let bodyEncoded = body.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!

        let gmailUrl = URL(string: "googlegmail://co?to=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
        let outlookUrl = URL(string: "ms-outlook://compose?to=\(to)&subject=\(subjectEncoded)")
        let yahooMail = URL(string: "ymail://mail/compose?to=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
        let sparkUrl = URL(string: "readdle-spark://compose?recipient=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
        let defaultUrl = URL(string: "mailto:\(to)?subject=\(subjectEncoded)&body=\(bodyEncoded)")

        if let gmailUrl = gmailUrl, UIApplication.shared.canOpenURL(gmailUrl) {
            return gmailUrl
        } else if let outlookUrl = outlookUrl, UIApplication.shared.canOpenURL(outlookUrl) {
            return outlookUrl
        } else if let yahooMail = yahooMail, UIApplication.shared.canOpenURL(yahooMail) {
            return yahooMail
        } else if let sparkUrl = sparkUrl, UIApplication.shared.canOpenURL(sparkUrl) {
            return sparkUrl
        }

        return defaultUrl
    }
}
