import RxSwift
import UIKit

protocol AccordionViewModel {
    var selectTrigger: AnyObserver<Bool> { get }
}

final class AccordionTableViewCell: UITableViewCell, ReuseIdentifiable {
    var viewModel: AccordionViewModel!

    // Useful for expanding and collapsing content
    // Actually regular View will throw a lot of warnings about
    // incosistency of active constraints, but wrapping up with UIScrollView
    // creates really convinient bounds system for expanding and collapsing content.
    private let scrollView = PassthroughScrollView()
    private let containerView = UIView()
    // Adding separate background due to
    // adding alignmentRects to Image changes ImageView frame
    private let iconBackgroundView = UIView()
    private let iconImageView = UIImageView()
    private let textContainer = UIView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let detailsView = PassthroughView()
    private let accessoryImageView = UIImageView()

    private struct Sizes {
        static let collapsedHeight: CGFloat = 64

        private init() {}
    }

    private var reuseBag = DisposeBag()

    override func prepareForReuse() {
        super.prepareForReuse()

        iconImageView.image = UIImage(named: Service.default.iconName)?
            .withAlignmentRectInsets(.init(top: -8, left: -8, bottom: -8, right: -8))
        titleLabel.text = nil
        descriptionLabel.text = nil
        detailsView.subviews.forEach { $0.removeFromSuperview() }

        reuseBag = DisposeBag()
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if scrollView.frame.height > Sizes.collapsedHeight, detailsView.frame.contains(point) {
            return detailsView.hitTest(self.convert(point, to: detailsView), with: event)
        } else {
            return super.hitTest(point, with: event)
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(scrollView)
        scrollView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-12)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(Sizes.collapsedHeight).priority(999)
        }

        scrollView.addSubview(containerView)
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
            $0.height.equalToSuperview().priority(.low)
        }

        containerView.addSubview(iconImageView)
        iconImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.bottom.lessThanOrEqualToSuperview().offset(-12)
            $0.leading.equalToSuperview().offset(16)
            $0.size.equalTo(40)
        }

        containerView.insertSubview(iconBackgroundView, belowSubview: iconImageView)
        iconBackgroundView.snp.makeConstraints {
            $0.edges.equalTo(iconImageView)
        }

        containerView.addSubview(accessoryImageView)
        accessoryImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-16)
            $0.size.equalTo(24)
        }

        containerView.addSubview(textContainer)
        textContainer.snp.makeConstraints {
            $0.centerY.equalTo(iconImageView)
            $0.leading.equalTo(iconImageView.snp.trailing).offset(12)
            $0.trailing.lessThanOrEqualTo(accessoryImageView.snp.leading).offset(-8)
        }

        textContainer.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }

        textContainer.addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        containerView.addSubview(detailsView)
        detailsView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(64)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }

        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        selectionStyle = .none

        scrollView.layer.cornerRadius = 20
        scrollView.backgroundColor = .concrete
        scrollView.isScrollEnabled = false
        scrollView.isUserInteractionEnabled = false

        iconImageView.image = UIImage(named: Service.default.iconName)?
            .withAlignmentRectInsets(.init(top: -8, left: -8, bottom: -8, right: -8))
        iconImageView.contentMode = .scaleAspectFit

        iconBackgroundView.backgroundColor = .white
        iconBackgroundView.layer.cornerRadius = 12
        iconBackgroundView.layer.masksToBounds = true

        titleLabel.font = .outfit(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .codGray
        titleLabel.setContentHuggingPriority(.required, for: .vertical)
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)

        descriptionLabel.setContentHuggingPriority(.required, for: .vertical)
        descriptionLabel.setContentCompressionResistancePriority(.required, for: .vertical)

        descriptionLabel.font = .outfit(ofSize: 16)
        descriptionLabel.textColor = .nobel

        textContainer.setContentHuggingPriority(.required, for: .vertical)
        textContainer.setContentCompressionResistancePriority(.required, for: .vertical)

        detailsView.setContentHuggingPriority(.defaultLow, for: .vertical)
        detailsView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)

        detailsView.clipsToBounds = true

        accessoryImageView.image = UIImage(named: "expand_icon")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        update(isSelected: selected)
    }

    private func update(isSelected: Bool) {
        scrollView.snp.updateConstraints {
            $0.height.equalTo(isSelected ? scrollView.contentSize.height : Sizes.collapsedHeight).priority(999)
        }
        let transform: CGAffineTransform = isSelected
        ? .identity.rotated(by: .pi - 0.001) // Gurantee valid direction for transform
        : .identity
        UIView.animate(
            withDuration: 0.25,
            animations: { [weak self] in
                self?.accessoryImageView.transform = transform
            }
        )
    }

    func setup(viewModel: AuthenticatorContentViewModel) {
        iconImageView.image = UIImage(named: viewModel.authenticator.service.iconName)?
            .withAlignmentRectInsets(.init(top: -8, left: -8, bottom: -8, right: -8))
        titleLabel.text = viewModel.authenticator.name
        descriptionLabel.text = viewModel.authenticator.email

        let contentView = AuthenticatorContentView()
        detailsView.addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(16)
        }
        contentView.setup(viewModel: viewModel)
        bindViewModel(viewModel: viewModel)
    }

     func setup(viewModel: CredentialsContentViewModel) {
         iconImageView.image = UIImage(named: viewModel.credentials.service.iconName)?
             .withAlignmentRectInsets(.init(top: -8, left: -8, bottom: -8, right: -8))
         titleLabel.text = viewModel.credentials.name
         descriptionLabel.text = viewModel.credentials.email

         let contentView = PasswordContentView()
         detailsView.addSubview(contentView)
         contentView.snp.makeConstraints {
             $0.edges.equalToSuperview().inset(16)
         }
         contentView.setup(viewModel: viewModel)
         bindViewModel(viewModel: viewModel)
     }


    private func bindViewModel(viewModel: AccordionViewModel) {
        rx.methodInvoked(#selector(UITableViewCell.setSelected(_:animated:)))
            .observe(on: MainScheduler.asyncInstance)
            .compactMap { [weak self] _ in self?.isSelected }
            .bind(to: viewModel.selectTrigger)
            .disposed(by: reuseBag)
    }
}
