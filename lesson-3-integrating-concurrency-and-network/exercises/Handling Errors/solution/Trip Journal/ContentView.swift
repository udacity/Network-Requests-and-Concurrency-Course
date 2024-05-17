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

    @State private var isLoading = false

    @State private var isShowingSuccessAlert = false
    @State private var isShowingErrorAlert = false
    @State private var error: Error?

    var body: some View {
        Form {
            Section {
                TextField("", text: $username, prompt: Text("Username"))
                    .textContentType(.username)
                    .disabled(isLoading)
                TextField("", text: $password, prompt: Text("Password"))
                    .textContentType(.password)
                    .disabled(isLoading)
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
                        if isLoading {
                            ProgressView()
                        } else {
                            Text("Sign Up")
                                .bold()
                        }
                    })
                    .disabled(isLoading)

                    Spacer()
                }
            }
        }
        .alert("An Error Occurred", isPresented: $isShowingErrorAlert, presenting: error, actions: { _ in

        }, message: { error in
            Text(error.localizedDescription)
        })
        .alert("Account Created!", isPresented: $isShowingSuccessAlert) {

        } message: {
            Text("Your account has successfully been created!")
        }
    }
}

private extension ContentView {

    func registerUser() async {
        isLoading = true

        do {
            let url = URL(string: "http://localhost:8000/register")!
            var urlRequest = URLRequest(url: url)

            urlRequest.httpMethod = "POST"

            urlRequest.addValue("application/json", forHTTPHeaderField: "content-type")

            let requestObject = CreateUserRequest(
                usernames: username,
                password: password
            )

            let requestData = try JSONEncoder.main.encode(requestObject)

            urlRequest.httpBody = requestData

            let (data, _) = try await URLSession.shared.data(for: urlRequest)

            let responseObject = try JSONDecoder.main.decode(CreateUserResponse.self, from: data)

            if let detail = responseObject.detail {
                let error = NSError(
                    domain: "TripJournal",
                    code: 0,
                    userInfo: [
                        NSLocalizedDescriptionKey : detail
                    ]
                )
                throw error
            } else if let accessToken = responseObject.accessToken, !accessToken.isEmpty {
                isShowingSuccessAlert = true
            } else {
                let error = NSError(
                    domain: "TripJournal",
                    code: 0,
                    userInfo: [
                        NSLocalizedDescriptionKey : "An unknown error occurred. Please try again later."
                    ]
                )
                throw error
            }
        } catch {
            self.error = error
            self.isShowingErrorAlert = true
        }

        isLoading = false
    }
}

#Preview {
    ContentView()
}
