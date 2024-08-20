import RxSwift
import SwiftOTP

// MARK: - Protocol

protocol AuthenticatorService {
    func oneTimePassword(
        authenticator: Authenticator,
        length: AuthenticatorPasswordLength,
        timeInterval: Int,
        algorithm: AuthenticatorAlgorithm
    ) -> Observable<Result<OneTimePassword, AuthenticatorError>>
}

// Default implementation
extension AuthenticatorService {
    func oneTimePassword(
        authenticator: Authenticator,
        length: AuthenticatorPasswordLength = .six,
        timeInterval: Int = 30,
        algorithm: AuthenticatorAlgorithm = .sha1
    ) -> Observable<Result<OneTimePassword, AuthenticatorError>> {
        return oneTimePassword(
            authenticator: authenticator,
            length: length,
            timeInterval: timeInterval,
            algorithm: algorithm
        )
    }
}

// MARK: - Implementation

class AuthenticatorServiceImpl: AuthenticatorService {
    func oneTimePassword(
        authenticator: Authenticator,
        length: AuthenticatorPasswordLength,
        timeInterval: Int,
        algorithm: AuthenticatorAlgorithm
    ) -> Observable<Result<OneTimePassword, AuthenticatorError>> {
        return .deferred {
            return Observable<Int>.interval(.milliseconds(500), scheduler: MainScheduler.instance)
                .startWith(0)
                .map { [weak self] _ -> Result<OneTimePassword, AuthenticatorError> in
                    guard let self = self else { return .failure(.unrecognizedError) }
                    return self.generateOneTimePassword(
                        secret: authenticator.secret,
                        length: length,
                        timeInterval: timeInterval,
                        algorithm: algorithm
                    )
                }
                .distinctUntilChanged()
        }
    }

    private func generateOneTimePassword(
        secret: String,
        length: AuthenticatorPasswordLength,
        timeInterval: Int,
        algorithm: AuthenticatorAlgorithm
    ) -> Result<OneTimePassword, AuthenticatorError> {
        guard let secretData = base32DecodeToData(secret) else {
            return .failure(.unableToDecodeSecret)
        }
        let totpData = TOTP(
            secret: secretData,
            digits: length.rawValue,
            timeInterval: timeInterval,
            algorithm: algorithm.mapToOTPAlgorithm()
        )
        let now = Date()
        let secondsPast1970 = Int(floor(now.timeIntervalSince1970))
        let expirationInSeconds = timeInterval - (secondsPast1970 % timeInterval)
        if let totp = totpData?.generate(time: Date()) {
            return .success(.init(code: totp, expirationInSeconds: expirationInSeconds))
        } else {
            return .failure(.unableToGenerateTOTP)
        }
    }
}
