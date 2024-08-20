import RxCocoa
import RxSwift
import UIKit

final class PageHeaderView: UIView {
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    fileprivate let settingsButton = UIButton(type: .system)

    private let searchContainer = UIView()
    fileprivate let searchView = SearchView()

    private static let searchViewHeight: CGFloat = 56

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(settingsButton)
        settingsButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(2)
            $0.trailing.equalToSuperview()
            $0.bottom.lessThanOrEqualToSuperview()
            $0.size.equalTo(60)
        }

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
            $0.trailing.equalTo(settingsButton.snp.leading).offset(-8)
        }

        addSubview(subtitleLabel)
        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom)
            $0.leading.equalToSuperview()
            $0.trailing.equalTo(settingsButton.snp.leading).offset(-8)
        }

        addSubview(searchContainer)
        searchContainer.snp.makeConstraints {
            $0.top.equalTo(subtitleLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.equalTo(PageHeaderView.searchViewHeight)
        }

        searchContainer.addSubview(searchView)
        searchView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        titleLabel.textColor = .codGray
        titleLabel.font = .outfit(ofSize: 30, weight: .bold)

        subtitleLabel.textColor = .doveGray
        subtitleLabel.font = .outfit(ofSize: 20)

        settingsButton.backgroundColor = .concrete
        settingsButton.layer.cornerRadius = 30
        settingsButton.setImage(UIImage(named: "gear_icon"), for: .normal)
        settingsButton.tintColor = .codGray
    }

    func setup(title: String, subtitle: String) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
    }

    func showSearchView() {
        searchContainer.snp.updateConstraints {
            $0.height.equalTo(PageHeaderView.searchViewHeight)
        }
    }

    func hideSearchView() {
        searchContainer.snp.updateConstraints {
            $0.height.equalTo(0)
        }
    }
}

// MARK: - Reactive wrapper

extension Reactive where Base: PageHeaderView {
    var searchQuery: ControlProperty<String?> {
        return base.searchView.rx.searchQuery
    }

    var settingsTrigger: ControlEvent<Void> {
        return base.settingsButton.rx.tap
    }
}
