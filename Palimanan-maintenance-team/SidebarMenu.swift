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
        case .danau: return "Danau"
        case .bukit: return "Bukit"
        }
    }
    
    var foremanId: Int {
        switch self {
        case .lembah: return 1
        case .danau: return 2
        case .bukit: return 3
        }
    }
    
    static func fromId(_ id: Int) -> ForemanMenu? {
        switch id {
        case 1: return .lembah
        case 2: return .danau
        case 3: return .bukit
        default: return nil
        }
    }
}
