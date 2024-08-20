import RxCocoa
import RxSwift
import UIKit

final class PasswordsView: UIViewController {
    var viewModel: PasswordsViewModel!

    private let disposeBag = DisposeBag()

    private let headerView = PageHeaderView()
    private let passwordPlaceholderView = PasswordPlaceholderView()
    private let tableView = UITableView(frame: .zero)

    override func loadView() {
        super.loadView()

        view.addSubview(headerView)
        view.addSubview(passwordPlaceholderView)
        view.addSubview(tableView)

        headerView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
        }

        passwordPlaceholderView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }

        tableView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom).offset(24)
            $0.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        bindViewModel()

        viewModel.didLoadTrigger.onNext(())
    }

    private func setupUI() {
        view.backgroundColor = .white
        headerView.setup(
            title: "Passwords",
            subtitle: "keep your security data"
        )

        tableView.register(AccordionTableViewCell.self)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 76
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
    }

    private func bindViewModel() {
        rx.methodInvoked(#selector(UIViewController.viewWillAppear(_:)))
            .map { _ in () }
            .bind(to: viewModel.willAppearTrigger)
            .disposed(by: disposeBag)
        headerView.rx.settingsTrigger
            .bind(to: viewModel.settingsTrigger)
            .disposed(by: disposeBag)
        passwordPlaceholderView.rx.newPasswordTrigger
            .bind(to: viewModel.newPasswordTrigger)
            .disposed(by: disposeBag)
        Observable.combineLatest(viewModel.credentials.asObservable(), headerView.rx.searchQuery)
            .subscribe(onNext: { [weak self] items, searchQuery in
                let areItemsEmpty = items.isEmpty && (searchQuery?.isEmpty ?? true)
                self?.tableView.isHidden = areItemsEmpty
                self?.passwordPlaceholderView.isHidden = !areItemsEmpty
                if areItemsEmpty {
                    self?.headerView.hideSearchView()
                } else {
                    self?.headerView.showSearchView()
                }
            })
            .disposed(by: disposeBag)
        headerView.rx.searchQuery
            .bind(to: viewModel.searchQuery)
            .disposed(by: disposeBag)
        bindTableView()
    }

    private func bindTableView() {
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        viewModel.credentials
            .drive(tableView.rx.items(
                cellIdentifier: AccordionTableViewCell.reuseId, cellType: AccordionTableViewCell.self)
            ) { [weak self] row, item, cell in
                guard let self = self else { return }
                cell.setup(viewModel: self.viewModel.credentialsViewModel(item))
            }
            .disposed(by: disposeBag)
        tableView.rx.itemDeselected
            .do(
                onNext: { [weak self] _ in
                    self?.tableView.beginUpdates()
                },
                afterNext: { [weak self] _ in
                    self?.tableView.endUpdates()
                }
            )
            .subscribe()
            .disposed(by: disposeBag)
        tableView.rx.itemSelected
            .do(onNext: { [weak self] _ in
                self?.tableView.beginUpdates()
            })
            .do(afterNext: { [weak self] _ in
                DispatchQueue.main.async { [weak self] in
                    self?.tableView.endUpdates()
                }
            })
            .subscribe()
            .disposed(by: disposeBag)
        tableView.rx.willBeginDragging
            .subscribe(onNext: { [weak self] in
                self?.view.endEditing(true)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - UITableViewDelegate implementation

extension PasswordsView: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        tableView.beginUpdates()
        // Actually TableView deselects Row by itself later
        // but we're doing it earlier and withing updates block to make
        // sure that Accordion will collapse properly
        // Note: yeah, there is a small UI glitch which we wouldn't fix now
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.endUpdates()
        let deleteAction = UIContextualAction(
            style: .destructive,
            title: nil,
            handler: { [weak self, indexPath] _, _, success in
                success(true)
                self?.viewModel.deleteTrigger.onNext(indexPath)
            }
        )
        deleteAction.image = UIImage(named: "delete_icon")
        deleteAction.backgroundColor = .white
        let editAction = UIContextualAction(
            style: .normal,
            title: nil,
            handler: { [weak self, indexPath] _, _, success in
                success(true)
                self?.viewModel.editTrigger.onNext(indexPath)
            }
        )
        editAction.image = UIImage(named: "edit_icon")
        editAction.backgroundColor = .white
        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }

    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath == tableView.indexPathForSelectedRow {
            _ = tableView.delegate?.tableView?(tableView, willDeselectRowAt: indexPath)
            tableView.deselectRow(at: indexPath, animated: true)
            tableView.delegate?.tableView?(tableView, didDeselectRowAt: indexPath)
            return nil
        } else {
            return indexPath
        }
    }
}
