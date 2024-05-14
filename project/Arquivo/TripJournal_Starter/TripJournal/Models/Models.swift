import Foundation
import MapKit

/// Represents  the parameters to login the user
struct LoginRequest: Encodable {
    let username: String
    let password: String
}

/// Represents  a token that is returns when the user authenticates.
struct Token: Decodable {
    let accessToken: String
    let tokenType: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
    }
}

/// Represents a trip.
struct Trip: Identifiable, Sendable, Hashable, Decodable {
    var id: Int
    var name: String
    var startDate: Date
    var endDate: Date
    var events: [Event]
    
    enum CodingKeys: String, CodingKey {
        case id, name, events
        case startDate = "start_date"
        case endDate = "end_date"
    }
}

/// Represents an event in a trip.
struct Event: Identifiable, Sendable, Hashable, Codable {
    var id: Int
    var name: String
    var note: String?
    var date: Date
    var location: Location?
    var medias: [Media]
    var transitionFromPrevious: String?
}

/// Represents a location.
struct Location: Sendable, Hashable, Codable {
    var latitude: Double
    var longitude: Double
    var address: String?

    var coordinate: CLLocationCoordinate2D {
        return .init(latitude: latitude, longitude: longitude)
    }
}

/// Represents a media with a URL.
struct Media: Identifiable, Sendable, Hashable, Codable {
    var id: Int
    var url: URL?
}
