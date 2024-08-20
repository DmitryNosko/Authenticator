import RxCocoa
import RxSwift
import UIKit

final class SettingsView: UIViewController {
    var viewModel: SettingsViewModel!

    private let titleLabel = UILabel()
    private let closeButton = UIButton()
    private let biometricView = SettingsBiometricView()
    private let headerLabel = UILabel()
    private let tableView = UITableView()

    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        bindViewModel()

        viewModel.didLoadTrigger.onNext(())
    }

    private func setupUI() {
        view.backgroundColor = .white
        navigationController?.isNavigationBarHidden = true
        assemble()
    }

    private func bindViewModel() {
        closeButton.rx.tap
            .bind(to: viewModel.closeTrigger)
            .disposed(by: disposeBag)
        bindTableView()
    }

    private func bindTableView() {
        //MARK: - Input
        biometricView.rx.biometricTrigger
            .bind(to: viewModel.biometricTrigger)
            .disposed(by: disposeBag)
        tableView.rx.itemSelected
            .bind(to: viewModel.selectTrigger)
            .disposed(by: disposeBag)

        //MARK: - Output
        viewModel.biometricType
            .drive { [weak self] type in
                self?.biometricView.bind(title: type.rawValue)
            }
            .disposed(by: disposeBag)
        
        viewModel.isBiometricEnabled
            .drive { [weak self] isEnabled in
                self?.biometricView.setIsOn(isEnabled)
            }
            .disposed(by: disposeBag)
        
        viewModel.settings
            .drive(tableView.rx.items(
                cellIdentifier: SettingsTableViewCell.reuseId,
                cellType: SettingsTableViewCell.self)
            ) { row, item, cell in
                cell.bind(model: item)
            }
            .disposed(by: disposeBag)
    }
}

//MARK: - Configure UI
private extension SettingsView {
    func assemble() {
        addSubviews()
        configureViews()
        setConstraints()
    }

    func addSubviews() {
        view.addSubview(titleLabel)
        view.addSubview(closeButton)
        view.addSubview(biometricView)
        view.addSubview(headerLabel)
        view.addSubview(tableView)
    }

    func configureViews() {

        with(titleLabel) {
            $0.text = "Settings"
            $0.textColor = .black
            $0.font = .outfit(ofSize: 30, weight: .bold)
        }

        with(closeButton) {
            $0.setImage(UIImage(named: "close"), for: .normal)
        }
        
        with(headerLabel) {
            $0.text = "General"
            $0.textColor = UIColor.hex("#999999")
            $0.font = .outfit(ofSize: 16)
        }

        with(tableView) {
            $0.backgroundColor = .clear
            $0.register(SettingsTableViewCell.self,
                        forCellReuseIdentifier: SettingsTableViewCell.reuseId)
            $0.separatorColor = .clear
            $0.separatorStyle = .none
            $0.showsHorizontalScrollIndicator = false
            $0.showsVerticalScrollIndicator = false
            $0.sectionHeaderTopPadding = 0
            $0.keyboardDismissMode = .onDrag
            $0.alwaysBounceVertical = true
            $0.sectionHeaderTopPadding = 10
        }
    }

    func setConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide)
            $0.leading.equalToSuperview().scaledOffset(20)
        }

        closeButton.snp.makeConstraints {
            $0.size.equalToScaledValue(30)
            $0.centerY.equalTo(titleLabel.snp.centerY)
            $0.trailing.equalToSuperview().scaledOffset(-20)
        }
        
        biometricView.snp.makeConstraints {
            $0.height.equalToScaledValue(60)
            $0.top.equalTo(titleLabel.snp.bottom).scaledOffset(20)
            $0.leading.equalToSuperview().scaledOffset(20)
            $0.trailing.equalToSuperview().scaledOffset(-20)
        }
        
        headerLabel.snp.makeConstraints {
            $0.top.equalTo(biometricView.snp.bottom).scaledOffset(16)
            $0.leading.equalTo(biometricView.snp.leading)
        }

        tableView.snp.makeConstraints {
            $0.top.equalTo(headerLabel.snp.bottom).scaledOffset(10)
            $0.bottom.equalToSuperview().scaledOffset(-20)
            $0.leading.equalToSuperview().scaledOffset(20)
            $0.trailing.equalToSuperview().scaledOffset(-20)
        }
    }
}

