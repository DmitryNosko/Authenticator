import UIKit

final class ChooseIconTableViewCell: UITableViewCell, ReuseIdentifiable {
    private let containerView = UIView()
    private let backgroundIconView = UIView()
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()

    override func prepareForReuse() {
        super.prepareForReuse()
        containerView.removeGradientLayer()
        iconImageView.image = UIImage(named: "default_icon")
        titleLabel.text = nil
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(containerView)
        containerView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-12)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        containerView.addSubview(backgroundIconView)
        backgroundIconView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.bottom.lessThanOrEqualToSuperview().offset(-12)
            $0.leading.equalToSuperview().offset(16)
            $0.size.equalTo(40)
        }

        containerView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.centerY.equalTo(backgroundIconView.snp.centerY)
            $0.leading.equalTo(backgroundIconView.snp.trailing).offset(12)
            $0.height.equalTo(20)
        }

        backgroundIconView.addSubview(iconImageView)
        iconImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(24)
        }

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        selectionStyle = .none

        backgroundColor = .clear

        containerView.layer.cornerRadius = 20
        containerView.backgroundColor = .white
        containerView.clipsToBounds = true

        backgroundIconView.layer.cornerRadius = 12
        backgroundIconView.layer.masksToBounds = true
        backgroundIconView.backgroundColor = .concrete

        iconImageView.layer.cornerRadius = 12
        iconImageView.layer.masksToBounds = true
        iconImageView.image = UIImage(named: "default_icon")
        iconImageView.contentMode = .scaleAspectFit

        titleLabel.font = .outfit(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .codGray
    }

    func setup(service: Service) {
        iconImageView.image = UIImage(named: service.iconName)
        titleLabel.text = service.serviceName
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if selected {
            containerView.gradientBorder(colors: [UIColor.cobalt, UIColor.dodgerBlue])
        } else {
            containerView.removeGradientLayer()
        }
    }
}
