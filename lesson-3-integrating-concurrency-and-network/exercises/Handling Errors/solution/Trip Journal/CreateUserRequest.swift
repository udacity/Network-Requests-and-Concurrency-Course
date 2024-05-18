//
//  CreateUserRequest.swift
//  Trip Journal
//
//  Created by Mark DiFranco on 2024-05-16.
//

import Foundation

struct CreateUserRequest: Codable {
    let username: String
    let password: String
}
