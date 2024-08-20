import UIKit

extension UIFont {
    static func customFont(name: String, ofSize size: CGFloat, weight: UIFont.Weight) -> UIFont? {
        if let customFont = UIFont(name: "\(name)-\(mapWeightToString(weight))", size: size) {
            return customFont
        } else if let customFont = UIFont(name: "\(name)-\(mapWeightToString(.regular))", size: size) {
            print("⚠️ Unable to find \(name) font with \(weight) weight. Falling back to `.regular`!")
            return customFont
        } else {
            print("⚠️ Unable to find \(name) font!")
            return nil
        }
    }

    static func outfit(ofSize size: CGFloat, weight: UIFont.Weight = .regular) -> UIFont? {
        return customFont(name: "Outfit", ofSize: size, weight: weight)
    }

    private static func mapWeightToString(_ weight: UIFont.Weight) -> String {
        switch weight {
        case .black:
            return "Black"
        case .bold:
            return "Bold"
        case .heavy:
            return "Heavy"
        case .light:
            return "Light"
        case .medium:
            return "Medium"
        case .regular:
            return "Regular"
        case .semibold:
            return "SemiBold"
        case .thin:
            return "Thin"
        case .ultraLight:
            return "UltraLight"
        default:
            print("⚠️ Unexpected weight: \(weight). Falling back to `.regular`!")
            return mapWeightToString(.regular)
        }
    }
}
