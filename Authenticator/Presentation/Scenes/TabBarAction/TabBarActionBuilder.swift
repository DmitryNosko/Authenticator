//
//  CreateSubjectBuilder.swift
//  Authenticator
//
//  Created by Roman Knyukh Personal on 3/26/24.
//

import UIKit

protocol TabBarActionBuilder {
    func build() -> UIViewController
}

final class TabBarActionBuilderImpl: TabBarActionBuilder {
    typealias Context = TabBarActionContainer 
        & ServiceDetailsContainer
        & ChooseIconContainer
        & QRScannerContainer

    private let context: Context

    init(context: Context) {
        self.context = context
    }

    func build() -> UIViewController {
        let view = TabBarActionView()
        let router = TabBarActionRouterImpl(
            view: view,
            addNewServiceInfoBuilder: ServiceDetailsBuilderImpl(context: context),
            qrScannerBuilder: QRScannerBuilderImpl(context: context)
        )
        let viewModel = TabBarActionViewModelImpl(router: router)
        view.viewModel = viewModel
        return view
    }
}
