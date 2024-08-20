import RxSwift
import UIKit

final class AuthenticatorContentView: UIView {
    var viewModel: AuthenticatorContentViewModel!

    private let contentView = PassthroughView()
    private let codeLabel = UILabel()
    private let copyButton = UIButton(type: .system)
    private let timerView = CircularTimerView()

    private let errorLabel = UILabel()

    private let disposeBag = DisposeBag()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        contentView.addSubview(codeLabel)
        codeLabel.snp.makeConstraints {
            $0.top.leading.bottom.equalToSuperview()
        }

        contentView.addSubview(timerView)
        timerView.snp.makeConstraints {
            $0.size.equalTo(52)
            $0.trailing.equalToSuperview()
            $0.top.greaterThanOrEqualToSuperview()
            $0.bottom.lessThanOrEqualToSuperview()
            $0.centerY.equalTo(codeLabel)
        }

        contentView.addSubview(copyButton)
        copyButton.snp.makeConstraints {
            $0.leading.equalTo(codeLabel.snp.trailing).offset(12)
            $0.centerY.equalTo(codeLabel)
            $0.trailing.lessThanOrEqualTo(timerView.snp.leading).offset(-12)
            $0.size.equalTo(24)
        }

        addSubview(errorLabel)
        errorLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
        }

        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        codeLabel.textColor = .codGray
        codeLabel.font = .outfit(ofSize: 48, weight: .bold)

        copyButton.setImage(UIImage(named: "copy_icon"), for: .normal)
        copyButton.tintColor = .codGray

        timerView.isUserInteractionEnabled = false

        errorLabel.textAlignment = .center
        errorLabel.font = .outfit(ofSize: 16, weight: .medium)
        errorLabel.text = "Something went wrong"
        errorLabel.isHidden = true
    }

    func setup(viewModel: AuthenticatorContentViewModel) {
        self.viewModel = viewModel
        viewModel.code
            .drive(codeLabel.rx.text)
            .disposed(by: disposeBag)
        viewModel.timer
            .drive(onNext: { [weak self] value in
                self?.timerView.update(value: value)
            })
            .disposed(by: disposeBag)
        viewModel.state
            .drive(onNext: { [weak self] state in
                self?.update(state: state)
            })
            .disposed(by: disposeBag)
        copyButton.rx.tap
            .bind(to: viewModel.copyTrigger)
            .disposed(by: disposeBag)
    }

    private func update(state: AuthenticatorContentViewState) {
        switch state {
        case .idle:
            contentView.isHidden = false
            errorLabel.isHidden = true
        case .failed:
            contentView.isHidden = true
            errorLabel.isHidden = false
        }
    }
}
