import Foundation

protocol UserDefaultsStore {
    var isOnboardingFinished: Bool { get set }
    var hasSubscription: Bool { get }
    var isBiometricEnabled: Bool { get }
}

class UserDefaultsStoreImpl: UserDefaultsStore {
    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    struct Key {
        static let isFirstLaunch = "isFirstLaunch"
        static let hasSubscription = "hasSubscription"
        static let isBiometricEnabled = "isBiometricEnabled"
    }

    var isOnboardingFinished: Bool {
        get {
            return userDefaults.bool(forKey: Key.isFirstLaunch)
        }
        set {
            userDefaults.setValue(newValue, forKey: Key.isFirstLaunch)
        }
    }

    var hasSubscription: Bool {
        get {
            return userDefaults.bool(forKey: Key.hasSubscription)
        }
        set {
            userDefaults.setValue(newValue, forKey: Key.hasSubscription)
        }
    }
    
    var isBiometricEnabled: Bool {
        get {
            return userDefaults.bool(forKey: Key.isBiometricEnabled)
        }
        set {
            userDefaults.setValue(newValue, forKey: Key.isBiometricEnabled)
        }
    }
}
