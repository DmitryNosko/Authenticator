import Foundation

struct Credentials {
    let uid: String
    let name: String
    let email: String
    let password: String
    let service: Service

    init(
        uid: String = UUID().uuidString,
        name: String,
        email: String,
        password: String,
        service: Service
    ) {
        self.uid = uid
        self.name = name
        self.email = email
        self.password = password
        self.service = service
    }
}
