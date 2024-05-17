//
//  JSONDecoder+Constants.swift
//  Trip Journal
//
//  Created by Mark DiFranco on 2024-05-16.
//

import Foundation

extension JSONDecoder {
    static let main: JSONDecoder = {
        let decoder = JSONDecoder()

        decoder.keyDecodingStrategy = .convertFromSnakeCase

        return decoder
    }()
}
