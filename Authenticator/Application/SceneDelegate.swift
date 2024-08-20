//
//  SceneDelegate.swift
//  Authenticator
//
//  Created by Roman Knyukh Personal on 3/24/24.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene

        let appContext = AppContextImpl()
        if UserDefaultsStoreImpl().isOnboardingFinished {
            let dashboardBuilder = DashboardBuilderImpl(context: appContext)
            window?.rootViewController = dashboardBuilder.build()
        } else {
            let onboardingBuilder = OnboardingBuilderImpl(context: appContext)
            window?.rootViewController = onboardingBuilder.build()
        }
        window?.makeKeyAndVisible()
    }
}
