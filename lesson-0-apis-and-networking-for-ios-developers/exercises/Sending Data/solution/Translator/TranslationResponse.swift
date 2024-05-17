//
//  TranslationResponse.swift
//  Translator
//
//  Created by Mark DiFranco on 2024-05-15.
//

import Foundation

struct TranslationResponse: Codable {
    let data: Data
}

struct Data: Codable {
    let translations: Translations
}

struct Translations: Codable {
    let translatedText: String
}
