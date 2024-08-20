import AVFoundation
import RxCocoa
import RxSwift

final class RxAVCaptureMetadataOutputObjectsDelegateProxy:
    DelegateProxy<AVCaptureMetadataOutput, AVCaptureMetadataOutputObjectsDelegate>, DelegateProxyType, AVCaptureMetadataOutputObjectsDelegate
{
    private weak var metadataOutput: AVCaptureMetadataOutput?

    init(metadataOutput: AVCaptureMetadataOutput) {
        self.metadataOutput = metadataOutput
        super.init(parentObject: metadataOutput, delegateProxy: RxAVCaptureMetadataOutputObjectsDelegateProxy.self)
    }

    static func registerKnownImplementations() {
        self.register { RxAVCaptureMetadataOutputObjectsDelegateProxy(metadataOutput: $0) }
    }

    static func currentDelegate(for object: AVCaptureMetadataOutput) -> AVCaptureMetadataOutputObjectsDelegate? {
        return object.metadataObjectsDelegate
    }

    static func setCurrentDelegate(
        _ delegate: AVCaptureMetadataOutputObjectsDelegate?,
        to object: AVCaptureMetadataOutput
    ) {
        object.setMetadataObjectsDelegate(delegate, queue: DispatchQueue.main)
    }

    // MARK: - AVCaptureMetadataOutputObjectsDelegate implementation

    fileprivate let didOutputMetadataObjectsSubject = BehaviorSubject<[AVMetadataObject]>(value: [])

    func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        didOutputMetadataObjectsSubject.onNext(metadataObjects)
    }
}

// MARK: - Reactive implmentation

extension Reactive where Base: AVCaptureMetadataOutput {
    var metadataObjects: Observable<[AVMetadataObject]> {
        return RxAVCaptureMetadataOutputObjectsDelegateProxy.proxy(for: base)
            .didOutputMetadataObjectsSubject
            .asObservable()
    }
}
