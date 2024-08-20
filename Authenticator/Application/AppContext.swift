typealias AppContext = DashboardContainer
    & AuthenticatorContainer
    & PasswordsContainer
    & ServiceDetailsContainer
    & TabBarActionContainer
    & SettingsContainer
    & PremiumContainer
    & ChooseIconContainer
    & QRScannerContainer
    & DeleteAlertContainer
    & OnboardingContainer

final class AppContextImpl: AppContext {
    let servicesRepository: ServicesRepository
    let authenticatorsRepository: AuthenticatorsRepository
    let credentialsRepository: CredentialsRepository
    let authenticatorService: AuthenticatorService
    let userDefaultsStore: UserDefaultsStore
    let biometricService: BiometricService

    init() {
        servicesRepository = ServicesRepositoryImpl()
        let authenticatorStorage = AuthenticatorStorageImpl()
        authenticatorsRepository = AuthenticatorsRepositoryImpl(
            authenticatorStorage: authenticatorStorage,
            servicesRepository: servicesRepository
        )
        let credentialsStorage = CredentialsStorageImpl()
        credentialsRepository = CredentialsRepositoryImpl(
            credentialsStorage: credentialsStorage,
            servicesRepository: servicesRepository
        )
        authenticatorService = AuthenticatorServiceImpl()
        userDefaultsStore = UserDefaultsStoreImpl()
        biometricService = BiometricServiceImpl()
    }
}
