//
//  DataPayload.swift
//  Palimanan-maintenance-team
//
//  Created by Louis Mario Wijaya on 01/09/25.
//

import Foundation

struct DataPayload: Codable {
    let accessToken: String
    let tokenType: String
    let expiresIn: Int
    let user: User
}
