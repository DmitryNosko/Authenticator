protocol AuthenticatorContainer {
    var authenticatorsRepository: AuthenticatorsRepository { get }
    var authenticatorService: AuthenticatorService { get }
    var userDefaultsStore: UserDefaultsStore { get }
}
