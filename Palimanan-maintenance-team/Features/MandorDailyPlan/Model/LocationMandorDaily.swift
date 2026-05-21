//
//  Location.swift
//  Palimanan-maintenance-team
//
//  Created by Louis Mario Wijaya on 03/09/25.
//

import Foundation

struct LocationMandorDaily: Decodable, Identifiable {
    var id: Int { locationId }
    let locationId: Int
    let locationName: String
    let tasks: [TaskDetail]
}
