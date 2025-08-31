//
//  DashboardView.swift
//  Palimanan-maintenance-team
//
//  Created by Syamsuddin Putra Riefli on 31/08/25.
//

import SwiftUI


struct DashboardView: View {
    @ObservedObject var viewModel: DashboardViewModel
    let foremanId: Int
    
    var body: some View {
        ScrollView {
            if viewModel.isLoading {
                ProgressView("Loading…")
                    .padding()
            } else if let report = viewModel.report {
                VStack(spacing: 20) {
                    ForemanCard(report: report)
                    
                    ForEach(report.divisions) { division in
                        DivisionCard(division: division)
                    }
                }
                .padding()
            } else if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
            } else {
                Text("No data available")
                    .foregroundStyle(.secondary)
            }
        }
        .task {
            // Important: fetch again when the foremanId changes
            await viewModel.fetchReport(for: foremanId)
        }
        .background(Color(.systemGray6))
    }
}

#Preview {
    let mockReport = ForemanReport(
        id: 1,
        createdAt: "28-08-2025",
        approved: Approval(
            isApproved: true,
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
                id: 101,
                name: "Operasional",
                locations: [
                    Location(
                        locationId: 201,
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
                        locationId: 202,
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
                id: 102,
                name: "Landscape",
                locations: [
                    Location(
                        locationId: 301,
                        locationName: "Green",
                        tasks: [
                            TaskItem(
                                id: 401,
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
                                id: 402,
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
            )
        ]
    )
    
    // Inject mock data into the VM
    let mockVM = DashboardViewModel()
    mockVM.report = mockReport
    
    return DashboardView(
        viewModel: mockVM,
        foremanId: 1
    )
    .previewLayout(.sizeThatFits)
    .padding()
}

