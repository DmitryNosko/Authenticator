import UIKit
import RxSwift
import RxCocoa
import AVFoundation

final class QRScannerView: UIViewController {
    var viewModel: QRScannerViewModel!
    private let captureSession = AVCaptureSession()
    private let metadataOutput = AVCaptureMetadataOutput()

    private let disposeBag = DisposeBag()

    private lazy var scannerOverlayPreviewLayer: ScannerOverlayLayer = {
         var scanner = ScannerOverlayLayer(session: captureSession)
          scanner.frame = view.bounds
          scanner.cornerRadius = 22
          scanner.videoGravity = .resizeAspectFill
          return scanner
    }()

    private let titleLabel = UILabel()
    private var scannerView = UIView()
    private let descriptionLabel = UILabel()
    private let closeButton = UIButton(frame: .zero)

    override func loadView() {
        super.loadView()

        view.addSubview(scannerView)
        view.addSubview(titleLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(closeButton)

        scannerView.snp.makeConstraints {
            $0.edges.equalTo(view)
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().scaledOffset(50)
            $0.centerX.equalToSuperview()
            $0.height.equalToScaledValue(24)
        }

        closeButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide).scaledOffset(-14)
            $0.height.width.equalToScaledValue(72)
        }

        descriptionLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().scaledOffset(16)
            $0.trailing.equalToSuperview().scaledOffset(-16)
            $0.bottom.equalTo(closeButton.snp.top).scaledOffset(-147)
            $0.centerX.equalToSuperview()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        bindViewModel()
    }

    private func bindViewModel() {
        closeButton.rx.tap
            .bind(to: viewModel.closeTrigger)
            .disposed(by: disposeBag)
        rx.methodInvoked(#selector(UIViewController.viewWillAppear(_:)))
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .subscribe(onNext: { [weak self] _ in
                self?.captureSession.startRunning()
            })
            .disposed(by: disposeBag)
        metadataOutput.rx.metadataObjects
            .map { $0.compactMap { ($0 as? AVMetadataMachineReadableCodeObject)?.stringValue }.first }
            .bind(to: viewModel.scanTrigger)
            .disposed(by: disposeBag)
    }

    private func setupUI() {
        configureScanner()

        with(titleLabel) {
            $0.font = .outfit(ofSize: 20, weight: .medium)
            $0.textColor = .white
            $0.text = "Scan"
        }

        with(descriptionLabel) {
            $0.text = """
            Point your camera
            at the qr code
            """
            $0.textColor = .white
            $0.font = .outfit(ofSize: 20,weight: .semibold)
            $0.textAlignment = .center
            $0.numberOfLines = 0
        }

        with(closeButton) {
            $0.layer.masksToBounds = true
            $0.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            $0.setImage(UIImage(systemName: "xmark")?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
        }

        with(scannerView) {
            $0.layer.insertSublayer(scannerOverlayPreviewLayer, at: 0)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        closeButton.layer.cornerRadius = closeButton.frame.height / 2
    }

    func configureScanner() {
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            return
        }

        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }

        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            return
        }

        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            return
        }
    }
}
