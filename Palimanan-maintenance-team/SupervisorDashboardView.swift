//
//  SupervisorDashboardView.swift
//  Palimanan-maintenance-team
//
//  Created by Louis Mario Wijaya on 01/09/25.
//

import SwiftUI

struct SupervisorDashboardView: View {
    @State private var selection: SidebarMenu? = nil
    @StateObject private var dashboardVM = DashboardViewModel()
    @StateObject private var dailyVM = DailyReportViewModel()
    @State private var expandDashboard = true
    @State private var expandHarian = true

    init(
        dashboardVM: DashboardViewModel? = nil,
        dailyVM: DailyReportViewModel? = nil
    ) {
        _dashboardVM = StateObject(
            wrappedValue: dashboardVM ?? DashboardViewModel()
        )
        _dailyVM = StateObject(wrappedValue: dailyVM ?? DailyReportViewModel())
    }

    var body: some View {
        NavigationSplitView {
            VStack {
                    List(selection: $selection) {
                        // MARK: Dashboard Dropdown
                        DisclosureGroup(isExpanded: $expandDashboard) {
                            NavigationLink(value: SidebarMenu.dashboard(.lembah)) {
                                Label("Lembah", systemImage: "apple.meditate")
                            }
                            NavigationLink(value: SidebarMenu.dashboard(.danau)) {
                                Label("Danau", systemImage: "water.waves")
                            }
                            NavigationLink(value: SidebarMenu.dashboard(.bukit)) {
                                Label("Bukit", systemImage: "mountain.2")
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
                                Label("Lembah", systemImage: "apple.meditate")
                            }
                            NavigationLink(value: SidebarMenu.programHarian(.danau)) {
                                Label("Danau", systemImage: "water.waves")
                            }
                            NavigationLink(value: SidebarMenu.programHarian(.bukit)) {
                                Label("Bukit", systemImage: "mountain.2")
                            }
                        } label: {
                            Label("Program Harian", systemImage: "list.bullet.clipboard")
                        }
                    }
                    .listStyle(.automatic)
                    .scrollContentBackground(.hidden) // 👈 remove system default
                    .background(Color(.systemGray6))   // 👈 force same background
                    .navigationTitle("Menu")

                    Spacer()

                    Button(action: {
                        SessionManager.shared.logout()
                    }) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .font(.title2)
                            Text("Keluar")
                                .font(.headline).bold()
                            Spacer()
                        }
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white)
                                .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                        )
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 30)
                    .padding(.bottom, 30)
                }
                .background(Color(.systemGray6))

        } detail: {
            switch selection {
            case .dashboard(let foreman):
                DashboardView(
                    viewModel: dashboardVM,
                    foremanId: foreman.foremanId
                )
                .navigationTitle("Dashboard - \(foreman.title)")

            case .programMingguan:
                WeeklyPlanHistory()

            case .programHarian(let foreman):
                DailyReportView(
                    viewModel: dailyVM,
                    foremanId: foreman.foremanId
                )
                .navigationTitle("Program Harian - \(foreman.title)")

            default:
                VStack {
                    Text("Pilih menu di samping")
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .background(Color(.systemGray6))
            }
            .background(Color(.systemGray6))
        }
        .background(Color(.systemGray6))
    }
}

#Preview {
    SupervisorDashboardView()
}
