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
                    ProgressView("Memuat data...")
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .accessibilityLabel("Sedang memuat data")
                } else if viewModel.errorMessage != nil {
                    Text("Gagal memuat data.")
                        .foregroundColor(.red)
                        .padding()
                        .accessibilityLabel(
                            "Gagal memuat data."
                        )

                    Button(action: {
                        Task {
                            await viewModel.fetchLatestDailyPlan()
                        }
                    }) {
                        Label(
                            "Coba Kembali",
                            systemImage:
                                "arrow.trianglehead.clockwise.rotate.90"
                        )
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.accentColor)
                    .padding(.horizontal)
                    .accessibilityLabel(
                        "Coba Kembali."
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
                            .accessibilityLabel(
                                "Tidak ada pekerjaan, silakan menambahkan pekerjaan"
                            )

                            Button(action: { showAddTaskSheet = true }) {
                                Label("Tambah Pekerjaan", systemImage: "plus")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.accentColor)
                            .padding(.horizontal)
                            .accessibilityLabel(
                                "Tambah Pekerjaan."
                            )
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                } else {
                    Text("Tidak ada data yang tersedia.")
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
                        // Start refetching when view appears
                        viewModel.startRefetching()
                    }
                }
            }

            .onDisappear {
                // Stop refetching when view disappears to prevent memory leaks
                viewModel.stopRefetching()
            }

            .sheet(isPresented: $showAddTaskSheet) {
                AddTaskView(foremanId: SessionManager.shared.foremanId!) {
                    divisionId,
                    locationId,
                    jobType,
                    area,
                    priority,
                    description in
                    do {
                        if let plan = viewModel.dailyPlan {
                            if DateHelper.isToday(plan.createdAt) {
                                try await viewModel.addSelfNewDailyTask(
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
                                try await viewModel.createNewDailyPlanAndTask(
                                    for: SessionManager().foremanId!,
                                    divisionId: divisionId,
                                    locationId: locationId,
                                    jobType: jobType,
                                    area: area,
                                    priority: priority,
                                    description: description
                                )
                            }
                        } else {
                            try await viewModel.createNewDailyPlanAndTask(
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
                        return true
                    } catch {
                        print(
                            "❌ Failed to add task:",
                            error.localizedDescription
                        )
                        return false
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
                    description,
                    neededWorkers,
                    availableWorker,
                    workerNames,
                    image in
                    do {
                        try await viewModel.updateTask(
                            foremanId: SessionManager.shared.foremanId!,
                            reportId: viewModel.dailyPlan?.id ?? 0,
                            taskId: task.id,
                            jobType: jobType,
                            locationId: locationId,
                            areas: area,
                            workerNeeded: neededWorkers,
                            availableWorker: availableWorker,
                            workerNameList: workerNames,
                            image: image,
                            description: description
                        )
                        
                        await viewModel.fetchLatestDailyPlan()
                        return true
                    } catch {
                        print(
                            "❌ Failed to update task:",
                            error.localizedDescription
                        )
                        return false 
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
                    .padding(.bottom, 8)
            }

            ZStack {
                LinearGradient(
                    colors: [
                        Color(hex: "#F8F8F8"),
                        Color(hex: "#79A222").opacity(0.6),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(alignment: .leading) {
                    HStack {
                        Text("Daftar Pekerjaan")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .accessibilityAddTraits(.isHeader)

                        Spacer()

                        if !plan.approved.isApproved {
                            Button(action: { showAddTaskSheet = true }) {
                                HStack {
                                    Image(systemName: "plus")
                                        .font(.subheadline)
                                        .foregroundStyle(Color.white)

                                    Text("Tambah")
                                        .foregroundStyle(Color.white)
                                        .font(.subheadline)
                                }
                                .padding(.vertical, 4)
                                .padding(.horizontal, 12)
                            }
                            .background(Color(hex: "#79A222"))
                            .cornerRadius(16)
                            .accessibilityHint(
                                "Tambah pekerjaan baru ke daftar"
                            )
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top)

                    Menu {
                        ForEach(viewModel.allDivisions, id: \.self) {
                            division in
                            Button(division) {
                                viewModel.selectedDivisionName = division
                            }
                        }
                    } label: {
                        HStack {
                            Text(viewModel.selectedDivisionName)
                                .font(.title3)
                                .fontWeight(.semibold)

                            Image(systemName: "chevron.down")
                                .font(.footnote)
                                .fontWeight(.bold)
                        }
                        .foregroundColor(Color(hex: "#79A222"))
                        .padding(.horizontal)
                    }
                    .accessibilityLabel(
                        "Pilih Divisi, saat ini \(viewModel.selectedDivisionName)"
                    )

                    List {
                        if viewModel.filteredLocations.isEmpty {
                            Text("Tidak ada pekerjaan hari ini.")
                                .frame(maxWidth: .infinity, alignment: .center)
                                .foregroundColor(Color(hex: "#A9A9A9"))
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .accessibilityLabel(
                                    "Tidak ada pekerjaan di divisi \(viewModel.selectedDivisionName) untuk hari ini"
                                )
                        } else {
                            ForEach(viewModel.filteredLocations) { location in
                                Section(
                                    header: Text(
                                        "\(location.locationName.uppercased())"
                                    )
                                    .padding(.vertical, 4)
                                    .accessibilityAddTraits(.isHeader)
                                    .accessibilityHint(
                                        "Daftar pekerjaan di lokasi \(location.locationName)"
                                    )
                                ) {
                                    ForEach(
                                        location.tasks.sorted(by: {
                                            $0.priority < $1.priority
                                        })
                                    ) { task in
                                        taskRow(
                                            task: task,
                                            locationId: location.locationId,
                                            taskState: plan.approved.isApproved
                                        )
                                        .listRowSeparator(.hidden)
                                        .listRowBackground(Color.clear)
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
        }
    }

    private func taskRow(task: TaskDetail, locationId: Int, taskState: Bool)
        -> some View
    {
        Button {
            selectedTask = task
            selectedTaskLocationId = locationId
        } label: {
            HStack(spacing: 16) {
                Text(task.priority)
                    .font(.caption)
                    .fontWeight(.bold)
                    .frame(width: 32, height: 32)
                    .background(Color.gray.opacity(0.1))
                    .clipShape(Circle())
                    .accessibilityHidden(true)

                Text(task.taskType)
                    .font(.body)
                    .fontWeight(.light)
                    .lineLimit(1)

                Spacer()

                Text(task.area.joined(separator: ", "))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)

                if !taskState {
                    Image(systemName: "chevron.right")
                        .font(.headline)
                        .foregroundColor(Color(hex: "#79A222"))
                        .accessibilityHidden(true)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
            .background(Color.white)
            .cornerRadius(12)
            .accessibilityLabel(
                "\(task.taskType), prioritas \(task.priority), area: \(task.area.joined(separator: ", "))"
            )
            .accessibilityHint(
                "Ketuk untuk membuka detail pekerjaan \(task.taskType)"
            )
        }
        .disabled(taskState)
    }
}

extension MandorDashboardView {
    static var previewVM: MandorDashboardViewModel = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let todayDateString = formatter.string(from: Date())
        let mockData = DailyPlanData(
            id: 39,
            createdAt: todayDateString,
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
                                    taskType: "Perapian TANAKA",
                                    description: "yy",
                                    priority: "P2",
                                    area: [
                                        "CH", "FC", "H1", "H2", "H3", "H4",
                                        "H5",
                                    ],
                                    needWorker: nil,
                                    availableWorker: nil,
                                    workerList: [],
                                    isFinished: false
                                ),
                                .init(
                                    id: 1281,
                                    taskType: "Perapian TANAKA",
                                    description: "yy",
                                    priority: "P2",
                                    area: [
                                        "CH", "FC", "H1", "H2", "H3", "H4",
                                        "H5",
                                    ],
                                    needWorker: nil,
                                    availableWorker: nil,
                                    workerList: [],
                                    isFinished: false
                                ),
                                .init(
                                    id: 1281,
                                    taskType: "Perapian TANAKA",
                                    description: "yy",
                                    priority: "P2",
                                    area: [
                                        "CH", "FC", "H1", "H2", "H3", "H4",
                                        "H5",
                                    ],
                                    needWorker: nil,
                                    availableWorker: nil,
                                    workerList: [],
                                    isFinished: false
                                ),
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
                                    taskType: "Potong Green",
                                    description: "ll",
                                    priority: "P1",
                                    area: ["H8", "H7", "H6"],
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
                                    taskType: "Service Golf Cart",
                                    description: "uu",
                                    priority: "P4",
                                    area: ["Hole 2"],
                                    needWorker: nil,
                                    availableWorker: nil,
                                    workerList: [],
                                    isFinished: false
                                ),
                                .init(
                                    id: 1284,
                                    taskType: "Perbaiki Roda Golf Cart 241",
                                    description: "99",
                                    priority: "P1",
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

        return MandorDashboardViewModel(mockPlan: mockData)
    }()
}

#Preview {
    MandorDashboardView(viewModel: MandorDashboardView.previewVM)
        .environmentObject(SessionManager())
}
