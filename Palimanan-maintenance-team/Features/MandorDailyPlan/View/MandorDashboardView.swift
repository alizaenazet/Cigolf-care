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
    
    init() {
        _viewModel = StateObject(wrappedValue: MandorDashboardViewModel())
    }
    
    init(viewModel: MandorDashboardViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Loading Data...")
                } else if let errorMessage = viewModel.errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                        .padding()
                } else if let plan = viewModel.dailyPlan {
                    dashboardContent(plan: plan)
                } else {
                    Text("No data available.")
                }
            }
            
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Label(viewModel.mandorArea, systemImage: "leaf.fill")
                        .foregroundColor(.green)
                }
            }
            
            .onAppear {
                if viewModel.dailyPlan == nil {
                    Task {
                        await viewModel.fetchLatestDailyPlan()
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func dashboardContent(plan: DailyPlanData) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            
            Text("Program Hari Ini")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            VStack(spacing: 0) {
                infoRow(
                    icon: "calendar",
                    title: "Tanggal",
                    subtitle: viewModel.formattedDate
                )
                
                Divider().padding(.leading, 60)
                
                infoRow(
                    icon: "person.3.fill",
                    title: "Penyedia Tenaga Kerja",
                    subtitle: plan.outsourceCompany
                )
                
                Divider().padding(.leading, 60)
                
                infoRow(
                    icon: "map.fill",
                    title: "Area",
                    subtitle: viewModel.allTaskAreas
                )
            }
            .background(Color(.white))
            .cornerRadius(12)
            .padding(.horizontal)
            
            Divider()
            
            HStack {
                Text("Daftar Pekerjaan")
                    .font(.title2).bold()
                Spacer()
                Button(action: { /* Static for now */ }) {
                    Label("Tambah", systemImage: "plus")
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.horizontal)
            
            // Segmented control for divisions
            Picker("Division", selection: $viewModel.selectedDivisionName) {
                ForEach(viewModel.allDivisions, id: \.self) { division in
                    Text(division)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            // The list of tasks, grouped by location
            List {
                if viewModel.filteredLocations.isEmpty {
                    Text("Tidak ada pekerjaan di divisi \(viewModel.selectedDivisionName) untuk hari ini.")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(viewModel.filteredLocations) { location in
                        Section(header: Text(location.locationName.uppercased())) {
                            ForEach(location.tasks) { task in
                                taskRow(task: task)
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
        }
    }
    
    // A view for a single task row
    private func taskRow(task: TaskDetail) -> some View {
        HStack(spacing: 15) {
            Text(task.priority)
                .font(.headline.monospaced())
                .frame(width: 44, height: 44)
                .background(Color.gray.opacity(0.1))
                .clipShape(Circle())
            
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
        }
        .padding(.vertical, 4)
    }
}

private func infoRow(icon: String, title: String, subtitle: String) -> some View {
    HStack(spacing: 16) {
        Image(systemName: icon)
            .font(.title2)
            .foregroundColor(.green)
            .frame(width: 24)
        
        VStack(alignment: .leading) {
            Text(title)
                .fontWeight(.bold)
            Text(subtitle)
                .foregroundColor(.secondary)
        }
        Spacer()
    }
    .padding()
}


// --- PREVIEW PROVIDER ---

// We create an extension to hold our preview-specific code, keeping it clean.
extension MandorDashboardView {
    // This is a static, pre-configured ViewModel instance that will be used ONLY for the preview.
    static var previewVM: MandorDashboardViewModel = {
        
        // We create our mock data using the exact structure from your API response.
        let mockData = DailyPlanData(
            id: 39, createdAt: "2025-09-03",
            approved: ApprovedStatus(isApproved: false, approvedAt: "", spvName: ""),
            outsourceCompany: "Turcotte - Schumm",
            foremanName: "Darlene McLaughlin",
            totalTasks: 4, finishedTasks: 0, pendingTasks: 4,
            divisions: [
                .init(id: 1, name: "Operasional", locations: [
                    .init(locationId: 4, locationName: "Fairway", tasks: [
                        .init(id: 1281, taskType: "y", description: "yy", priority: "P2", area: ["Parkiran","Hole 25"], needWorker: nil, availableWorker: nil, workerList: [], isFinished: false)
                    ])
                ]),
                .init(id: 2, name: "Landscape", locations: [
                    .init(locationId: 2, locationName: "Green", tasks: [
                        .init(id: 1282, taskType: "l", description: "ll", priority: "P1", area: ["Hole 8","Main Gate"], needWorker: nil, availableWorker: nil, workerList: [], isFinished: false)
                    ]),
                    .init(locationId: 14, locationName: "Mekanik", tasks: [
                        .init(id: 1283, taskType: "u", description: "uu", priority: "P1", area: ["Hole 2"], needWorker: nil, availableWorker: nil, workerList: [], isFinished: false),
                        .init(id: 1284, taskType: "9", description: "99", priority: "P4", area: ["Hole 6"], needWorker: nil, availableWorker: nil, workerList: [], isFinished: false)
                    ])
                ])
            ]
        )
        
        // We return a new ViewModel, initializing it with our mock data.
        return MandorDashboardViewModel(mockPlan: mockData)
    }()
}

#Preview {
    // This calls the special initializer for previews, injecting the mock ViewModel.
    MandorDashboardView(viewModel: MandorDashboardView.previewVM)
    // We still need a dummy SessionManager for the Logout button to work in the preview.
        .environmentObject(SessionManager())
}
