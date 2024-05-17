//
//  TranslationRequest.swift
//  Translator
//
//  Created by Mark DiFranco on 2024-05-15.
//

import Foundation

struct TranslationRequest: Codable {
    let q: String
    let source: Language
    let target: Language
}

enum Language: String, CaseIterable, Identifiable, Codable {
    case english = "en"
    case spanish = "es"
    case french = "fr"
    case german = "de"

    var id: String { rawValue }
}
