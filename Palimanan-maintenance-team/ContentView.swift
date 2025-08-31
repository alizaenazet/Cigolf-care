//
//  ContentView.swift
//  Palimanan-maintenance-team
//
//  Created by Ali zaenal on 28/08/25.
//

import SwiftUI

struct ContentView: View {
    @State private var selection: SidebarMenu? = nil
    @StateObject private var dashboardVM = DashboardViewModel()
    @StateObject private var dailyVM = DashboardViewModel()
    @State private var expandDashboard = true
    @State private var expandHarian = true
    
    var body: some View {
        NavigationSplitView {
            List(selection: $selection) {
                // MARK: Dashboard Dropdown
                DisclosureGroup(isExpanded: $expandDashboard) {
                    NavigationLink(value: SidebarMenu.dashboard(.lembah)) {
                        Label("Lembah", systemImage: "leaf")
                    }
                    NavigationLink(value: SidebarMenu.dashboard(.bukit)) {
                        Label("Bukit", systemImage: "mountain.2")
                    }
                    NavigationLink(value: SidebarMenu.dashboard(.danau)) {
                        Label("Danau", systemImage: "water.waves")
                    }
                } label: {
                    Label("Dashboard", systemImage: "rectangle.grid.2x2")
                }
                
                // MARK: Program Mingguan (standalone)
                NavigationLink(value: SidebarMenu.programMingguan) {
                    Label("Program Mingguan", systemImage: "calendar.badge.plus")
                }
                
                // MARK: Program Harian Dropdown
                DisclosureGroup(isExpanded: $expandHarian) {
                    NavigationLink(value: SidebarMenu.programHarian(.lembah)) {
                        Label("Lembah", systemImage: "leaf")
                    }
                    NavigationLink(value: SidebarMenu.programHarian(.bukit)) {
                        Label("Bukit", systemImage: "mountain.2")
                    }
                    NavigationLink(value: SidebarMenu.programHarian(.danau)) {
                        Label("Danau", systemImage: "water.waves")
                    }
                } label: {
                    Label("Program Harian", systemImage: "list.bullet.clipboard")
                }
            }
            .listStyle(.automatic)
            .navigationTitle("Menu")
            
        } detail: {
            switch selection {
            case .dashboard(let foreman):
                DashboardView(viewModel: dashboardVM, foremanId: foreman.foremanId)
                    .navigationTitle("Dashboard - \(foreman.title)")
                
            case .programMingguan:
                Text("Program Mingguan (coming soon)")
                    .font(.title2)
                    .foregroundColor(.gray)
                    .navigationTitle("Program Mingguan")
                
            case .programHarian(let foreman):
                DashboardView(viewModel: dailyVM, foremanId: foreman.foremanId)
                    .navigationTitle("Program Harian - \(foreman.title)")
                
            default:
                Text("Select a menu")
                    .foregroundStyle(.secondary)
            }
        }
    }
}


#Preview {
    ContentView()
}
