//
//  JSONEncoder+Constants.swift
//  Trip Journal
//
//  Created by Mark DiFranco on 2024-05-16.
//

import Foundation

extension JSONEncoder {
    static let main: JSONEncoder = {
        let encoder = JSONEncoder()

        encoder.keyEncodingStrategy = .convertToSnakeCase

        return encoder
    }()
}
