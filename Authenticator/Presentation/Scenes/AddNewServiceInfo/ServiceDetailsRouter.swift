import UIKit
import RxSwift

enum FlowResult<Value> {
    case finished(Value)
    case cancelled
}

typealias SimpleFlowResult = FlowResult<Void>

extension FlowResult where Value == Void {
    static var finished: Self = .finished(())
}

protocol ServiceDetailsRouter {
    func dissmis()
    func showSelectIcon() -> Single<FlowResult<Service>>
}

final class ServiceDetailsRouterImpl: ServiceDetailsRouter {
    private weak var view: UIViewController?
    private let chooseIconBuilder: ChooseIconBuilder

    init(view: UIViewController, chooseIconBuilder: ChooseIconBuilder) {
        self.view = view
        self.chooseIconBuilder = chooseIconBuilder
    }

    func dissmis() {
        self.view?.dismiss(animated: true)
    }

    func showSelectIcon() -> Single<FlowResult<Service>> {
        return .create { [weak self] single in
            guard let self else { return Disposables.create() }
            let chooseIconView = chooseIconBuilder.build(
                onFinish: { service in
                    single(.success(.finished(service)))
                },
                onCancel: {
                    single(.success(.cancelled))
                }
            )

            view?.navigationController?.pushViewController(chooseIconView, animated: true)

            return Disposables.create()
        }
    }
}
