import RxCocoa
import RxSwift
import UIKit

final class OnboardingViewCell: UICollectionViewCell, ReuseIdentifiable {

    fileprivate let closeButton = UIButton()
    fileprivate let restoreButton = UIButton()
    fileprivate let continueButton = UIButton()
    fileprivate let termsOfServiceButton = UIButton()
    fileprivate let privacyPolicyButton = UIButton()

    private let containerView = UIView()
    private let backgroundImageView = UIImageView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let bottomTermOfServiceAndPrivacyPolicyView = UIStackView()

    private(set) var reuseBag = DisposeBag()

    override init(frame: CGRect) {
        super.init(frame: frame)
        assemble()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        continueButton.applyGradient(with: [.cobalt, .dodgerBlue], gradient: .horizontal)
    }

    override func prepareForReuse() {
        titleLabel.text = nil
        descriptionLabel.text = nil
        reuseBag = DisposeBag()
    }

    func setup(step: OnboardingStep) {
        switch step.stepType {
        case .info:
            closeButton.isHidden = true
            restoreButton.isHidden = true
            bottomTermOfServiceAndPrivacyPolicyView.isHidden = true
        case .restore:
            closeButton.isHidden = false
            restoreButton.isHidden = false
            bottomTermOfServiceAndPrivacyPolicyView.isHidden = false
        }
        backgroundImageView.image = UIImage(named: step.backgroundImage)
        titleLabel.text = step.title
        descriptionLabel.text = step.description
        continueButton.setTitle(step.buttonTitle, for: .normal)
    }
}

//MARK: - UI Configuration
private extension OnboardingViewCell {

    func assemble() {
        addSubviews()
        setConstraints()
        configureViews()
    }

    func addSubviews() {
        addSubview(containerView)
        containerView.addSubview(backgroundImageView)
        containerView.addSubview(closeButton)
        containerView.addSubview(restoreButton)
        bottomTermOfServiceAndPrivacyPolicyView.addArrangedSubview(termsOfServiceButton)
        bottomTermOfServiceAndPrivacyPolicyView.addArrangedSubview(privacyPolicyButton)
        containerView.addSubview(bottomTermOfServiceAndPrivacyPolicyView)
        containerView.addSubview(continueButton)
        containerView.addSubview(descriptionLabel)
        containerView.addSubview(titleLabel)
    }

    func configureViews() {
        with(containerView) {
            $0.backgroundColor = .clear
        }

        with(backgroundImageView) {
            $0.contentMode = .scaleAspectFill
        }

        with(closeButton) {
            $0.setImage(UIImage(named: "close")?.withTintColor(.silver, renderingMode: .alwaysOriginal), for: .normal)
        }

        with(restoreButton) {
            $0.setTitle("Restore", for: .normal)
            $0.titleLabel?.font = .outfit(ofSize: 14)
            $0.setTitleColor(.silver, for: .normal)
        }

        with(titleLabel) {
            $0.numberOfLines = 0
            $0.textAlignment = .center
            $0.font = .outfit(ofSize: 40, weight: .bold)
            $0.textColor = .codGray
        }

        with(descriptionLabel) {
            $0.numberOfLines = 0
            $0.textAlignment = .center
            $0.font = .outfit(ofSize: 14)
            $0.textColor = .nobel
        }

        with(continueButton) {
            $0.titleLabel?.font = .outfit(ofSize: 20)
            $0.layer.cornerRadius = 28
            $0.layer.masksToBounds = true
            $0.tintColor = .white
        }

        with(bottomTermOfServiceAndPrivacyPolicyView) {
            $0.axis = .horizontal
            $0.spacing = 25.scaled()
        }

        with(termsOfServiceButton) {
            $0.setTitle("Terms of Service", for: .normal)
            $0.titleLabel?.font = .outfit(ofSize: 12)
            $0.setTitleColor(.silver, for: .normal)
        }

        with(privacyPolicyButton) {
            $0.setTitle("Privacy Policy", for: .normal)
            $0.titleLabel?.font = .outfit(ofSize: 12)
            $0.setTitleColor(.silver, for: .normal)
        }
    }

    func setConstraints() {
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        backgroundImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        closeButton.snp.makeConstraints {
            $0.size.equalToScaledValue(30)
            $0.top.equalTo(safeAreaLayoutGuide).scaledOffset(10)
            $0.leading.equalToSuperview().scaledOffset(24)
        }

        restoreButton.snp.makeConstraints {
            $0.centerY.equalTo(closeButton.snp.centerY)
            $0.trailing.equalToSuperview().scaledOffset(-24)
        }

        bottomTermOfServiceAndPrivacyPolicyView.snp.makeConstraints {
            $0.height.equalToScaledValue(20)
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(safeAreaLayoutGuide).scaledOffset(-10)
        }

        continueButton.snp.makeConstraints {
            $0.bottom.equalTo(safeAreaLayoutGuide).scaledOffset(-42)
            $0.leading.equalToSuperview().scaledOffset(20)
            $0.trailing.equalToSuperview().scaledOffset(-20)
            $0.height.equalToScaledValue(72)
        }

        descriptionLabel.snp.makeConstraints {
            $0.bottom.equalTo(continueButton.snp.top).scaledOffset(-36)
            $0.leading.equalToSuperview().scaledOffset(40)
            $0.trailing.equalToSuperview().scaledOffset(-40)
        }

        titleLabel.snp.makeConstraints {
            $0.bottom.equalTo(descriptionLabel.snp.top).scaledOffset(-8)
            $0.leading.equalToSuperview().scaledOffset(30)
            $0.trailing.equalToSuperview().scaledOffset(-30)
        }
    }
}

// MARK: - Reactive extension
extension Reactive where Base: OnboardingViewCell {
    var closeTrigger: ControlEvent<Void> {
        return base.closeButton.rx.tap
    }

    var restoreTrigger: ControlEvent<Void> {
        return base.restoreButton.rx.tap
    }

    var continueTrigger: ControlEvent<Void> {
        return base.continueButton.rx.tap
    }

    var termsOfServiceTrigger: ControlEvent<Void> {
        return base.termsOfServiceButton.rx.tap
    }

    var privacyPolicyTrigger: ControlEvent<Void> {
        return base.privacyPolicyButton.rx.tap
    }
}
