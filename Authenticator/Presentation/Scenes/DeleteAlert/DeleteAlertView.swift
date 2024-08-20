import RxCocoa
import RxSwift
import RxGesture
import UIKit

final class DeleteAlertView: UIViewController {
    var viewModel: DeleteAlertViewModel!

    private let backgroundView = UIView()
    private let containerView = UIView()
    private let titleLabel = UILabel()
    private let closeButton = UIButton(type: .system)
    private let confirmButton = UIButton(type: .system)
    private let cancelButton = UIButton(type: .system)

    private let disposeBag = DisposeBag()

    override func loadView() {
        view = UIView()

        view.addSubview(backgroundView)
        backgroundView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        view.addSubview(containerView)
        containerView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.centerY.equalToSuperview()
        }

        containerView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(35)
            $0.leading.trailing.equalToSuperview().inset(60)
        }

        containerView.addSubview(closeButton)
        closeButton.snp.makeConstraints {
            $0.top.trailing.equalToSuperview().inset(14)
            $0.size.equalTo(30)
        }

        containerView.addSubview(confirmButton)
        confirmButton.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(72)
        }

        containerView.addSubview(cancelButton)
        cancelButton.snp.makeConstraints {
            $0.top.equalTo(confirmButton.snp.bottom).offset(12)
            $0.leading.trailing.bottom.equalToSuperview().inset(20)
            $0.height.equalTo(72)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        bindViewModel()
    }

    private func setupUI() {
        backgroundView.backgroundColor = .black.withAlphaComponent(0.5)

        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 32

        titleLabel.text = "Do you really want to delete this data"
        titleLabel.textAlignment = .center
        titleLabel.font = .outfit(ofSize: 25, weight: .semibold)
        titleLabel.textColor = .codGray
        titleLabel.numberOfLines = 2

        confirmButton.setTitle("Delete", for: .normal)
        confirmButton.setImage(UIImage(named: "delete_alert_confirm_icon"), for: .normal)
        confirmButton.titleLabel?.font = .outfit(ofSize: 20, weight: .medium)
        confirmButton.layer.cornerRadius = 20
        confirmButton.layer.masksToBounds = true
        confirmButton.imageEdgeInsets = .init(top: 0, left: -5, bottom: 0, right: 5)
        confirmButton.titleEdgeInsets = .init(top: 0, left: 5, bottom: 0, right: -5)
        confirmButton.tintColor = .white

        cancelButton.setTitle("Back", for: .normal)
        cancelButton.titleLabel?.font = .outfit(ofSize: 20, weight: .medium)
        cancelButton.layer.cornerRadius = 20
        cancelButton.layer.masksToBounds = true
        cancelButton.tintColor = .cobalt

        closeButton.setImage(UIImage(named: "close"), for: .normal)
        closeButton.tintColor = .codGray
    }

    private func bindViewModel() {
        backgroundView.rx.tapGesture()
            .when(.recognized)
            .map { _ in () }
            .bind(to: viewModel.cancelTrigger)
            .disposed(by: disposeBag)
        closeButton.rx.tap
            .bind(to: viewModel.cancelTrigger)
            .disposed(by: disposeBag)
        cancelButton.rx.tap
            .bind(to: viewModel.cancelTrigger)
            .disposed(by: disposeBag)
        confirmButton.rx.tap
            .bind(to: viewModel.confirmTrigger)
            .disposed(by: disposeBag)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        confirmButton.applyGradient(with: [.brightRed, .sunsetOrange], gradient: .horizontal)
        cancelButton.gradientBorder(colors: [.cobalt, .dodgerBlue])
    }
}
