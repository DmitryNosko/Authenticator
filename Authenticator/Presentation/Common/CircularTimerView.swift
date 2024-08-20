import RxSwift
import UIKit

class CircularTimerView: UIView {
    var progressColors: [UIColor] = [.cobalt, .dodgerBlue]
    var progressTrackColor: UIColor? = .mercury

    var thresholdColors: [UIColor] = [.brightRed, .sunsetOrange]
    var thresholdTrackColor: UIColor? = .pippin

    var startingValue: Int = 30 {
        didSet {
            progressView.maxValue = startingValue
        }
    }
    var thresholdValue: Int = 5

    private let progressView = CircularProgressView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(progressView)
        progressView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(value: Int) {
        if value <= thresholdValue {
            progressView.trackColor = thresholdTrackColor
            progressView.progressColors = thresholdColors
            progressView.labelColors = thresholdColors
        } else {
            progressView.trackColor = progressTrackColor
            progressView.progressColors = progressColors
            progressView.labelColors = progressColors
        }
        progressView.update(value: value)
    }
}
