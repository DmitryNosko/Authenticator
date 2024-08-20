import RealmSwift

struct RealmStorageConfig {
    let namespace: String?
    let schemas: [Any.Type]

    static let `default`: Self = .init(namespace: nil, schemas: [])
    static let credentials: Self = .init(namespace: "credentials", schemas: [CredentialsData.self])
    static let authenticators: Self = .init(namespace: "authenticators", schemas: [AuthenticatorData.self])

    init(namespace: String?, schemas: [Any.Type]) {
        self.namespace = namespace
        self.schemas = schemas
    }
}

class RealmStorage<Value: Persistable> {
    private let realm: Realm?

    init(config: RealmStorageConfig = .default) {
        let realmConfig = Self.realmConfig(from: config)
        if let realm = try? Realm(configuration: realmConfig) {
            self.realm = realm
        } else {
            print("⚠️ Unable to open Realm! Config: \(config)")
            self.realm = nil
        }
    }

    func store(value: Value) {
        guard let realm = realm else {
            print("⚠️ Unable to store. Realm is not opened!")
            return
        }
        try? realm.write {
            realm.add(value)
        }
    }

    func update(uid: Value.UID, updateClosure: @escaping (Value) -> Void) {
        guard let realm = realm else {
            print("⚠️ Unable to update. Realm is not opened!")
            return
        }
        guard let storedObject = realm.object(ofType: Value.self, forPrimaryKey: uid) else {
            print("⚠️ Unable to update. Object not exists!")
            return
        }
        try? realm.write {
            updateClosure(storedObject)
        }
    }

    func fetch(uid: Value.UID) -> Value? {
        guard let realm = realm else {
            print("⚠️ Unable to fetch. Realm is not opened!")
            return nil
        }
        return realm.object(ofType: Value.self, forPrimaryKey: uid)
    }

    func fetchAll(predicate: NSPredicate = NSPredicate(value: true)) -> [Value] {
        guard let realm = realm else {
            print("⚠️ Unable to fetch. Realm is not opened!")
            return []
        }
        var result: [Value] = []
        for object in realm.objects(Value.self).filter(predicate) {
            result.append(object)
        }
        return result
    }

    func delete(uid: Value.UID) {
        guard let realm = realm else {
            print("⚠️ Unable to delete. Realm is not opened!")
            return
        }
        if let object = realm.object(ofType: Value.self, forPrimaryKey: uid) {
            try? realm.write {
                realm.delete(object)
            }
        }
    }

    @discardableResult
    public static func dropRealm(config: RealmStorageConfig) -> Bool {
       let realmConfig = realmConfig(from: config)
       return (try? Realm.deleteFiles(for: realmConfig)) ?? false
    }

    static func realmConfig(from config: RealmStorageConfig) -> Realm.Configuration {
        var realmConfig = Realm.Configuration.defaultConfiguration
        if let namespace = config.namespace {
            realmConfig.fileURL?.deleteLastPathComponent()
            realmConfig.fileURL?.appendPathComponent(namespace)
            realmConfig.fileURL?.appendPathExtension("realm")
        }
        if !config.schemas.isEmpty {
            realmConfig.objectTypes = config.schemas.compactMap { $0.self as? ObjectBase.Type }
        }
        #if DEBUG
        realmConfig.deleteRealmIfMigrationNeeded = true
        #endif
        return realmConfig
    }
}
