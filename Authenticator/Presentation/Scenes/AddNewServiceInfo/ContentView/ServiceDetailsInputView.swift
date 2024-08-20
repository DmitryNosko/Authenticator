import UIKit
import RxSwift
import RxCocoa

final class ServiceDetailsInputView: UIView {
    fileprivate let inputTextField = UITextField()

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.snp.makeConstraints {
            $0.height.equalTo(64)
        }

        addSubview(inputTextField)
        inputTextField.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(24)
        }

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .white
        layer.cornerRadius = 20
        layer.masksToBounds = true

        with(inputTextField) {
            $0.font = .outfit(ofSize: 16, weight: .regular)
        }
    }

    func setup(placeholder: String) {
        inputTextField.placeholder = placeholder
    }

    func setup(_ value: String?) {
        inputTextField.text = value
    }
}

extension Reactive where Base: ServiceDetailsInputView {
    var inputText: ControlProperty<String?> {
        return base.inputTextField.rx.text
    }
}
