import RxCocoa
import RxSwift
import UIKit

final class OnboardingView: UIViewController {
    var viewModel: OnboardingViewModel!

    private var carouselLayout = UICollectionViewFlowLayout()
    private lazy var collectionView: UICollectionView = {
        let collectionVIew = UICollectionView(frame: .zero, collectionViewLayout: carouselLayout)
        return collectionVIew
    }()
    private let pageControl = UIPageControl()
    
    private let disposeBag = DisposeBag()
    
    //MARK: - VC LifeCycle
    override func loadView() {
        view = UIView()

        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        view.addSubview(pageControl)
        pageControl.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().scaledOffset(-145)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        bindViewModel()
    }
}

//MARK: - ViewModel Binding
private extension OnboardingView {
    
    func bindViewModel() {
        viewModel.didLoadTrigger.onNext(())
        
        viewModel.steps
            .map { $0.count }
            .drive(pageControl.rx.numberOfPages)
            .disposed(by: disposeBag)

        viewModel.currentPage
            .skip(1)
            .drive { [weak self] page in
                self?.pageControl.currentPage = page
                self?.collectionView.scrollToItem(
                    at: IndexPath(item: page, section: 0),
                    at: .centeredHorizontally,
                    animated: true
                )
            }
            .disposed(by: disposeBag)

        collectionView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        viewModel.steps
            .drive(collectionView.rx.items(
                cellIdentifier: OnboardingViewCell.reuseId,
                cellType: OnboardingViewCell.self)
            ) { [weak self] row, item, cell in
                guard let self else {
                    return
                }
                cell.setup(step: item)

                cell.rx.closeTrigger
                    .bind(to: self.viewModel.closeTrigger)
                    .disposed(by: cell.reuseBag)

                cell.rx.restoreTrigger
                    .bind(to: self.viewModel.restoreTrigger)
                    .disposed(by: cell.reuseBag)

                cell.rx.continueTrigger
                    .map { [weak self] in
                        self?.collectionView.indexPath(for: cell) ?? IndexPath()
                    }
                    .bind(to: self.viewModel.continueTrigger)
                    .disposed(by: cell.reuseBag)

                cell.rx.termsOfServiceTrigger
                    .bind(to: self.viewModel.termsOfServiceTrigger)
                    .disposed(by: cell.reuseBag)

                cell.rx.privacyPolicyTrigger
                    .bind(to: self.viewModel.privacyPolicyTrigger)
                    .disposed(by: cell.reuseBag)
            }
            .disposed(by: disposeBag)
    }
}

//MARK: - Configure UI
private extension OnboardingView {
    
    func setupUI() {
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = false
        collectionView.isScrollEnabled = false
        carouselLayout.scrollDirection = .horizontal
        collectionView.collectionViewLayout = carouselLayout
        collectionView.register(OnboardingViewCell.self, forCellWithReuseIdentifier: OnboardingViewCell.reuseId)
        
        pageControl.pageIndicatorTintColor = .silver
        pageControl.currentPageIndicatorTintColor = .cobalt
        pageControl.isUserInteractionEnabled = false
    }
}

extension OnboardingView: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return .init(top: 0, left: 0, bottom: 0, right: 0)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return .init(width: self.view.frame.width, height: self.view.frame.height)
    }
}
