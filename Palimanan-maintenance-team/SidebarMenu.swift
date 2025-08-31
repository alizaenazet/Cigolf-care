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
}
