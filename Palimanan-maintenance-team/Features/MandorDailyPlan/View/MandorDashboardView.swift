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
                    //                    if DateHelper.isToday(plan.createdAt) {
                    //                        dashboardContent(plan: plan)
                    //                    }
                    if plan != nil {
                        dashboardContent(plan: plan)
                    }
                    else {
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
                    Button(role: .destructive) {
                        session.logout()
                    } label: {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .foregroundColor(.red)
                            .font(.callout)
                    }
                    .fontWeight(.semibold)
                }
            }
            
            .onAppear {
                if viewModel.dailyPlan == nil {
                    Task {
                        await viewModel.fetchLatestDailyPlan()
                        viewModel.startRefetching()
                    }
                }
            }
            
            .onDisappear {
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
                Image(systemName: {
                    switch viewModel.mandorArea {
                    case "Lembah":
                        return "leaf.fill"
                    case "Bukit":
                        return "mountain.2"
                    case "Danau":
                        return "water.waves"
                    default:
                        return "leaf.fill"
                    }
                }())
                .foregroundColor(Color(hex: "#A9A9A9"))
                .font(.subheadline)
                
                Text("\(viewModel.mandorArea)")
                    .font(.subheadline)
                    .foregroundColor(Color(hex: "#A9A9A9"))
                    .fontWeight(.medium)
                
                Text("|")
                    .font(.subheadline)
                    .foregroundStyle(Color(hex: "#A9A9A9"))
                    .fontWeight(.medium)
                
                Text("\(viewModel.formattedDate)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(Color(hex: "#A9A9A9"))
            }
            .padding(.horizontal)
            .padding(.bottom, 4)
            
            if plan.approved.isApproved {
                Text("Status: Sudah Disetujui")
                    .font(.footnote)
                    .fontWeight(.regular)
                    .foregroundStyle(Color(hex: "#292929"))
                    .padding(.vertical, 6)
                    .padding(.horizontal, 12)
                    .background(Color.gray)
                    .padding(.horizontal)
            } else {
                Text("Status: Dalam Pengerjaan")
                    .font(.footnote)
                    .fontWeight(.regular)
                    .foregroundStyle(Color(hex: "292929"))
                    .padding(.vertical, 6)
                    .padding(.horizontal, 12)
                    .background(Color(hex: "EDEDED"))
                    .cornerRadius(8)
                    .padding(.horizontal)
            }
            
            ZStack {
                LinearGradient(
                    colors: [
                        Color(hex: "#FFFFFF"),
                        Color(hex: "#79A222").opacity(0.3),
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
                            .cornerRadius(8)
                            .accessibilityHint(
                                "Tambah pekerjaan baru ke daftar"
                            )
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    .padding(.bottom, 20)
                    
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
                    
                    Picker("Pilih Status Pekerjaan", selection: $viewModel.selectedStatusFilter) {
                        ForEach(MandorDashboardViewModel.TaskStatusFilter.allCases, id: \.self) { status in
                            Text(status.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    .padding(.top, 4)
                    .accessibilityLabel("Filter status pekerjaan")
                    
                    List {
                        if viewModel.filteredLocations.isEmpty {
                            Text("Tidak ada pekerjaan hari ini.")
                                .frame(maxWidth: .infinity, alignment: .center)
                                .foregroundColor(Color(hex: "#A9A9A9"))
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .padding(.top, 24)
                                .accessibilityLabel(
                                    "Tidak ada pekerjaan di divisi \(viewModel.selectedDivisionName) untuk hari ini"
                                )
                        } else {
                            ForEach(viewModel.filteredLocations) { location in
                                Section(
                                    header: Text(
                                        "\(location.locationName.uppercased())"
                                    )
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
                                        .padding(.vertical, -6)
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
            HStack {
                Text(task.priority)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .accessibilityHidden(true)
                    .padding(.horizontal, 8)
                
                VStack(alignment: .leading) {
                    Text(task.taskType)
                        .font(.body)
                        .fontWeight(.light)
                    
                    Spacer()
                        .frame(height: 4)
                    
                    
                    Text(task.area.joined(separator: ", "))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
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
            id: 42,
            createdAt: todayDateString,
            approved: ApprovedStatus(isApproved: false, approvedAt: "", spvName: ""),
            outsourceCompany: "PT. Golf Sejahtera",
            foremanName: "Darlene McLaughlin",
            totalTasks: 17,
            finishedTasks: 4,
            pendingTasks: 13,
            divisions: [
                .init(
                    id: 1, name: "Operasional", locations: [
                        .init(
                            locationId: 1, locationName: "Green", tasks: [
                                .init(id: 101, taskType: "Verticut Green", description: "Jalur verticut utara-selatan", priority: "P1", area: ["H1-H9"], needWorker: nil, availableWorker: nil, workerList: [], isFinished: false),
                                .init(id: 102, taskType: "Pupuk Granular Green", description: "Gunakan pupuk NPK 15-15-15", priority: "P2", area: ["H10-H18"], needWorker: nil, availableWorker: nil, workerList: [], isFinished: false),
                                .init(id: 103, taskType: "Sulam Rumput Green", description: "Area yang botak di H5 dan H7", priority: "P1", area: ["H5", "H7"], needWorker: nil, availableWorker: nil, workerList: [], isFinished: true)
                            ]),
                        .init(
                            locationId: 2, locationName: "Tee Box", tasks: [
                                .init(id: 104, taskType: "Mowing Tee Box", description: "Ketinggian 1.5 inch", priority: "P2", area: ["Semua Hole"], needWorker: nil, availableWorker: nil, workerList: [], isFinished: false),
                                .init(id: 105, taskType: "Top Dress Pasir", description: "Tebar tipis di area baru tanam", priority: "P3", area: ["H1", "H10"], needWorker: nil, availableWorker: nil, workerList: [], isFinished: false)
                            ]),
                        .init(
                            locationId: 3, locationName: "Fairway", tasks: [
                                .init(id: 106, taskType: "Mowing Fairway", description: "Pola pemotongan diamond", priority: "P2", area: ["H1-H9"], needWorker: nil, availableWorker: nil, workerList: [], isFinished: false),
                                .init(id: 107, taskType: "Spot Weeding Gulma", description: "Cabut gulma manual", priority: "P3", area: ["H11", "H14"], needWorker: nil, availableWorker: nil, workerList: [], isFinished: true)
                            ]),
                        .init(
                            locationId: 4, locationName: "Apron", tasks: [
                                .init(id: 108, taskType: "Trimming Tepi Apron", description: "Gunakan mesin potong senar", priority: "P3", area: ["Semua Hole"], needWorker: nil, availableWorker: nil, workerList: [], isFinished: false)
                            ])
                    ]),
                .init(
                    id: 2, name: "Landscape", locations: [
                        .init(
                            locationId: 10, locationName: "All", tasks: [
                                .init(id: 201, taskType: "Pemangkasan Bunga Bougenville", description: "Area di sekitar Clubhouse dan danau H15", priority: "P2", area: ["Clubhouse", "H15"], needWorker: nil, availableWorker: nil, workerList: [], isFinished: false),
                                .init(id: 202, taskType: "Pembersihan Taman & Daun Kering", description: "Fokus di area shelter", priority: "P1", area: ["Shelter H5", "Shelter H12"], needWorker: nil, availableWorker: nil, workerList: [], isFinished: true)
                            ])
                    ]),
                .init(
                    id: 3, name: "Projek", locations: [
                        .init(
                            locationId: 11, locationName: "All", tasks: [
                                .init(id: 301, taskType: "Renovasi Bunker", description: "Penggantian pasir bunker H16", priority: "P1", area: ["H16"], needWorker: nil, availableWorker: nil, workerList: [], isFinished: false),
                                .init(id: 302, taskType: "Perbaikan Jalur Cart", description: "Tambal lubang di jalur antara H3 dan H4", priority: "P2", area: ["H3-H4"], needWorker: nil, availableWorker: nil, workerList: [], isFinished: false)
                            ])
                    ]),
                .init(
                    id: 4, name: "Irigasi", locations: [
                        .init(
                            locationId: 12, locationName: "All", tasks: [
                                .init(id: 401, taskType: "Perbaikan Sprinkler Patah", description: "Sprinkler di fairway H6 sisi kiri", priority: "P1", area: ["H6"], needWorker: nil, availableWorker: nil, workerList: [], isFinished: false),
                                .init(id: 402, taskType: "Pembersihan Nozzle Tersumbat", description: "Area green H11 dan H18", priority: "P3", area: ["H11", "H18"], needWorker: nil, availableWorker: nil, workerList: [], isFinished: false)
                            ])
                    ]),
                .init(
                    id: 5, name: "Mekanik", locations: [
                        .init(
                            locationId: 13, locationName: "All", tasks: [
                                .init(id: 501, taskType: "Servis Mesin Potong Green", description: "Ganti oli dan asah pisau Reel Mower A", priority: "P1", area: ["Workshop"], needWorker: nil, availableWorker: nil, workerList: [], isFinished: false),
                                .init(id: 502, taskType: "Perbaikan Ban Golf Cart 14", description: "Ban belakang kanan bocor", priority: "P2", area: ["Workshop"], needWorker: nil, availableWorker: nil, workerList: [], isFinished: false),
                                .init(id: 503, taskType: "Cek Aki Golf Cart", description: "Pengecekan rutin untuk 5 unit", priority: "P3", area: ["Garasi Cart"], needWorker: nil, availableWorker: nil, workerList: [], isFinished: true)
                            ])
                    ])
            ]
        )
        
        return MandorDashboardViewModel(mockPlan: mockData)
    }()
}

#Preview {
    MandorDashboardView(viewModel: MandorDashboardView.previewVM)
        .environmentObject(SessionManager())
}
