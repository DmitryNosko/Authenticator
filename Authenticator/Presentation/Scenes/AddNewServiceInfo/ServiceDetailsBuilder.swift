//
//  CreateNewBuilder.swift
//  Authenticator
//
//  Created by Roman Knyukh Personal on 3/26/24.
//

import UIKit

enum ServiceType {
    case authenticator(String, String)
    case password(String, String)
}

protocol ServiceDetailsBuilder {
    func build(_ type: ServiceType, serviceDetailsModel: ServiceDetailsModel) -> UIViewController
}

extension ServiceDetailsBuilder {
    func build(
        _ type: ServiceType,
        serviceDetailsModel: ServiceDetailsModel = ServiceDetailsModel.empty
    ) -> UIViewController
    {
        return build(type, serviceDetailsModel: serviceDetailsModel)
    }
}

final class ServiceDetailsBuilderImpl: ServiceDetailsBuilder {
    typealias Context = ServiceDetailsContainer & ChooseIconContainer

    private let context: Context

    init(context: Context) {
        self.context = context
    }

    func build(_ type: ServiceType, serviceDetailsModel: ServiceDetailsModel) -> UIViewController {
        let view = ServiceDetailsView()
        let router = ServiceDetailsRouterImpl(view: view, chooseIconBuilder: ChooseIconBuilderImpl(context: context))
        let viewModel = ServiceDetailsViewModelImpl(
            router: router,
            serviceType: type,
            authenticatorsRepository: context.authenticatorsRepository,
            credentialsRepository: context.credentialsRepository,
            serviceDetailsModel: serviceDetailsModel
        )
        view.viewModel = viewModel

        return view
    }
}
