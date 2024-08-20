import RxCocoa
import RxSwift
import UIKit

final class DashboardView: UITabBarController {
    var viewModel: DashboardViewModel!

    private let customTabBar = CustomTabBar()

    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        rx.methodInvoked(#selector(UIViewController.viewWillAppear(_:)))
            .map { _ in () }
            .take(1)
            .subscribe(onNext: { [weak self] _ in
                // Deferring viewDidLoad due to UITabBarController init behaviour
                // Note: viewDidLoad called immediately after init(:) so
                // viewModel is not setup yet.
                self?.deferredViewDidLoad()
            })
            .disposed(by: disposeBag)
    }

    private func deferredViewDidLoad() {
        setupUI()
        bindViewModel()

        viewModel.didLoadTrigger.onNext(())
    }

    private func setupUI() {
        setValue(customTabBar, forKey: "tabBar")
        addPreferences()
    }

    private func bindViewModel() {
        customTabBar.rx.createTrigger
            .bind(to: viewModel.createTrigger)
            .disposed(by: disposeBag)
    }

    private func addPreferences() {
        tabBar.unselectedItemTintColor = .black.withAlphaComponent(0.3)
    }
}
