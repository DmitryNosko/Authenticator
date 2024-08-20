import RxCocoa
import RxSwift
import UIKit

final class PremiumView: UIViewController {
    var viewModel: PremiumViewModel!

    private let backButton = UIButton()
    private let titleLabel = UILabel()
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
        backButton.rx.tap
            .bind(to: viewModel.backTrigger)
            .disposed(by: disposeBag)
        bindTableView()
    }

    private func bindTableView() {
        //MARK: - Input
        tableView.rx.itemSelected
            .bind(to: viewModel.selectTrigger)
            .disposed(by: disposeBag)

        //MARK: - Output
        viewModel.subscriptions
            .drive(tableView.rx.items(
                cellIdentifier: PremiumTableViewCell.reuseId,
                cellType: PremiumTableViewCell.self)
            ) { row, item, cell in
                cell.setup(model: item)
            }
            .disposed(by: disposeBag)
    }
}

//MARK: - Configure UI
private extension PremiumView {
    func assemble() {
        addSubviews()
        configureViews()
        setConstraints()
    }

    func addSubviews() {
        view.addSubview(titleLabel)
        view.addSubview(backButton)
        view.addSubview(tableView)
    }

    func configureViews() {

        with(titleLabel) {
            $0.text = "Premium"
            $0.textColor = .black
            $0.font = .outfit(ofSize: 30, weight: .bold)
        }

        with(backButton) {
            $0.setImage(UIImage(named: "back"), for: .normal)
        }

        with(tableView) {
            $0.backgroundColor = .clear
            $0.register(PremiumTableViewCell.self,
                        forCellReuseIdentifier: PremiumTableViewCell.reuseId)
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
        backButton.snp.makeConstraints {
            $0.size.equalToScaledValue(30)
            $0.top.equalTo(self.view.safeAreaLayoutGuide)
            $0.leading.equalToSuperview().scaledOffset(20)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide)
            $0.centerX.equalToSuperview()
        }

        tableView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).scaledOffset(20)
            $0.bottom.equalToSuperview().scaledOffset(-20)
            $0.leading.equalToSuperview().scaledOffset(20)
            $0.trailing.equalToSuperview().scaledOffset(-20)
        }
    }
}
