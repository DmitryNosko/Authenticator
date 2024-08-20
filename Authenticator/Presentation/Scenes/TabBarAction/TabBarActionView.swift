import UIKit
import RxCocoa
import RxSwift

final class TabBarActionView: UIViewController {
    var viewModel: TabBarActionViewModel!

    private let disposeBag = DisposeBag()

    private let colors = [UIColor.hex("#003DB5"), UIColor.hex("#4D89FF")]

    private let closeButton = CircleButton(image: UIImage(systemName: "xmark")?.withTintColor(.white, renderingMode: .alwaysOriginal))
    private let scanQrButton = TabBarActionButton(title: "Scan QR-code", imageName: "icon_scan_qr_code")
    private let enterManualyButton = TabBarActionButton(title: "Enter manualy", imageName: "icon_enter_manualy")
    private let addPasswordButton = TabBarActionButton(title: "Add password", imageName: "icon_add_password")

    override func loadView() {
        view = UIView()

        view.addSubview(closeButton)
        view.addSubview(addPasswordButton)
        view.addSubview(enterManualyButton)
        view.addSubview(scanQrButton)

        addPasswordButton.snp.makeConstraints {
            $0.bottom.equalTo(closeButton.snp.top).scaledOffset(-30)
            $0.leading.equalToSuperview().scaledOffset(16)
            $0.trailing.equalToSuperview().scaledOffset(-16)
        }

        enterManualyButton.snp.makeConstraints {
            $0.bottom.equalTo(addPasswordButton.snp.top).scaledOffset(-12)
            $0.leading.equalToSuperview().scaledOffset(16)
            $0.trailing.equalToSuperview().scaledOffset(-16)
        }

        scanQrButton.snp.makeConstraints {
            $0.bottom.equalTo(enterManualyButton.snp.top).scaledOffset(-12)
            $0.leading.equalToSuperview().scaledOffset(16)
            $0.trailing.equalToSuperview().scaledOffset(-16)
        }

        closeButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().scaledOffset(-16)
            $0.height.width.equalToScaledValue(72)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        bindViewModel()

        viewModel.didLoadTrigger.onNext(())
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scanQrButton.applyGradient(with: colors, gradient: .horizontal)
        enterManualyButton.applyGradient(with: colors, gradient: .horizontal)
        addPasswordButton.applyGradient(with: colors, gradient: .horizontal)
        closeButton.applyGradient(with: [UIColor.hex("#CF3255"), UIColor.hex("#CF3255")], gradient: .horizontal)
        closeButton.layer.cornerRadius = closeButton.frame.height / 2
    }

    private func setupUI() {
        view.backgroundColor = .black.withAlphaComponent(0.5)
    }

    private func bindViewModel() {
        closeButton.rx.tap
            .bind(to: viewModel.closeTrigger)
            .disposed(by: disposeBag)

        enterManualyButton.rx.tap
            .bind(to: viewModel.manualInputTrigger)
            .disposed(by: disposeBag)

        addPasswordButton.rx.tap
            .bind(to: viewModel.newPasswordTrigger)
            .disposed(by: disposeBag)

        scanQrButton.rx.tap
            .bind(to: viewModel.qrScannerTrigger)
            .disposed(by: disposeBag)
    }
}
