//
//  SidebarMenu.swift
//  Palimanan-maintenance-team
//
//  Created by Syamsuddin Putra Riefli on 31/08/25.
//


enum SidebarMenu: Hashable {
    case dashboard(ForemanMenu)
    case programMingguan
    case programHarian(ForemanMenu)
}

enum ForemanMenu: Hashable {
    case lembah, bukit, danau
    
    var title: String {
        switch self {
        case .lembah: return "Lembah"
        case .bukit: return "Bukit"
        case .danau: return "Danau"
        }
    }
    
    var foremanId: Int {
        switch self {
        case .lembah: return 1
        case .bukit: return 2
        case .danau: return 3
        }
    }
    
    var holeRange: [Int] {
        switch self {
        case .lembah: return Array(1...9)
        case .bukit: return Array(10...18)
        case .danau: return Array(19...27)
        }
    }
    
    static func fromId(_ id: Int) -> ForemanMenu? {
        switch id {
        case 1: return .lembah
        case 2: return .bukit
        case 3: return .danau
        default: return nil
        }
    }
}
