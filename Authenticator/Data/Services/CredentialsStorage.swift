protocol CredentialsStorage {
    func store(credentials: CredentialsData)
    func delete(credentialsUid: String)
    func fetchAll() -> [CredentialsData]
}

final class CredentialsStorageImpl: CredentialsStorage {
    private let realmStorage: RealmStorage<CredentialsData>

    init(realmStorage: RealmStorage<CredentialsData> = .init(config: .credentials)) {
        self.realmStorage = realmStorage
    }

    func store(credentials: CredentialsData) {
        if realmStorage.fetch(uid: credentials.uid) == nil {
            realmStorage.store(value: credentials)
        } else {
            realmStorage.update(uid: credentials.uid, updateClosure: { storedData in
                storedData.name = credentials.name
                storedData.email = credentials.email
                storedData.password = credentials.password
                storedData.serviceName = credentials.serviceName
            })
        }
    }

    func delete(credentialsUid: String) {
        realmStorage.delete(uid: credentialsUid)
    }

    func fetchAll() -> [CredentialsData] {
        realmStorage.fetchAll()
    }
}
