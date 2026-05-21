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
            VStack(spacing: 0) {
                List(selection: $selection) {
                    // MARK: Dashboard Dropdown
                    DisclosureGroup(isExpanded: $expandDashboard) {
                        NavigationLink(value: SidebarMenu.dashboard(.lembah)) {
                            Label {
                                Text("Lembah")
                            } icon: {
                                Image(systemName: "apple.meditate")
                                    .imageScale(.small)
                                    .dynamicTypeSize(.medium)
                            }
                        }
                        NavigationLink(value: SidebarMenu.dashboard(.danau)) {
                            Label {
                                Text("Danau")
                            } icon: {
                                Image(systemName: "water.waves")
                                    .imageScale(.small)
                                    .dynamicTypeSize(.medium)  // keep icon steady
                            }
                        }
                        NavigationLink(value: SidebarMenu.dashboard(.bukit)) {
//                            Label("Bukit", systemImage: "mountain.2")
                            Label {
                                Text("Bukit")
                            } icon: {
                                Image(systemName: "mountain.2")
                                    .imageScale(.small)
                                    .dynamicTypeSize(.medium)
                            }
                        }
                    } label: {
//                        Label("Dashboard", systemImage: "rectangle.grid.2x2")
                        Label {
                            Text("Dashboard")
                        } icon: {
                            Image(systemName: "rectangle.grid.2x2")
                                .imageScale(.small)
                                .dynamicTypeSize(.medium)  // keep icon steady
                        }
                    }

                    // MARK: Program Mingguan (standalone)
                    NavigationLink(value: SidebarMenu.programMingguan) {
//                        Label(
//                            "Program Mingguan",
//                            systemImage: "calendar.badge.plus"
//                        )
                        Label {
                            Text("Program Mingguan")
                        } icon: {
                            Image(systemName: "calendar.badge.plus")
                                .imageScale(.small)
                                .dynamicTypeSize(.medium)  // keep icon steady
                        }
                    }

                    // MARK: Program Harian Dropdown
                    DisclosureGroup(isExpanded: $expandHarian) {
                        NavigationLink(
                            value: SidebarMenu.programHarian(.lembah)
                        ) {
                            Label {
                                Text("Lembah")
                            } icon: {
                                Image(systemName: "apple.meditate")
                                    .imageScale(.small)
                                    .dynamicTypeSize(.medium)
                            }
                        }
                        NavigationLink(value: SidebarMenu.programHarian(.danau))
                        {
                            Label {
                                Text("Danau")
                            } icon: {
                                Image(systemName: "water.waves")
                                    .imageScale(.small)
                                    .dynamicTypeSize(.medium)  // keep icon steady
                            }
                        }
                        NavigationLink(value: SidebarMenu.programHarian(.bukit))
                        {
                            Label {
                                Text("Bukit")
                            } icon: {
                                Image(systemName: "mountain.2")
                                    .imageScale(.small)
                                    .dynamicTypeSize(.medium)
                            }
                        }
                    } label: {
                        Label {
                            Text("Harian")
                        } icon: {
                            Image(systemName: "list.bullet.clipboard")
                                .imageScale(.small)
                                .dynamicTypeSize(.medium)
                        }
                    }
                }
                .listStyle(.automatic)
                .scrollContentBackground(.hidden)
                .background(Color(.systemGray6))
                .navigationTitle("Menu")

                // Logout Button fixed at bottom
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
                            .shadow(
                                color: .black.opacity(0.3),
                                radius: 4,
                                x: 0,
                                y: 2
                            )
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
        }
        .background(Color(.systemGray6))
    }
}

#Preview {
    SupervisorDashboardView()
}
