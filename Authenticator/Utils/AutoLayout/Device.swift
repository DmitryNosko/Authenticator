import Foundation

enum Device {
    case iPhoneSE
    case iPhone8Plus
    case iPhone11, iPhoneXR
    case iPhone11Pro
    case iPhone11ProMax
    case iPhone13mini
    case iPhone14, iPhone13
    case iPhone14Plus, iPhone13ProMax
    case iPhone15, iPhone15Pro, iPhone14Pro
    case iPhone15Plus, iPhone15ProMax, iPhone14ProMax
    
    static let baseDevice: Device = .iPhone13mini
    
    var screenSize: CGSize {
        switch self {
        case .iPhoneSE:
            return CGSize(width: 375, height: 667)
        case .iPhone8Plus:
            return CGSize(width: 414, height: 736)
        case .iPhone11, .iPhoneXR:
            return CGSize(width: 414, height: 896)
        case .iPhone11Pro:
            return CGSize(width: 375, height: 812)
        case .iPhone11ProMax:
            return CGSize(width: 414, height: 896)
        case .iPhone13mini:
            return CGSize(width: 375, height: 812)
        case .iPhone14,.iPhone13:
            return CGSize(width: 390, height: 844)
        case .iPhone14Plus, .iPhone13ProMax:
            return CGSize(width: 428, height: 926)
        case .iPhone15, .iPhone15Pro, .iPhone14Pro:
            return CGSize(width: 393, height: 852)
        case .iPhone15Plus, .iPhone15ProMax, .iPhone14ProMax:
            return CGSize(width: 430, height: 932)
        }
    }
}
