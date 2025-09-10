//
//  MandorDashboardView.swift
//  Palimanan-maintenance-team
//
//  Created by Louis Mario Wijaya on 03/09/25.
//

import SwiftUI

struct MandorDashboardView: View {
    @StateObject var viewModel: MandorDashboardViewModel
    @EnvironmentObject var session: SessionManager
    @State private var showAddTaskSheet: Bool = false
    @State private var selectedTask: TaskDetail? = nil
    @State private var selectedTaskLocationId: Int = -1

    init() {
        _viewModel = StateObject(wrappedValue: MandorDashboardViewModel())
    }

    init(viewModel: MandorDashboardViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Loading Data...")
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .accessibilityLabel("Memuat data")
                } else if let errorMessage = viewModel.errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                        .padding()
                        .accessibilityLabel(
                            "Terjadi kesalahan: \(errorMessage)"
                        )
                } else if let plan = viewModel.dailyPlan {
                    if DateHelper.isToday(plan.createdAt) {
                        dashboardContent(plan: plan)
                    } else {
                        VStack(spacing: 12) {
                            Text(
                                "Tidak ada pekerjaan, silakan menambahkan pekerjaan"
                            )
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding()

                            Button(action: { showAddTaskSheet = true }) {
                                Label("Tambah Pekerjaan", systemImage: "plus")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.green)
                            .padding(.horizontal)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                } else {
                    Text("No data available.")
                        .accessibilityLabel("Tidak ada data yang tersedia")
                }
            }

            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Keluar", role: .destructive) {
                        session.logout()
                    }
                    .fontWeight(.semibold)
                }
            }

            .onAppear {
                if viewModel.dailyPlan == nil {
                    Task {
                        await viewModel.fetchLatestDailyPlan()
                    }
                }
            }

            .sheet(isPresented: $showAddTaskSheet) {
                AddTaskView(foremanId: SessionManager.shared.foremanId!) {
                    divisionId,
                    locationId,
                    jobType,
                    area,
                    priority,
                    description in
                    Task {
                        if let plan = viewModel.dailyPlan {
                            if DateHelper.isToday(plan.createdAt) {
                                await viewModel.addSelfNewDailyTask(
                                    for: SessionManager().foremanId!,
                                    taskId: plan.id,
                                    divisionId: divisionId,
                                    locationId: locationId,
                                    jobType: jobType,
                                    area: area,
                                    priority: priority,
                                    description: description
                                )
                            } else {
                                // ❌ Not today → create new plan + task
                                await viewModel.createNewDailyPlanAndTask(
                                    for: SessionManager().foremanId!,
                                    divisionId: divisionId,
                                    locationId: locationId,
                                    jobType: jobType,
                                    area: area,
                                    priority: priority,
                                    description: description
                                )
                            }
                            await viewModel.fetchLatestDailyPlan()
                        } else {
                            // no plan at all → create new one
                            await viewModel.createNewDailyPlanAndTask(
                                for: SessionManager().foremanId!,
                                divisionId: divisionId,
                                locationId: locationId,
                                jobType: jobType,
                                area: area,
                                priority: priority,
                                description: description
                            )
                            await viewModel.fetchLatestDailyPlan()
                        }
                    }
                }
            }

            .sheet(item: $selectedTask) { task in
                UpdateTaskView(
                    task: task,
                    foremanId: SessionManager.shared.foremanId!,
                    locationId: selectedTaskLocationId
                ) {
                    jobType,
                    locationId,
                    area,
                    priority,
                    notes,
                    neededWorkers,
                    availableWorker,
                    workerNames,
                    image in
                    Task {
                        await viewModel.updateTask(
                            foremanId: SessionManager.shared.foremanId!,
                            reportId: viewModel.dailyPlan?.id ?? 0,
                            taskId: task.id,
                            jobType: jobType,
                            locationId: locationId,
                            areas: area,
                            workerNeeded: neededWorkers,
                            availableWorker: availableWorker,
                            workerNameList: workerNames,
                            image: image
                        )
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func dashboardContent(plan: DailyPlanData) -> some View {
        VStack(alignment: .leading) {
            
            Text("Program Hari Ini")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.horizontal)
                .padding(.bottom, 4)
                .accessibilityAddTraits(.isHeader)
            
            HStack {
                Image(systemName: "leaf.fill")
                    .foregroundColor(Color(hex: "#79A222"))
                Text("\(viewModel.mandorArea)")
                    .font(.body)
                    .foregroundColor(Color(hex: "#79A222"))
                    .fontWeight(.bold)
            }
            .padding(.horizontal)
            .padding(.bottom, 4)
            
            Text("Hari: \(viewModel.formattedDate)")
                .font(.footnote)
                .fontWeight(.medium)
                .foregroundStyle(Color(hex: "#A9A9A9"))
                .padding(.horizontal)
            
            if plan.approved.isApproved {
                Text("Status: Sudah Disetujui")
                    .font(.footnote)
                    .fontWeight(.medium)
                    .foregroundStyle(Color(hex: "#A9A9A9"))
                    .padding(.horizontal)
            } else {
                Text("Status: Dalam Pengerjaan")
                    .font(.footnote)
                    .fontWeight(.medium)
                    .foregroundStyle(Color(hex: "#A9A9A9"))
                    .padding(.horizontal)
            }
            
            Divider().accessibilityHidden(true)

            HStack {
                Text("Daftar Pekerjaan")
                    .font(.title2).bold()
                    .accessibilityAddTraits(.isHeader)
                Spacer()
                Button(action: { showAddTaskSheet = true }) {
                    Label("Tambah", systemImage: "plus")
                }
                .buttonStyle(.borderedProminent)
                .accessibilityHint("Tambah pekerjaan baru ke daftar")
            }
            .padding(.horizontal)
            
            Picker("Division", selection: $viewModel.selectedDivisionName) {
                ForEach(viewModel.allDivisions, id: \.self) { division in
                    Text(division)
                        .accessibilityLabel("Divisi \(division)")
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            List {
                if viewModel.filteredLocations.isEmpty {
                    Text(
                        "Tidak ada pekerjaan di divisi \(viewModel.selectedDivisionName) untuk hari ini."
                    )
                    .foregroundColor(.secondary)
                    .accessibilityLabel(
                        "Tidak ada pekerjaan di divisi \(viewModel.selectedDivisionName) untuk hari ini"
                    )
                } else {
                    ForEach(viewModel.filteredLocations) { location in
                        Section(
                            header: Text("\(location.locationName.uppercased()) \(location.locationId)")
                                .accessibilityAddTraits(.isHeader)
                                .accessibilityHint(
                                    "Daftar pekerjaan di lokasi \(location.locationName)"
                                )
                            
                        ) {
                            ForEach(location.tasks) { task in
                                taskRow(task: task, locationId: location.locationId)
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
        }
    }

    // A view for a single task row
    private func taskRow(task: TaskDetail, locationId: Int) -> some View {
        Button {
            selectedTask = task
            selectedTaskLocationId = locationId
        } label: {
            HStack(spacing: 15) {
                Text(task.priority)
                    .font(.headline.monospaced())
                    .frame(width: 44, height: 44)
                    .background(Color.gray.opacity(0.1))
                    .clipShape(Circle())
                    .accessibilityHidden(true)

                VStack(alignment: .leading) {
                    Text(task.taskType)
                        .fontWeight(.bold)
                    Text(task.area.joined(separator: ", "))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .accessibilityHidden(true)
            }
            .padding(.vertical, 4)
            .accessibilityLabel(
                "\(task.taskType), prioritas \(task.priority), area: \(task.area.joined(separator: ", "))"
            )
            .accessibilityHint(
                "Ketuk untuk membuka detail pekerjaan \(task.taskType)"
            )
        }
        .buttonStyle(.plain)
    }
}

private func infoRow(icon: String, title: String, subtitle: String) -> some View {
    HStack(spacing: 16) {
        Image(systemName: icon)
            .font(.title2)
            .foregroundColor(.green)
            .frame(width: 24)
            .accessibilityHidden(true)

        VStack(alignment: .leading) {
            Text(title)
                .fontWeight(.bold)
            Text(subtitle)
                .foregroundColor(.secondary)
        }
        Spacer()
    }
    .padding()
    .accessibilityElement(children: .combine)
    .accessibilityLabel("\(title): \(subtitle)")
}

extension MandorDashboardView {
    static var previewVM: MandorDashboardViewModel = {

        // We create our mock data using the exact structure from your API response.
        let mockData = DailyPlanData(
            id: 39,
            createdAt: "2025-09-03",
            approved: ApprovedStatus(
                isApproved: false,
                approvedAt: "",
                spvName: ""
            ),
            outsourceCompany: "Turcotte - Schumm",
            foremanName: "Darlene McLaughlin",
            totalTasks: 4,
            finishedTasks: 0,
            pendingTasks: 4,
            divisions: [
                .init(
                    id: 1,
                    name: "Operasional",
                    locations: [
                        .init(
                            locationId: 4,
                            locationName: "Fairway",
                            tasks: [
                                .init(
                                    id: 1281,
                                    taskType: "y",
                                    description: "yy",
                                    priority: "P2",
                                    area: ["Parkiran", "Hole 25"],
                                    needWorker: nil,
                                    availableWorker: nil,
                                    workerList: [],
                                    isFinished: false
                                )
                            ]
                        )
                    ]
                ),
                .init(
                    id: 2,
                    name: "Landscape",
                    locations: [
                        .init(
                            locationId: 2,
                            locationName: "Green",
                            tasks: [
                                .init(
                                    id: 1282,
                                    taskType: "l",
                                    description: "ll",
                                    priority: "P1",
                                    area: ["Hole 8", "Main Gate"],
                                    needWorker: nil,
                                    availableWorker: nil,
                                    workerList: [],
                                    isFinished: false
                                )
                            ]
                        ),
                        .init(
                            locationId: 14,
                            locationName: "Mekanik",
                            tasks: [
                                .init(
                                    id: 1283,
                                    taskType: "u",
                                    description: "uu",
                                    priority: "P1",
                                    area: ["Hole 2"],
                                    needWorker: nil,
                                    availableWorker: nil,
                                    workerList: [],
                                    isFinished: false
                                ),
                                .init(
                                    id: 1284,
                                    taskType: "9",
                                    description: "99",
                                    priority: "P4",
                                    area: ["Hole 6"],
                                    needWorker: nil,
                                    availableWorker: nil,
                                    workerList: [],
                                    isFinished: false
                                ),
                            ]
                        ),
                    ]
                ),
            ]
        )

        // We return a new ViewModel, initializing it with our mock data.
        return MandorDashboardViewModel(mockPlan: mockData)
    }()
}

//#Preview {
//    // This calls the special initializer for previews, injecting the mock ViewModel.
//    MandorDashboardView(viewModel: MandorDashboardView.previewVM)
//    // We still need a dummy SessionManager for the Logout button to work in the preview.
//        .environmentObject(SessionManager())
//}
