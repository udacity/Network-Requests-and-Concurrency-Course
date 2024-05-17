//
//  ContentView.swift
//  Trip Journal
//
//  Created by Mark DiFranco on 2024-05-16.
//

import SwiftUI

@MainActor
struct ContentView: View {
    
    @State private var username = ""
    @State private var password = ""

    var body: some View {
        Form {
            Section {
                TextField("", text: $username, prompt: Text("Username"))
                    .textContentType(.username)
                TextField("", text: $password, prompt: Text("Password"))
                    .textContentType(.password)
            } header: {
                CreateUserHeaderView()
            }

            Section {
                HStack {
                    Spacer()

                    Button(action: {
                        Task {
                            await registerUser()
                        }
                    }, label: {
                        Text("Sign Up")
                            .bold()
                    })

                    Spacer()
                }
            }
        }
    }
}

private extension ContentView {

    func registerUser() async {
        // Implement request to register a new user.
    }
}

#Preview {
    ContentView()
}
