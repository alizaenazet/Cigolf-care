//
//  LoginResponse.swift
//  Palimanan-maintenance-team
//
//  Created by Louis Mario Wijaya on 01/09/25.
//

import Foundation

struct LoginResponse: Codable {
    let status: String
    let message: String
    let data: DataPayload
}
