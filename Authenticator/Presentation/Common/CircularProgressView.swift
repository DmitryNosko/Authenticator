import UIKit

class VerticalyCenteredTextLayer: CATextLayer {
    override func draw(in ctx: CGContext) {
        let verticalOffset = (bounds.size.height - fontSize) / 2 - fontSize / 10

        ctx.saveGState()
        ctx.translateBy(x: 0, y: verticalOffset)
        super.draw(in: ctx)
        ctx.restoreGState()
    }
}

class CircularProgressView: UIControl {
    private let textLayer = VerticalyCenteredTextLayer()
    private let labelGradientLayer = CAGradientLayer()
    private let trackLayer = CAShapeLayer()
    private let progressLayer = CAShapeLayer()
    private let progressGradientLayer = CAGradientLayer()

    var trackColor: UIColor? = .lightGray {
        didSet {
            trackLayer.strokeColor = trackColor?.cgColor
        }
    }

    var progressColors: [UIColor] = [.black] {
        didSet {
            progressLayer.strokeColor = UIColor.black.cgColor
            progressGradientLayer.colors = progressColors.map { $0.cgColor }
        }
    }

    var labelColors: [UIColor] = [.black] {
        didSet {
            labelGradientLayer.colors = labelColors.map { $0.cgColor }
        }
    }

    var maxValue: Int = 30

    private var viewPath: UIBezierPath {
        return UIBezierPath(
            arcCenter: CGPoint(x: frame.size.width / 2, y: frame.size.height / 2),
            radius: (frame.size.width - 7) / 2,
            startAngle: CGFloat(1.5 * Double.pi),
            endAngle: CGFloat(-0.5 * Double.pi),
            clockwise: false
        )
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        layer.addSublayer(trackLayer)
        layer.addSublayer(progressGradientLayer)
        progressGradientLayer.mask = progressLayer
        progressLayer.lineCap = .round

        layer.addSublayer(labelGradientLayer)
        labelGradientLayer.mask = textLayer
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        drawLayers()

        progressGradientLayer.frame = bounds
        progressGradientLayer.startPoint = .zero
        progressGradientLayer.endPoint = .init(x: 1.0, y: 1.0)

        labelGradientLayer.frame = bounds
        labelGradientLayer.startPoint = .zero
        labelGradientLayer.endPoint = .init(x: 1.0, y: 1.0)

        textLayer.frame = bounds
        textLayer.fontSize = 16
        textLayer.font = UIFont.outfit(ofSize: 16, weight: .semibold)
        textLayer.alignmentMode = .center
        textLayer.contentsScale = UIScreen.main.scale
    }

    private func drawLayers() {
        apply(path: viewPath, toLayer: trackLayer, lineWidth: 7)
        apply(path: viewPath, toLayer: progressLayer, lineWidth: 7)
    }

    private func apply(
        path: UIBezierPath,
        toLayer layer: CAShapeLayer,
        lineWidth: CGFloat
    ) {
        layer.path = path.cgPath
        layer.fillColor = UIColor.clear.cgColor
        layer.lineWidth = lineWidth
    }

    func update(value: Int) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        textLayer.string = "\(value)"
        CATransaction.commit()

        let progress = CGFloat(value) / CGFloat(maxValue)
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = 0.25
        animation.fromValue = progressLayer.strokeEnd
        animation.toValue = progress
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)

        progressLayer.strokeEnd = progress
        progressLayer.add(animation, forKey: "animatedProgress")

        sendActions(for: .valueChanged)
    }
}
