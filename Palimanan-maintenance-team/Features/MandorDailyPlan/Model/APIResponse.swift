//
//  MandorDailyPlansModel.swift
//  Palimanan-maintenance-team
//
//  Created by Louis Mario Wijaya on 03/09/25.
//

import Foundation

struct APIResponse<T: Decodable>: Decodable {
    let status: String
    let message: String
    let data: T?
}
