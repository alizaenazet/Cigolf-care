//
//  DailyReportView.swift
//  Palimanan-maintenance-team
//
//  Created by Yobel Nathaniel Filipus on 01/09/25.
//

import SwiftUI

struct DailyReportView: View {
    @ObservedObject var viewModel: DailyReportViewModel
    let foremanId: Int
    
    @State private var startDate = Date()
    @State private var endDate = Date()
    
    @State var rows: [TableRow] = [
        .init(nomor: "01", hari: "Senin", tanggal: "1 Agustus 2025"),
        .init(nomor: "02", hari: "Selasa", tanggal: "2 Agustus 2025"),
        .init(nomor: "03", hari: "Rabu", tanggal: "3 Agustus 2025"),
        .init(nomor: "04", hari: "Kamis", tanggal: "4 Agustus 2025"),
        .init(nomor: "05", hari: "Jumat", tanggal: "5 Agustus 2025"),
        .init(nomor: "06", hari: "Sabtu", tanggal: "6 Agustus 2025"),
        .init(nomor: "07", hari: "Minggu", tanggal: "7 Agustus 2025"),
        .init(nomor: "08", hari: "Senin", tanggal: "8 Agustus 2025"),
        .init(nomor: "08", hari: "Senin", tanggal: "8 Agustus 2025"),
        .init(nomor: "08", hari: "Senin", tanggal: "8 Agustus 2025"),
    ]
    
    var body: some View {
        VStack {
            // Header atas
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Penyedia Tenaga Kerja: PT YOBEL SEHAT")
                        .fontWeight(.regular)
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("Area: Lembah, CH, FC, VILLA, FC")
                        .fontWeight(.regular)
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                
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
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(.green)
                .cornerRadius(12)
            }
            
            // Filter tanggal
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
                    
                    Button(action: {}) {
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
            .background(.secondary.opacity(0.05))
            .cornerRadius(20)
            
            // Tabel
            GeometryReader { geo in
                let totalWidth = geo.size.width
                
                VStack {
                    // Header tabel
                    HStack {
                        Text("Nomor").bold()
                            .frame(width: totalWidth * 0.15, alignment: .center)
                        Text("Hari").bold()
                            .frame(width: totalWidth * 0.15, alignment: .center)
                        Text("Tanggal").bold()
                            .frame(width: totalWidth * 0.25, alignment: .center)
                        Text("Detail").bold()
                            .frame(width: totalWidth * 0.25, alignment: .center)
                        
                        Image(systemName: "square")
                            .foregroundColor(.green).frame(width: totalWidth * 0.15, alignment: .center)
                    }
                    .padding(.vertical, 8)
                    
                    Divider()
                    
                    // Rows dengan scroll
                    ScrollView(.vertical) {
                        LazyVStack(spacing: 8) {
                            ForEach(rows.indices, id: \.self) { index in
                                HStack {
                                    Text(rows[index].nomor)
                                        .frame(width: totalWidth * 0.15, alignment: .center)
                                    Text(rows[index].hari)
                                        .frame(width: totalWidth * 0.15, alignment: .center)
                                    Text(rows[index].tanggal)
                                        .frame(width: totalWidth * 0.25, alignment: .center)
                                    
                                    Button("Buka Detail") {
                                        print("Detail tapped for \(rows[index].nomor)")
                                    }
                                    .padding(.vertical, 6)
                                    .padding(.horizontal, 12)
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(6)
                                    .frame(width: totalWidth * 0.25)
                                    
                                    Button(action: {
                                        rows[index].isChecked.toggle()
                                    }) {
                                        Image(systemName: rows[index].isChecked ? "checkmark.square" : "square")
                                            .foregroundColor(.green)
                                    }
                                    .frame(width: totalWidth * 0.15)
                                    .buttonStyle(PlainButtonStyle())
                                }
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray.opacity(0.2))
                                )
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    //                    .frame(height: geo.size.height * 0.5) // tinggi tabel setengah layar
                }
            }
            .padding()
            .cornerRadius(20)
            .background(.gray.opacity(0.05))
        }
        .padding()
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

