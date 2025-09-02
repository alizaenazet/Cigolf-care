//
//  DailyReportView.swift
//  Palimanan-maintenance-team
//
//  Created by Yobel Nathaniel Filipus on 01/09/25.
//

import SwiftUI

struct HeaderView: View {
    var body: some View {
        HStack {
            
            Spacer()
            
            Button(action: {}) {
                HStack {
                    Image(systemName: "plus")
                        .foregroundStyle(.white)
                    Text("Buat Program Baru")
                        .fontWeight(.medium)
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 12)
            .background(.green)
            .cornerRadius(12)
        }
    }
}

// MARK: - Filter
struct FilterView: View {
    @Binding var startDate: Date
    @Binding var endDate: Date
    var onSearch: (() -> Void)?   // ✅ callback
    
    
    var body: some View {
        HStack {
            Text("Cari Riwayat")
                .fontWeight(.bold)
                .font(.title)
            
            Spacer()
            
            HStack {
                Text("Dari:")
                    .fontWeight(.semibold)
                    .font(.title3)
                DatePicker("", selection: $startDate, displayedComponents: .date)
                    .labelsHidden()
                
                Text("Hingga:")
                    .fontWeight(.semibold)
                    .font(.title3)
                DatePicker("", selection: $endDate, displayedComponents: .date)
                    .labelsHidden()
                
                Button(action: {
                    onSearch?() // ✅ panggil callback
                }) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.white)
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(.green)
                .cornerRadius(12)
                
                Button(action: {}) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundStyle(.white)
                        Text("Export")
                            .fontWeight(.medium)
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(.green)
                .cornerRadius(12)
            }
        }
        .padding()
        .background(.white)
        .cornerRadius(20)
    }
}

struct ReportTableView: View {
    @Binding var reports: [DailyReport]  // ✅ binding
    
    var body: some View {
        
        VStack {
            // Header tabel
            HStack {
                Text("Nomor").bold()
                    .frame(maxWidth: .infinity, alignment: .center)
                Text("Hari").bold()
                    .frame(maxWidth: .infinity, alignment: .center)
                Text("Tanggal").bold()
                    .frame(maxWidth: .infinity, alignment: .center)
                Text("Detail").bold()
                    .frame(maxWidth: .infinity, alignment: .center)
                Image(systemName: "square")
                    .foregroundColor(.green)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(.vertical, reports.isEmpty ? 8 : 0)
            
            Divider()
            
            ScrollView(.vertical) {
                LazyVStack(spacing: 8) {
                    ForEach(Array(reports.enumerated()), id: \.element.id) { index, report in
                        ReportRowView(
                            id: String(index + 1),
                            report: $reports[index] // ✅ binding ke row
                        )
                    }                }
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(.white)
        .cornerRadius(20)
        .onAppear {
            print("Reports:", reports.count)
        }
    }
}


// MARK: - Report Row
struct ReportRowView: View {
    let id: String
    @Binding var report: DailyReport // ✅ binding
    
    var body: some View {
        HStack {
            Text("\(id)")
                .frame(maxWidth: .infinity, alignment: .center)
            Text(DateHelper.dayConverter(day: report.day))
                .frame(maxWidth: .infinity, alignment: .center)
            Text(DateHelper.formattedDateWithoutDay(dateStr: report.date)) // date jadi string
                .frame(maxWidth: .infinity, alignment: .center)
            
            Button("Buka Detail") {
                print("Detail tapped for \(report.id)")
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 12)
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(6)
            .frame(maxWidth: .infinity)
            
            Button(action: {
                report.isChecked.toggle() // ✅ toggle centang
                print("Checkbox tapped for \(report.id)")
            }) {
                Image(systemName: report.isChecked ? "checkmark.square" : "square")
                    .foregroundColor(.green)
            }
            .frame(maxWidth: .infinity)
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.2))
        )
    }
}


struct DailyReportView: View {
    @ObservedObject var viewModel: DailyReportViewModel
    let foremanId: Int
    
    @State private var startDate = Date()
    @State private var endDate = Date()
    
    var body: some View {
        
        ScrollView {
            if viewModel.isLoading {
                ProgressView("Loading…")
                    .padding()
            } else if viewModel.report.count != 0 {
                VStack {
                    // Header atas
                    HeaderView()
                    // Filter tanggal
                    FilterView(startDate: $startDate, endDate: $endDate) {
                        Task {
                            await viewModel.fetchDailyReportByDateRange(
                                for: foremanId,
                                startDate: DateHelper.formatDateToDDMMYYYY(startDate),
                                endDate: DateHelper.formatDateToDDMMYYYY(endDate),
                            )
                        }
                    }
                    
                    ReportTableView(reports: $viewModel.report)

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
        .background(Color.secondary.opacity(0.1)) // ✅ abu-abu rata
        .task(id: foremanId) {
            await viewModel.fetchDailyReport(for: foremanId)
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
