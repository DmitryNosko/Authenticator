import RxCocoa
import RxSwift
import UIKit

class CustomTabBar: UITabBar {
    fileprivate let createButton = CircleButton(image: UIImage(systemName: "plus")?.withTintColor(.white, renderingMode: .alwaysOriginal))

    override init(frame: CGRect) {
        super.init(frame: frame)
        assemble()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        createButton.center = CGPoint(x: frame.width / 2, y: frame.height / 3)
        createButton.applyGradient(with: [UIColor.hex("#003DB5"), UIColor.hex("#4D89FF")], gradient: .horizontal)
    }

    private func assemble() {
        addSubviews()
        setupUI()
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard !clipsToBounds && !isHidden && alpha > 0 else { return nil }

        return self.createButton.frame.contains(point) ? self.createButton : super.hitTest(point, with: event)
    }
}

private extension CustomTabBar {
    func addSubviews() {
        self.addSubview(createButton)
    }

    func setupUI() {
        with(createButton) {
            $0.frame.size = CGSize(width: 72.scaled(), height: 72.scaled())
            $0.layer.cornerRadius = $0.frame.height / 2
        }
    }
}

// MARK: - Reactive implmentation

extension Reactive where Base: CustomTabBar {
    var createTrigger: ControlEvent<Void> {
        return base.createButton.rx.tap
    }
}
