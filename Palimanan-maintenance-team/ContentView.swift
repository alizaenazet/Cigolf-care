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
    
    init(
        dashboardVM: DashboardViewModel? = nil,
        dailyVM: DashboardViewModel? = nil
    ) {
        _dashboardVM = StateObject(wrappedValue: dashboardVM ?? DashboardViewModel())
        _dailyVM = StateObject(wrappedValue: dailyVM ?? DashboardViewModel())
    }
    
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
    var mockReport = ForemanReport(
        id: 1,
        createdAt: "28-08-2025",
        approved: Approval(
            isApproved: false,
            approvedAt: "28-08-2025",
            spvName: "Sal Priadi"
        ),
        outsourceCompany: "PT. Yobel Perkasa",
        foremanName: "Agus Gunandar",
        totalTasks: 2,
        finishedTasks: 1,
        pendingTasks: 1,
        divisions: [
            Division(
                id: 1,
                name: "Operasional",
                locations: [
                    Location(
                        locationId: 1,
                        locationName: "Green",
                        tasks: [
                            TaskItem(
                                id: 301,
                                taskType: "Verticut green",
                                description: "Potong model cepak",
                                priority: "P2",
                                area: "Hole 1, Hole 2, Villa",
                                needWorker: 3,
                                availableWorker: 3,
                                workerList: "Yobel, Mar, Vick",
                                urlPhoto: "",
                                isFinished: false
                            ),
                            TaskItem(
                                id: 302,
                                taskType: "Pupuk granular green",
                                description: "Pupuk cap cip cup",
                                priority: "P1",
                                area: "Hole 9",
                                needWorker: 1,
                                availableWorker: 1,
                                workerList: "Yobel",
                                urlPhoto: "/eijsd.png",
                                isFinished: true
                            )
                        ]
                    ),
                    Location(
                        locationId: 2,
                        locationName: "Teebox",
                        tasks: [
                            TaskItem(
                                id: 301,
                                taskType: "Verticut green",
                                description: "Potong model cepak",
                                priority: "P2",
                                area: "Hole 1, Hole 2, Villa",
                                needWorker: 3,
                                availableWorker: 3,
                                workerList: "Yobel, Mar, Vick",
                                urlPhoto: "",
                                isFinished: false
                            ),
                            TaskItem(
                                id: 302,
                                taskType: "Pupuk granular green",
                                description: "Pupuk cap cip cup",
                                priority: "P1",
                                area: "Hole 9",
                                needWorker: 1,
                                availableWorker: 1,
                                workerList: "Yobel",
                                urlPhoto: "/eijsd.png",
                                isFinished: true
                            )
                        ]
                    )
                ]
            ),
            Division(
                id: 2,
                name: "Landscape",
                locations: [
                    Location(
                        locationId: 1,
                        locationName: "Green",
                        tasks: [
                            TaskItem(
                                id: 401,
                                taskType: "Verticut green 2",
                                description: "Potong model cepak",
                                priority: "P2",
                                area: "Hole 1, Hole 2, Villa",
                                needWorker: 3,
                                availableWorker: 3,
                                workerList: "Yobel, Mar, Vick",
                                urlPhoto: "",
                                isFinished: false
                            ),
                            TaskItem(
                                id: 402,
                                taskType: "Pupuk granular green",
                                description: "Pupuk cap cip cup",
                                priority: "P1",
                                area: "Hole 9",
                                needWorker: 1,
                                availableWorker: 1,
                                workerList: "Yobel",
                                urlPhoto: "https://cdn.donmai.us/original/25/eb/25eb7f80ba5476d96068a3ccc8e17ab3.png",
                                isFinished: true
                            )
                        ]
                    )
                ]
            )
        ]
    )
    
    // Inject mock data into the VM
    let mockVM = DashboardViewModel()
    mockVM.report = mockReport
    
    return ContentView(dashboardVM: mockVM, dailyVM: mockVM)
}
