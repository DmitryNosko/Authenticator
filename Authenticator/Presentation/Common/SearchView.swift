import RxCocoa
import RxSwift
import UIKit

class SearchView: UIView {
    private let iconImageView = UIImageView()
    fileprivate let textField = UITextField()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(iconImageView)
        iconImageView.snp.makeConstraints {
            $0.size.equalTo(24)
            $0.top.leading.bottom.equalToSuperview().inset(16)
        }

        addSubview(textField)
        textField.snp.makeConstraints {
            $0.leading.equalTo(iconImageView.snp.trailing).offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalTo(iconImageView)
        }

        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .concrete
        layer.cornerRadius = 20

        iconImageView.image = UIImage(named: "search_icon")
        textField.placeholder = "Search services"
        textField.font = .outfit(ofSize: 16)
    }
}

// MARK: - Reactive extension

extension Reactive where Base: SearchView {
    var searchQuery: ControlProperty<String?> {
        return base.textField.rx.text
    }
}
