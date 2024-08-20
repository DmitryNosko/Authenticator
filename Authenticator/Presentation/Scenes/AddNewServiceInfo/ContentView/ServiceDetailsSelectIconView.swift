import UIKit
import RxSwift
import RxCocoa

final class ServiceDetailsSelectIconView: UIView {
    private let backgroundIconView = UIView()
    private let iconImageView = UIImageView()
    private let serviceNameLabel = UILabel()
    private let accessoryImageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(backgroundIconView)
        backgroundIconView.addSubview(iconImageView)
        addSubview(serviceNameLabel)
        addSubview(accessoryImageView)

        self.snp.makeConstraints {
            $0.height.equalTo(64)
        }

        iconImageView.snp.makeConstraints {
            $0.size.equalTo(40)
            $0.center.equalToSuperview()
        }

        backgroundIconView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.size.equalTo(40)
            $0.centerY.equalToSuperview()
        }

        serviceNameLabel.snp.makeConstraints {
            $0.leading.equalTo(iconImageView.snp.trailing).offset(12)
            $0.trailing.lessThanOrEqualTo(accessoryImageView.snp.leading).offset(-8)
            $0.centerY.equalTo(iconImageView.snp.centerY)
            $0.height.equalTo(24)
        }

        accessoryImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-16)
            $0.size.equalTo(24)
        }

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .white
        layer.cornerRadius = 20
        layer.masksToBounds = true

        backgroundIconView.layer.cornerRadius = 12
        backgroundIconView.layer.masksToBounds = true
        backgroundIconView.backgroundColor = .concrete

        iconImageView.image = UIImage(named: "new_service_default_icon")
        iconImageView.contentMode = .scaleAspectFit

        serviceNameLabel.text = "Select icon"
        serviceNameLabel.font = .outfit(ofSize: 16, weight: .regular)
        serviceNameLabel.textColor = UIColor.hex("#B3B3B3")

        accessoryImageView.image = UIImage(named: "arrow_right")
    }

    func setup(serviceName: String, serviceIconName: String) {
        serviceNameLabel.text = serviceName
        serviceNameLabel.textColor = .black
        iconImageView.image = UIImage(named: serviceIconName)

        iconImageView.snp.updateConstraints {
            $0.size.equalTo(24)
        }
    }
}
