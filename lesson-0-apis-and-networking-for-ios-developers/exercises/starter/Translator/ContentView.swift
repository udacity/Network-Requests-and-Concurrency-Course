//
//  ContentView.swift
//  Translator
//
//  Created by Mark DiFranco on 2024-05-15.
//

import SwiftUI

struct ContentView: View {
    @State private var textToTranslate = ""
    @State private var translatedText = ""

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
                .font(.largeTitle)

            TextField(
                "",
                text: $textToTranslate,
                prompt: Text("What would you like translated?")
            )
            .textFieldStyle(.roundedBorder)

            // Add UI to pick the "from" and "to" languages.

            Button("Translate", systemImage: "sparkles") {
                Task {
                    do {
                        try await performTranslation()
                    } catch {
                        print(error)
                    }
                }
            }
            .buttonStyle(.borderedProminent)

            Divider()

            Text(translatedText)
                .font(.title)
                .bold()
                .fontDesign(.rounded)
        }
        .padding()
    }
}

extension ContentView {

    func performTranslation() async throws {
        // Implement network request
    }
}

#Preview {
    ContentView()
}
