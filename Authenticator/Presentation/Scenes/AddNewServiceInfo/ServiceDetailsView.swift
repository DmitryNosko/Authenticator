import UIKit
import RxSwift
import RxCocoa
import RxGesture

final class ServiceDetailsView: UIViewController {
    var viewModel: ServiceDetailsViewModel!

    private let disposeBag = DisposeBag()

    private let continueButton = UIButton(frame: .zero)
    private let closeButton = UIButton(frame: .zero)
    private let titleLabel = UILabel()

    private let serviceNameInputView = ServiceDetailsInputView()
    private let loginInputView = ServiceDetailsInputView()
    private let keyInputView = ServiceDetailsInputView()

    private let selectIconView = ServiceDetailsSelectIconView()

    override func loadView() {
        view = UIView()

        view.addSubview(titleLabel)
        view.addSubview(closeButton)
        view.addSubview(continueButton)
        view.addSubview(serviceNameInputView)
        view.addSubview(loginInputView)
        view.addSubview(keyInputView)
        view.addSubview(selectIconView)

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(23)
            $0.centerX.equalToSuperview()
            $0.height.equalToScaledValue(24)
        }

        serviceNameInputView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(33)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        loginInputView.snp.makeConstraints {
            $0.top.equalTo(serviceNameInputView.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        keyInputView.snp.makeConstraints {
            $0.top.equalTo(loginInputView.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        closeButton.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel.snp.centerY)
            $0.trailing.equalToSuperview().scaledOffset(-16)
            $0.size.equalToScaledValue(30)
        }

        selectIconView.snp.makeConstraints {
            $0.top.equalTo(keyInputView.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        continueButton.snp.makeConstraints {
            $0.leading.equalToSuperview().scaledOffset(20)
            $0.trailing.equalToSuperview().scaledOffset(-20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalToScaledValue(72)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        rx.methodInvoked(#selector(UIViewController.viewWillAppear(_:)))
            .map { _ in () }
            .take(1)
            .subscribe(onNext: { [weak self] _ in
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
        view.backgroundColor = .concrete

        with(titleLabel) {
            $0.font = .outfit(ofSize: 20, weight: .medium)
            $0.textColor = .black
        }

        with(closeButton) {
            $0.setImage(UIImage(systemName: "xmark")?.withTintColor(.black, renderingMode: .alwaysOriginal), for: .normal)
        }

        with(continueButton) {
            $0.clipsToBounds = true
            $0.layer.cornerRadius = 28.scaled()
            $0.titleLabel?.font = .outfit(ofSize: 20, weight: .medium)
            $0.alpha = 0.5
            $0.isEnabled = false
        }
    }

    private func bindViewModel() {
        closeButton.rx.tap
            .bind(to: viewModel.closeTrigger)
            .disposed(by: disposeBag)
        selectIconView.rx
            .tapGesture()
            .when(.recognized)
            .map { _ in ()}
            .bind(to: viewModel.selectIconTrigger)
            .disposed(by: disposeBag)
        continueButton.rx.tap
            .bind(to: viewModel.continueTrigger)
            .disposed(by: disposeBag)
        serviceNameInputView.rx.inputText
            .bind(to: viewModel.serviceNameInputText)
            .disposed(by: disposeBag)
        loginInputView.rx.inputText
            .bind(to: viewModel.loginInputText)
            .disposed(by: disposeBag)
        keyInputView.rx.inputText
            .bind(to: viewModel.keyInputText)
            .disposed(by: disposeBag)

        switch viewModel.serviceType {
        case .authenticator(let title, let buttonTitle):
            setup(title: title,
                  buttonTitle: buttonTitle,
                  serviceNameInputViewPlaceholder: "Service name (ex: Microsoft)",
                  loginInputViewPlaceholder: "Your login (ex: User@mail.com)",
                  keyInputViewPlaceholder: "Secret key (ex: RT345YFG...)"
            )
        case .password(let title, let buttonTitle):
            setup(title: title,
                  buttonTitle: buttonTitle,
                  serviceNameInputViewPlaceholder: "Service name (ex: Microsoft)",
                  loginInputViewPlaceholder: "Your login",
                  keyInputViewPlaceholder: "Enter your password"
            )
        }

        setup(viewModel.serviceDetailsModel)

        viewModel.selectedService
            .drive { [weak self] service in
                guard let service else { return } 
                self?.selectIconView.setup(serviceName: service.serviceName, serviceIconName: service.iconName)
            }
            .disposed(by: disposeBag)
        viewModel.isContinueButtonEnabled
            .drive { [weak self] isEnabled in
                self?.continueButton.isEnabled = isEnabled
                self?.continueButton.alpha = isEnabled ? 1 : 0.5
            }
            .disposed(by: disposeBag)

    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        continueButton.applyGradient(with: [UIColor.hex("#003DB5"), UIColor.hex("#4D89FF")], gradient: .horizontal)
    }
}

private extension ServiceDetailsView {
    func setup(title: String,
               buttonTitle: String,
               serviceNameInputViewPlaceholder: String,
               loginInputViewPlaceholder: String,
               keyInputViewPlaceholder: String) {
        titleLabel.text = title
        continueButton.setTitle(buttonTitle, for: .normal)
        serviceNameInputView.setup(placeholder: serviceNameInputViewPlaceholder)
        loginInputView.setup(placeholder: loginInputViewPlaceholder)
        keyInputView.setup(placeholder: keyInputViewPlaceholder)
    }

    func setup(_ model: ServiceDetailsModel) {
        serviceNameInputView.setup(model.serviceName)
        loginInputView.setup(model.login)
        keyInputView.setup(model.key)
    }
}

