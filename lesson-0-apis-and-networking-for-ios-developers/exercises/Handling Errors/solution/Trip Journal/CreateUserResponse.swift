//
//  CreateUserResponse.swift
//  Trip Journal
//
//  Created by Mark DiFranco on 2024-05-16.
//

import Foundation

struct CreateUserResponse: Codable {
    let accessToken: String?
    let tokenType: String?
    let detail: String?
}
