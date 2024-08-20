import UIKit
import MessageUI
import StoreKit

protocol SettingsRouter {
    func dismiss()
    func showPremium()
    func showContactUsScreen(applicationSupportEmail: String, subject: String, body: String, emailURL: URL?)
    func showSafari(with urlString: String)
    func showReviewView()
    func showShareWithFriends(applicationLink: String)
    func showBiometricsSettingsAlert()
}

final class SettingsRouterImpl: SettingsRouter {
    private weak var view: UIViewController?
    private let settingsSupportUIDelegate = SettingsSupportUIDelegate()
    private let premiumBuilder: PremiumBuilder

    init(
        view: UIViewController,
        premiumBuilder: PremiumBuilder
    ) {
        self.view = view
        self.premiumBuilder = premiumBuilder
    }

    func dismiss() {
        self.view?.dismiss(animated: true)
    }
    
    func showPremium() {
        let premiumView = premiumBuilder.build()
        premiumView.modalPresentationStyle = .fullScreen
        premiumView.modalTransitionStyle = .flipHorizontal
        view?.present(premiumView, animated: true)
    }
    
    func showContactUsScreen(applicationSupportEmail: String, subject: String, body: String, emailURL: URL?) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = settingsSupportUIDelegate
            mail.setToRecipients([applicationSupportEmail])
            mail.setSubject(subject)
            mail.setMessageBody(body, isHTML: false)
            self.view?.present(mail, animated: true)
        } else if let emailUrl = emailURL {
            UIApplication.shared.open(emailUrl)
        }
    }
    
    func showSafari(with urlString: String) {
        guard let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) else {
            return
        }
        UIApplication.shared.open(url)
    }

    func showReviewView() {
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
    
    func showShareWithFriends(applicationLink: String) {
        let activityViewController = UIActivityViewController(activityItems: [applicationLink] , applicationActivities: nil)
        self.view?.present(activityViewController, animated: true)
    }
    
    func showBiometricsSettingsAlert() {
        let alertController = UIAlertController(
            title: "Enable Face ID/Touch ID",
            message: "To use biometric authentication, you need to enable Face ID/Touch ID for this app in your device settings.",
            preferredStyle: .alert
        )
        let settingsAction = UIAlertAction(title: "Go to Settings", style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
            }
        }
        alertController.addAction(settingsAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        self.view?.present(alertController, animated: true, completion: nil)
    }
}
