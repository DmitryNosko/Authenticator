import UIKit

protocol DashboardRouter {
    func showTabs()
    func showCreateSubject()
}

final class DashboardRouterImpl: DashboardRouter {
    private weak var view: UITabBarController?

    private let authenticatorBuilder: AuthenticatorBuilder
    private let passwordsBuilder: PasswordsBuilder
    private let tabBarActionBuilder: TabBarActionBuilder

    init(
        view: UITabBarController,
        authenticatorBuilder: AuthenticatorBuilder,
        passwordsBuilder: PasswordsBuilder,
        tabBarActionBuilder: TabBarActionBuilder
    ) {
        self.view = view
        self.authenticatorBuilder = authenticatorBuilder
        self.passwordsBuilder = passwordsBuilder
        self.tabBarActionBuilder  = tabBarActionBuilder
    }

    func showTabs() {
        let authenticatorView = authenticatorBuilder.build()
        let authenticatorNavigationView = UINavigationController(rootViewController: authenticatorView)
        authenticatorNavigationView.setNavigationBarHidden(true, animated: false)
        authenticatorView.tabBarItem.title = "Authenticator"
        authenticatorView.tabBarItem.image = UIImage(named: "authenticator_icon")

        let passwordsView = passwordsBuilder.build()
        let passwordsNavigationView = UINavigationController(rootViewController: passwordsView)
        passwordsNavigationView.setNavigationBarHidden(true, animated: false)
        passwordsView.tabBarItem.title = "Password"
        passwordsView.tabBarItem.image = UIImage(named: "password_icon")

        view?.viewControllers = [authenticatorNavigationView, passwordsNavigationView]
    }
    
    func showCreateSubject() {
        let tabBarActionView = tabBarActionBuilder.build()
        let tabbarActionNavigationView = UINavigationController(rootViewController: tabBarActionView)
        tabbarActionNavigationView.modalPresentationStyle = .overFullScreen
        view?.present(tabbarActionNavigationView, animated: true)
    }
}
