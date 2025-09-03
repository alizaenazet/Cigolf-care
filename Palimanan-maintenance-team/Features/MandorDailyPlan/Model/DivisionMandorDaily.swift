//
//  Division.swift
//  Palimanan-maintenance-team
//
//  Created by Louis Mario Wijaya on 03/09/25.
//

import Foundation

struct DivisionMandorDaily: Decodable, Identifiable {
    let id: Int
    let name: String
    let locations: [LocationMandorDaily]
}
