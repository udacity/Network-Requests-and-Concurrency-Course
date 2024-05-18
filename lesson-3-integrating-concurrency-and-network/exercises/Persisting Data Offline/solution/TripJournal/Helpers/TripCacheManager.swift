//
//  TripCacheManager.swift
//  TripJournal
//
//  Created by Jesus Guerra on 5/18/24.
//

import Foundation

class TripCacheManager {
    private let userDefaults = UserDefaults.standard
    private let tripsKey = "trips"

    func saveTrips(_ trips: [Trip]) {
        do {
            let data = try JSONEncoder().encode(trips)
            userDefaults.set(data, forKey: tripsKey)
        } catch {
            print("Failed to save trips to UserDefaults: \(error)")
        }
    }

    func loadTrips() -> [Trip] {
        guard let data = userDefaults.data(forKey: tripsKey) else {
            return []
        }
        do {
            return try JSONDecoder().decode([Trip].self, from: data)
        } catch {
            return []
        }
    }
}
