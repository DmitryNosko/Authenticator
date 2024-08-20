import RealmSwift

class AuthenticatorData: Object, Persistable {
    @Persisted(primaryKey: true) var uid: String
    @Persisted var name: String
    @Persisted var email: String
    @Persisted var secret: String
    @Persisted var serviceName: String?

    convenience init(
        uid: String,
        name: String,
        email: String,
        secret: String,
        serviceName: String?
    ) {
        self.init()

        self.uid = uid
        self.name = name
        self.email = email
        self.secret = secret
        self.serviceName = serviceName
    }

    func toDomain(service: Service?) -> Authenticator {
        return .init(
            uid: uid,
            name: name,
            email: email,
            secret: secret,
            service: service ?? .default
        )
    }

    static func from(authenticator: Authenticator) -> AuthenticatorData {
        return .init(
            uid: authenticator.uid,
            name: authenticator.name,
            email: authenticator.email,
            secret: authenticator.secret,
            serviceName: authenticator.service.serviceName
        )
    }
}
