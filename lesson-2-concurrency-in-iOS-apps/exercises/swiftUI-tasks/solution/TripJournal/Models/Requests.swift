import Foundation

/// An object that can be used to create a new trip.
struct TripCreate: Codable {
    let name: String
    let startDate: Date
    let endDate: Date
}

/// An object that can be used to update an existing trip.
struct TripUpdate: Codable {
    let name: String
    let startDate: Date
    let endDate: Date
}
