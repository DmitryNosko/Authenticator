import SwiftOTP

enum AuthenticatorAlgorithm {
    case sha1
    case sha256
    case sha512
}

extension AuthenticatorAlgorithm {
    func mapToOTPAlgorithm() -> OTPAlgorithm {
        switch self {
        case .sha1:
            return .sha1
        case .sha256:
            return .sha256
        case .sha512:
            return .sha512
        }
    }
}
