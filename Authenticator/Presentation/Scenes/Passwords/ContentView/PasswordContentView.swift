import UIKit

final class PasswordContentView: UIView {
    var viewModel: CredentialsContentViewModel!

    private let contentView = PassthroughView()
    private let passwordTitleLabel = UILabel()
    private let loginTitleLabel = UILabel()
    private let passwordLabel = UILabel()
    private let loginLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        contentView.addSubview(loginTitleLabel)
        contentView.addSubview(passwordTitleLabel)
        contentView.addSubview(loginLabel)
        contentView.addSubview(passwordLabel)

        loginTitleLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
            $0.height.equalTo(24)
        }

        loginLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalTo(loginTitleLabel.snp.trailing).offset(10)
            $0.height.equalTo(24)
        }

        passwordTitleLabel.snp.makeConstraints {
            $0.top.equalTo(loginLabel.snp.bottom)
            $0.leading.equalToSuperview()
            $0.height.equalTo(24)
            $0.bottom.equalToSuperview()
        }

        passwordLabel.snp.makeConstraints {
            $0.top.equalTo(loginLabel.snp.bottom)
            $0.leading.equalTo(passwordTitleLabel.snp.trailing).offset(10)
            $0.height.equalTo(24)
        }

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        passwordTitleLabel.text = "Password:"
        passwordTitleLabel.font = .outfit(ofSize: 16, weight: .regular)
        passwordTitleLabel.textColor = .nobel

        passwordLabel.textColor = .codGray
        passwordLabel.font = .outfit(ofSize: 16, weight: .bold)

        loginTitleLabel.text = "Login:"
        loginTitleLabel.font = .outfit(ofSize: 16, weight: .regular)
        loginTitleLabel.textColor = .nobel

        loginLabel.textColor = .codGray
        loginLabel.font = .outfit(ofSize: 16, weight: .bold)
    }

    func setup(viewModel: CredentialsContentViewModel) {
        self.viewModel = viewModel
        passwordLabel.text = viewModel.credentials.password
        loginLabel.text = viewModel.credentials.email
    }
}
