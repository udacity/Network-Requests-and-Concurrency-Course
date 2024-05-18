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
            // Encode trips array into JSON data and save it to UserDefaults using tripsKey
        } catch {
            print("Failed to save trips to UserDefaults: \(error)")
        }
    }

    func loadTrips() -> [Trip] {
        // Retrieve data from UserDefaults using tripsKey; if no data is found, return an empty array

        do {
            // Retrieve data from UserDefaults using tripsKey; if no data is found, return an empty array

        } catch {
            print("Failed to load trips from UserDefaults: \(error)")
            return []
        }
    }
}
