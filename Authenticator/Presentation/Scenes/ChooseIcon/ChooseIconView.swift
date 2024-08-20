import UIKit
import RxSwift
import RxCocoa

final class ChooseIconView: UIViewController {
    var viewModel: ChooseIconViewModel!

    private let disposeBag = DisposeBag()

    private let titleLabel = UILabel()
    private let backButton = UIButton(frame: .zero)
    private let closeButton = UIButton(frame: .zero)
    private let continueButton = UIButton(frame: .zero)
    private let backgroundButtonView = UIView()

    private let tableView = UITableView(frame: .zero)

    override func loadView() {
        super.loadView()

        view.addSubview(tableView)
        view.addSubview(titleLabel)
        view.addSubview(backButton)
        view.addSubview(closeButton)
        view.addSubview(backgroundButtonView)
        backgroundButtonView.addSubview(continueButton)

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(23)
            $0.centerX.equalToSuperview()
            $0.height.equalToScaledValue(24)
        }

        backButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.centerY.equalTo(titleLabel)
            $0.size.equalTo(24)
        }

        closeButton.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel.snp.centerY)
            $0.trailing.equalToSuperview().scaledOffset(-16)
            $0.height.width.equalToScaledValue(30)
        }

        backgroundButtonView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(130)
        }

        continueButton.snp.makeConstraints {
            $0.leading.equalToSuperview().scaledOffset(20)
            $0.trailing.equalToSuperview().scaledOffset(-20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalToScaledValue(72)
        }

        tableView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(26)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(backgroundButtonView.snp.top)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        bindViewModel()

        viewModel.didLoadTrigger.onNext(())
    }

    private func setupUI() {
        view.backgroundColor = .concrete

        with(titleLabel) {
            $0.font = .outfit(ofSize: 20, weight: .medium)
            $0.text = "Choose Icon"
            $0.textColor = .black
        }

        with(closeButton) {
            $0.setImage(UIImage(systemName: "xmark")?.withTintColor(.black, renderingMode: .alwaysOriginal), for: .normal)
        }

        with(backButton) {
            $0.setImage(UIImage(named: "arrow-left")?.withTintColor(.black, renderingMode: .alwaysOriginal), for: .normal)
        }

        with(backgroundButtonView) {
            $0.backgroundColor = .concrete
            $0.layer.shadowColor = UIColor.black.withAlphaComponent(0.1).cgColor
            $0.layer.shadowOpacity = 1
            $0.layer.shadowOffset = CGSize.zero
        }

        with(continueButton) {
            $0.clipsToBounds = true
            $0.layer.cornerRadius = 28.scaled()
            $0.titleLabel?.font = .outfit(ofSize: 20, weight: .medium)
            $0.setTitle("Continue", for: .normal)
        }

        with(tableView) {
            $0.register(ChooseIconTableViewCell.self)
            $0.rowHeight = UITableView.automaticDimension
            $0.estimatedRowHeight = 75
            $0.backgroundColor = .concrete
            $0.separatorStyle = .none
        }
    }

    private func bindViewModel() {
        backButton.rx.tap
            .bind(to: viewModel.backTrigger)
            .disposed(by: disposeBag)
        closeButton.rx.tap
            .bind(to: viewModel.closeTrigger)
            .disposed(by: disposeBag)
        continueButton.rx.tap
            .bind(to: viewModel.continueTrigger)
            .disposed(by: disposeBag)
        viewModel.isContinueButtonEnabled
            .drive (onNext: { [weak self] isEnabled in
                self?.continueButton.isEnabled = isEnabled
                self?.continueButton.alpha = isEnabled ? 1 : 0.5
            })
            .disposed(by: disposeBag)
        bindTableView()
    }

    private func bindTableView() {
        viewModel.services
            .drive(tableView.rx.items(
                cellIdentifier: ChooseIconTableViewCell.reuseId, cellType: ChooseIconTableViewCell.self)
            ) { row, item, cell in
                cell.setup(service: item)
            }
            .disposed(by: disposeBag)
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        tableView.rx.itemSelected
            .bind(to: viewModel.selectedTrigger)
            .disposed(by: disposeBag)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        continueButton.applyGradient(with: [UIColor.hex("#003DB5"), UIColor.hex("#4D89FF")], gradient: .horizontal)
    }
}

extension ChooseIconView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        10
    }
}
