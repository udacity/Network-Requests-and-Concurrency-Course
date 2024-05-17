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
    @State private var fromLanguage = Language.english
    @State private var toLanguage = Language.spanish

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

            LabeledContent("From") {
                Picker("From", selection: $fromLanguage) {
                    ForEach(Language.allCases) { language in
                        Text(language.rawValue)
                            .tag(language)
                    }
                }
            }

            LabeledContent("To") {
                Picker("To", selection: $toLanguage) {
                    ForEach(Language.allCases) { language in
                        Text(language.rawValue)
                            .tag(language)
                    }
                }
            }

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
        guard !textToTranslate.isEmpty else { return }

        await MainActor.run {
            translatedText = ""
        }

        // URL
        let url = URL(string: "https://deep-translate1.p.rapidapi.com/language/translate/v2")!
        var urlRequest = URLRequest(url: url)

        // Headers
        urlRequest.setValue("application/json", forHTTPHeaderField: "content-type")
        urlRequest.setValue("f46be5a3c2msh5ed6e81a006d250p140fe6jsnfc72cd9799c6", forHTTPHeaderField: "X-RapidAPI-Key")

        // Method
        urlRequest.httpMethod = "POST"

        // Body
        let requestBody = TranslationRequest(
            q: textToTranslate,
            source: fromLanguage,
            target: toLanguage
        )

        // JSON Data
        let encoder = JSONEncoder()
        let data = try encoder.encode(requestBody)
        urlRequest.httpBody = data

        // Send Request
        let (responseData, _) = try await URLSession.shared.data(for: urlRequest)

        // Decode response
        let decoder = JSONDecoder()
        let response = try decoder.decode(TranslationResponse.self, from: responseData)

        // Update UI
        await MainActor.run {
            translatedText = response.data.translations.translatedText
        }
    }
}

#Preview {
    ContentView()
}
