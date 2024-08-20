import RxCocoa
import RxSwift
import UIKit

final class PasswordPlaceholderView: UIView {
    private let infoView = PlaceholderInfoView()
    fileprivate let newPasswordButton = UIButton(type: .system)

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(infoView)
        infoView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        addSubview(newPasswordButton)
        newPasswordButton.snp.makeConstraints {
            $0.top.equalTo(infoView.snp.bottom).offset(32)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(72)
        }

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        newPasswordButton.applyGradient(with: [.cobalt, .dodgerBlue], gradient: .horizontal)
    }

    private func setupUI() {
        infoView.setup(
            imageName: "password_screen_icon",
            title: "Add Password",
            description: "Save your data and designate it secure with two-factor authentication"
        )

        with(newPasswordButton) {
            $0.layer.masksToBounds = true
            $0.layer.cornerRadius = 28
            $0.titleLabel?.font = .outfit(ofSize: 20, weight: .medium)
            $0.setTitle("New password", for: .normal)
            $0.tintColor = .white
        }
    }
}

// MARK: - Reactive extension

extension Reactive where Base: PasswordPlaceholderView {
    var newPasswordTrigger: ControlEvent<Void> {
        return base.newPasswordButton.rx.tap
    }
}
