import Foundation

struct Service: Codable {
    let serviceName: String
    let iconName: String

    private enum CodingKeys : String, CodingKey {
        case serviceName = "service_name"
        case iconName = "serivce_icon_name"
    }

    static let `default`: Self = .init(serviceName: "Default", iconName: "defaults_icon")
}
