protocol ServiceDetailsContainer {
    var userDefaultsStore: UserDefaultsStore { get }
    var authenticatorsRepository: AuthenticatorsRepository { get }
    var credentialsRepository: CredentialsRepository { get }
}
