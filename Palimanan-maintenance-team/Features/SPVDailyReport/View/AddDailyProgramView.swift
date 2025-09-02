//
//  AddDailyProgram.swift
//  Palimanan-maintenance-team
//
//  Created by Yobel Nathaniel Filipus on 02/09/25.
//

import SwiftUI

struct HeaderViewAddDailyProgram: View {
    var body: some View {
        HStack {
            Spacer()
            HStack {
                Image(systemName: "checkmark.circle")
                    .foregroundStyle(.white)
                Text("Simpan Program")
                    .fontWeight(.medium)
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 12)
            .background(.green)
            .cornerRadius(12)
        }
    }
}

struct AddDailyProgramView: View {
    let foremanId: Int
    
    @State private var division: [String: Int] = [
        "Operasional": 1,
        "Landscape": 2,
        "Projek": 3,
        "Irigasi": 4,
        "Mekanik": 5
    ]
    @State private var location: [String: Int] = [
        "All": 1,
        "Green": 2,
        "Tee Box": 3,
        "Fairway": 4,
        "Apron": 5,
        "Rough": 6,
        "Bunker": 7,
        "Nursery": 8,
        "Driving Range": 9,
        "Maingate": 10,
        "Putting 10": 11,
        "Paving Room": 12,
        "Resto": 13,
        "Mekanik": 14,
        "Irigasi": 15
    ]
    @StateObject private var viewModel = DailyReportViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header atas
                    HeaderViewAddDailyProgram()
                    
                    DivisionListView(viewModel: viewModel)
                }
                .padding()
            }
        }
        .navigationTitle("Buat Program Harian") // judul navigation bar
        .navigationBarTitleDisplayMode(.large) // bisa .large atau .inline
    }
}

struct DivisionListView: View {
    @ObservedObject var viewModel: DailyReportViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            ForEach($viewModel.cigolfDivision) { $division in
                if division.isSelected {
                    DivisionSection(
                        division: $division,
                        locations: viewModel.cigolfLocation,
                        viewModel: viewModel
                    )
                }
            }
            
            if (!viewModel.isSelectedAllDivision()) {
                Button(action: {
                    viewModel.addDivision()
                }) {
                    Text("Tambah Divisi")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .cornerRadius(10)
                }
            }
        }
    }
}

// MARK: - Division Section (Dynamic Jobs)
struct DivisionSection: View {
    @Binding var division: CigolfDivision
    var locations: [CigolfLocation]
    let viewModel: DailyReportViewModel
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header Divisi
            HStack {
                Text(division.name)
                    .font(.headline)
                Button {
                    division.isSelected = false
                } label: {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
                Spacer()
                
            }
            
            // Tombol Tambah Lokasi
            Button {
                //                division.jobs.append(DailyJob())
            } label: {
                Text("Tambah Lokasi")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .cornerRadius(10)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

//// MARK: - Subview untuk 1 Job
//struct JobItemView: View {
//    @Binding var job: DailyJob
//    @Binding var division: CigolfDivision
//    var locations: [CigolfLocation]
//
//    var body: some View {
//        VStack(spacing: 8) {
//            HStack {
//                Picker("Lokasi", selection: $job.location) {
//                    ForEach(locations) { loc in
//                        Text(loc.name).tag(Optional(loc))
//                    }
//                }
//                .pickerStyle(MenuPickerStyle())
//
//                Spacer()
//
//                Button {
//                    if let index = division.jobs.firstIndex(where: { $0.id == job.id }) {
//                        division.jobs.remove(at: index)
//                    }
//                } label: {
//                    Image(systemName: "trash")
//                        .foregroundColor(.red)
//                }
//            }
//
//            TextField("Jenis pekerjaan", text: $job.jobType)
//                .textFieldStyle(RoundedBorderTextFieldStyle())
//
//            TextField("Hole/Area", text: $job.holeArea)
//                .textFieldStyle(RoundedBorderTextFieldStyle())
//
//            Picker("Prioritas", selection: $job.priority) {
//                ForEach(1..<6) { i in
//                    Text("\(i)").tag(i)
//                }
//            }
//            .pickerStyle(SegmentedPickerStyle())
//
//            TextField("Keterangan ...", text: $job.notes)
//                .textFieldStyle(RoundedBorderTextFieldStyle())
//        }
//        .padding()
//        .background(Color.gray.opacity(0.05))
//        .cornerRadius(8)
//    }
//}


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
                                area: ["Hole 1", "Hole 2", "Villa"],
                                needWorker: 3,
                                availableWorker: 3,
                                workerList: ["Yobel", "Mar","Vick"],
                                urlPhoto: "",
                                isFinished: false
                            ),
                            TaskItem(
                                id: 302,
                                taskType: "Pupuk granular green",
                                description: "Pupuk cap cip cup",
                                priority: "P1",
                                area: ["Hole 9"],
                                needWorker: 1,
                                availableWorker: 1,
                                workerList: ["Yobel"],
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
                                area: ["Hole 1", "Hole 2", "Villa"],
                                needWorker: 3,
                                availableWorker: 3,
                                workerList: ["Yobel", "Mar","Vick"],
                                urlPhoto: "",
                                isFinished: false
                            ),
                            TaskItem(
                                id: 302,
                                taskType: "Pupuk granular green",
                                description: "Pupuk cap cip cup",
                                priority: "P1",
                                area: ["Hole 9"],
                                needWorker: 1,
                                availableWorker: 1,
                                workerList: ["Yobel"],
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
                                area: ["Hole 1", "Hole 2", "Villa"],
                                needWorker: 3,
                                availableWorker: 3,
                                workerList: ["Yobel", "Mar","Vick"],
                                urlPhoto: "",
                                isFinished: false
                            ),
                            TaskItem(
                                id: 402,
                                taskType: "Pupuk granular green",
                                description: "Pupuk cap cip cup",
                                priority: "P1",
                                area: ["Hole 9"],
                                needWorker: 1,
                                availableWorker: 1,
                                workerList: ["Yobel"],
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

