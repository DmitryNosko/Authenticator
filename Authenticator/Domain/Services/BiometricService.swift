import LocalAuthentication
import UIKit

enum BiometricType: String {
    case FaceID = "Face ID"
    case TouchID = "Touch ID"
}

protocol BiometricService {
    func setBiometricEnabled(_ isEnabled: Bool)
    func isBiometricEnabled() -> Bool
    func getBiometricType() -> BiometricType
    func authenticateWithBiometrics(completion: @escaping (Bool, Error?) -> Void)
}

class BiometricServiceImpl: BiometricService {
    private let userDefaults = UserDefaultsStoreImpl()
    
    init() {}
    
    func setBiometricEnabled(_ isEnabled: Bool) {
        userDefaults.isBiometricEnabled = isEnabled
    }
    
    func isBiometricEnabled() -> Bool {
        userDefaults.isBiometricEnabled
    }
    
    func getBiometricType() -> BiometricType {
        return canUseBiometricAuthentication() ? .FaceID : .TouchID
    }
    
    func authenticateWithBiometrics(completion: @escaping (Bool, Error?) -> Void) {
        let context = LAContext()
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Authenticate using Face ID or Touch ID") { success, error in
            DispatchQueue.main.async {
                completion(success, error)
            }
        }
    }
}

private extension BiometricServiceImpl {
    
    func canUseBiometricAuthentication() -> Bool {
        let context = LAContext()
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }
}

