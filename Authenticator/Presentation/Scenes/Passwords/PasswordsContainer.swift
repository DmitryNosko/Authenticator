protocol PasswordsContainer {
    var credentialsRepository: CredentialsRepository { get }
    var userDefaultsStore: UserDefaultsStore { get }
}
