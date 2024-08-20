import UIKit

class PlaceholderInfoView: UIView {
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.centerX.equalToSuperview()
            $0.leading.greaterThanOrEqualToSuperview().offset(20)
            $0.trailing.lessThanOrEqualToSuperview().offset(-20)
        }

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(2)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.bottom.equalToSuperview().offset(-48)
        }

        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .white
        layer.cornerRadius = 20
        layer.shadowRadius = 4
        layer.shadowColor = UIColor.black.withAlphaComponent(0.4).cgColor
        layer.masksToBounds = false
        layer.shadowOpacity = 0.4
        layer.shadowOffset = CGSize.zero

        titleLabel.font = .outfit(ofSize: 32, weight: .bold)
        titleLabel.textColor = .codGray
        titleLabel.textAlignment = .center

        descriptionLabel.font = .outfit(ofSize: 16, weight: .medium)
        descriptionLabel.numberOfLines = 2
        descriptionLabel.textColor = .silver
        descriptionLabel.textAlignment = .center
    }

    func setup(imageName: String, title: String, description: String) {
        imageView.image = UIImage(named: imageName)
        titleLabel.text = title
        descriptionLabel.text = description
    }
}
