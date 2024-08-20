protocol AuthenticatorStorage {
    func store(authenticator: AuthenticatorData)
    func delete(authenticatorUid: String)
    func fetchAll() -> [AuthenticatorData]
}

final class AuthenticatorStorageImpl: AuthenticatorStorage {
    private let realmStorage: RealmStorage<AuthenticatorData>

    init(realmStorage: RealmStorage<AuthenticatorData> = .init(config: .authenticators)) {
        self.realmStorage = realmStorage
    }

    func store(authenticator: AuthenticatorData) {
        if realmStorage.fetch(uid: authenticator.uid) == nil {
            realmStorage.store(value: authenticator)
        } else {
            realmStorage.update(uid: authenticator.uid, updateClosure: { storedData in
                storedData.name = authenticator.name
                storedData.email = authenticator.email
                storedData.secret = authenticator.secret
                storedData.serviceName = authenticator.serviceName
            })
        }
    }

    func delete(authenticatorUid: String) {
        realmStorage.delete(uid: authenticatorUid)
    }

    func fetchAll() -> [AuthenticatorData] {
        realmStorage.fetchAll()
    }
}
