//
//  LoggedInView.swift
//  TripJournal
//
//  Created by Jesus Guerra on 5/14/24.
//

import SwiftUI

struct LoggedInView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.journalService) private var journalService

    var body: some View {
        VStack {
            Text("You are logged in")
                .font(.title)
                .foregroundColor(.green)

            Button(action: {
                journalService.logOut()
            }) {
                Text("Logout")
                    .font(.headline)
                    .foregroundColor(.red)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
            }
        }
        .padding()
        .onChange(of: scenePhase) { _, newValue in
            if newValue == .active {
                checkSession()
            }
        }
    }

    // Ensure checkSession runs on the main thread
    func checkSession() {
        journalService.checkIfTokenExpired()
    }
}
