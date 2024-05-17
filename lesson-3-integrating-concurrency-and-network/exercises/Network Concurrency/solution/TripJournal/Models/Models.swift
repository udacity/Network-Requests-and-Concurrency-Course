import Foundation
import MapKit

/// Represents  the parameters to login the user
struct LoginRequest: Encodable {
    let username: String
    let password: String
}

/// Represents  a token that is returns when the user authenticates.
struct Token: Codable {
    let accessToken: String
    let tokenType: String
    var expirationDate: Date?

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case expirationDate
    }

    static func defaultExpirationDate() -> Date {
        let calendar = Calendar.current
        let currentDate = Date()
        return calendar.date(byAdding: .minute, value: 1, to: currentDate) ?? currentDate
    }
}

/// Represents a trip.
struct Trip: Identifiable, Sendable, Hashable, Decodable {
    var id: Int
    var name: String
    var startDate: Date
    var endDate: Date
    
    enum CodingKeys: String, CodingKey {
        case id, name
        case startDate = "start_date"
        case endDate = "end_date"
    }
}
