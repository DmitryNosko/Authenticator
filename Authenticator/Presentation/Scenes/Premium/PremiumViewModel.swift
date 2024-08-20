import RxCocoa
import RxSwift

protocol PremiumViewModel: AnyObject {
    var didLoadTrigger: AnyObserver<Void> { get }
    var refreshTrigger: AnyObserver<Void> { get }
    var backTrigger: AnyObserver<Void> { get }
    var selectTrigger: AnyObserver<IndexPath> { get }
    
    var subscriptions: Driver<[SubscriptionModel]> { get }
}

final class PremiumViewModelImpl: PremiumViewModel {
    private let router: PremiumRouter

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
            .compactMap { [weak self] in
                [SubscriptionModel(image: UIImage(named: "premium"), title: "Trial 3-day/total $0", itemType: .trial),
                 SubscriptionModel(image: UIImage(named: "premium"), title: "Weekly/Total $5,99", itemType: .weekly),
                 SubscriptionModel(image: UIImage(named: "premium"), title: "Monthly/Total $19,99", itemType: .monthly),
                 SubscriptionModel(image: UIImage(named: "premium"), title: "Yearly/Total $39,99", itemType: .yearly)]
            }
            .bind(to: subscriptionsSubject)
            .disposed(by: disposeBag)
        return refreshSubject.asObserver()
    }()
    
    private let subscriptionsSubject = BehaviorSubject<[SubscriptionModel]>(value: [])
    private(set) lazy var subscriptions: Driver<[SubscriptionModel]> = {
        return subscriptionsSubject.asDriver(onErrorJustReturn: [])
    }()

    private let backSubject = PublishSubject<Void>()
    private(set) lazy var backTrigger: AnyObserver<Void> = {
        backSubject
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.router.dismiss()
            })
            .disposed(by: disposeBag)
        return backSubject.asObserver()
    }()

    private let selectSubject = PublishSubject<IndexPath>()
    private(set) lazy var selectTrigger: AnyObserver<IndexPath> = {
        selectSubject
            .withLatestFrom(subscriptions) { ($0, $1) }
            .compactMap { indexPath, items -> SubscriptionModel? in
                guard items.indices.contains(indexPath.row) else {
                    return nil
                }
                return items[indexPath.row]
            }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] item in
                switch item.itemType {
                case .trial:
                    print("trial")
                case .weekly:
                    print("weekly")
                case .monthly:
                    print("monthly")
                case .yearly:
                    print("yearly")
                }
            })
            .disposed(by: disposeBag)
        return selectSubject.asObserver()
    }()

    private let disposeBag = DisposeBag()

    init(router: PremiumRouter) {
        self.router = router
    }
}
