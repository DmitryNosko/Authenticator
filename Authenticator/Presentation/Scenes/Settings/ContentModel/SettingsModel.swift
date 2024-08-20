import UIKit.UIImage

struct SettingsModel {
    enum SettingsItemType {
        case subscriptions
        case support
        case privacyPolicy
        case termsOfUse
        case rateThisApp
        case share
    }

    let image: UIImage?
    let title: String
    let itemType: SettingsItemType
}
