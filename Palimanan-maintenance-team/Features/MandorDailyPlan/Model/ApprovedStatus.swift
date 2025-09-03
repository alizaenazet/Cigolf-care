//
//  ApprovedStatus.swift
//  Palimanan-maintenance-team
//
//  Created by Louis Mario Wijaya on 03/09/25.
//

import Foundation

struct ApprovedStatus: Decodable {
    let isApproved: Bool
    let approvedAt: String?
    let spvName: String?
}
