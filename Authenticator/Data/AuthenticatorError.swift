enum AuthenticatorError: Error {
    case unrecognizedError

    case unableToDecodeSecret
    case unableToGenerateTOTP
}
