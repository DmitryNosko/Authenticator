import RealmSwift

class CredentialsData: Object, Persistable {
    @Persisted(primaryKey: true) var uid: String
    @Persisted var name: String
    @Persisted var email: String
    @Persisted var password: String
    @Persisted var serviceName: String?

    convenience init(
        uid: String,
        name: String,
        email: String,
        password: String,
        serviceName: String?
    ) {
        self.init()

        self.uid = uid
        self.name = name
        self.email = email
        self.password = password
        self.serviceName = serviceName
    }

    func toDomain(service: Service?) -> Credentials {
        return .init(
            uid: uid,
            name: name,
            email: email,
            password: password,
            service: service ?? .default
        )
    }

    static func from(credentials: Credentials) -> CredentialsData {
        return .init(
            uid: credentials.uid,
            name: credentials.name,
            email: credentials.email,
            password: credentials.password,
            serviceName: credentials.service.serviceName
        )
    }
}
