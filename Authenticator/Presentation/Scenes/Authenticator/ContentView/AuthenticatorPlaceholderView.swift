import RxCocoa
import RxSwift
import UIKit

final class AuthenticatorPlaceholderView: UIView {
    private let infoView = PlaceholderInfoView()
    fileprivate let scanButton = UIButton(type: .system)
    fileprivate let manualInputButton = UIButton(type: .system)

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(infoView)
        infoView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        addSubview(scanButton)
        scanButton.snp.makeConstraints {
            $0.top.equalTo(infoView.snp.bottom).offset(32)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(72)
        }

        addSubview(manualInputButton)
        manualInputButton.snp.makeConstraints {
            $0.centerX.equalTo(scanButton)
            $0.top.equalTo(scanButton.snp.bottom).offset(24)
            $0.bottom.equalToSuperview()
        }

        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        scanButton.applyGradient(with: [.cobalt, .dodgerBlue], gradient: .horizontal)
    }

    private func setupUI() {
        infoView.setup(
            imageName: "authenticator_placeholder_icon",
            title: "ADD 2FA Codes",
            description: "Save your data and designate it secure with two-factor authentication"
        )

        scanButton.setTitle("Scan QR-code", for: .normal)
        scanButton.setImage(UIImage(named: "scan_icon"), for: .normal)
        scanButton.titleLabel?.font = .outfit(ofSize: 20, weight: .medium)
        scanButton.layer.cornerRadius = 28
        scanButton.layer.masksToBounds = true
        scanButton.imageEdgeInsets = .init(top: 0, left: -5, bottom: 0, right: 5)
        scanButton.titleEdgeInsets = .init(top: 0, left: 5, bottom: 0, right: -5)
        scanButton.tintColor = .white

        manualInputButton.setAttributedTitle(
            NSAttributedString(
                string: "Enter manually",
                attributes: [
                    .font: UIFont.outfit(ofSize: 20, weight: .medium) as Any,
                    .underlineStyle: NSUnderlineStyle.single.rawValue
                ]
            ),
            for: .normal
        )
        manualInputButton.tintColor = .codGray
    }
}

// MARK: - Reactive extension

extension Reactive where Base: AuthenticatorPlaceholderView {
    var scanTrigger: ControlEvent<Void> {
        return base.scanButton.rx.tap
    }

    var manualInputTrigger: ControlEvent<Void> {
        return base.manualInputButton.rx.tap
    }
}
