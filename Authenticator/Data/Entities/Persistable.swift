import RealmSwift

protocol Persistable: Object {
    associatedtype UID

    var uid: UID { get }
}
