//
//  ForemenMapper.swift
//  Palimanan-maintenance-team
//
//  Created by Louis Mario Wijaya on 03/09/25.
//

import Foundation

enum ForemanMapper: Int {
    case darlene = 6
    case kelly = 7
    case joyce = 8
    
    var foremanId: Int {
        switch self {
        case .darlene: return 1
        case .kelly:   return 2
        case .joyce:   return 3
        }
    }
}
