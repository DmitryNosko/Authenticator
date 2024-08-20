import Foundation

struct Authenticator {
    let uid: String
    let name: String
    let email: String
    let secret: String
    let service: Service

    init(
        uid: String = UUID().uuidString,
        name: String,
        email: String,
        secret: String,
        service: Service
    ) {
        self.uid = uid
        self.name = name
        self.email = email
        self.secret = secret
        self.service = service
    }
}
