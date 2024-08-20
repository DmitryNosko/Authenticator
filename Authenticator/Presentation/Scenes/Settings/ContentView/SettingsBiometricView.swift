import RxCocoa
import RxSwift
import UIKit

final class SettingsBiometricView: UIView {
    private let titleLabel = UILabel()
    fileprivate let switchView = UISwitch()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(2)
            $0.trailing.equalToSuperview()
            $0.bottom.lessThanOrEqualToSuperview()
            $0.size.equalTo(60)
        }

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().scaledOffset(16)
        }

        addSubview(switchView)
        switchView.snp.makeConstraints {
            $0.height.equalToScaledValue(31)
            $0.width.equalToScaledValue(51)
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().scaledOffset(-16)
        }

        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        layer.cornerRadius = 24.scaled()
        backgroundColor = .concrete
        
        titleLabel.font = .outfit(ofSize: 16)
        titleLabel.textColor = .codGray
        titleLabel.textAlignment = .left

        switchView.onTintColor = .cobalt
        switchView.backgroundColor = .clear
    }
    
    func bind(title: String) {
        titleLabel.text = title
    }

    func setIsOn(_ isOn: Bool) {
        switchView.setOn(isOn, animated: true)
    }
}

extension Reactive where Base: SettingsBiometricView {
    var biometricTrigger: ControlEvent<Bool> {
        return base.switchView.rx.value.changed
    }
}

