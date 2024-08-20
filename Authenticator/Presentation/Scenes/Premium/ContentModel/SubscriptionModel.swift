import UIKit.UIImage

struct SubscriptionModel {
    enum SubscriptionItemType {
        case trial
        case weekly
        case monthly
        case yearly
    }

    let image: UIImage?
    let title: String
    let itemType: SubscriptionItemType
}
