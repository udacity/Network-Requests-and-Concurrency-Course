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
