//
//  DailyReportView.swift
//  Palimanan-maintenance-team
//
//  Created by Yobel Nathaniel Filipus on 01/09/25.
//

import SwiftUI

struct HeaderView: View {
    let foremanId: Int

    var body: some View {
        HStack {
            Spacer()

            NavigationLink(
                destination: AddDailyProgramView(foremanId: foremanId)
            ) {
                HStack {
                    Image(systemName: "plus")
                        .foregroundStyle(.white)
                    Text("Buat Program Baru")
                        .fontWeight(.medium)
                        .font(.headline)
                        .foregroundColor(.white)
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 12)
                .background(
                    Color(red: 121 / 255, green: 162 / 255, blue: 34 / 255)
                ).cornerRadius(12)
            }
        }
    }
}

// MARK: - Filter
struct FilterView: View {
    @Binding var startDate: Date
    @Binding var endDate: Date
    @Binding var selectedIds: [Int]  // ⬅️ pindahkan ke atas
    @Binding var isExporting: Bool
    @Binding var errorMessage: String?

    var onSearch: (() -> Void)?  // ⬅️ setelah binding
    var onExport: () async -> Bool

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
                DatePicker(
                    "",
                    selection: $startDate,
                    displayedComponents: .date
                )
                .labelsHidden()

                Text("Hingga:")
                    .fontWeight(.semibold)
                    .font(.title3)
                DatePicker("", selection: $endDate, displayedComponents: .date)
                    .labelsHidden()

                Button(action: {
                    onSearch?()  // ✅ panggil callback
                }) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.white)
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(
                    Color(red: 121 / 255, green: 162 / 255, blue: 34 / 255)
                )
                .cornerRadius(12)
                
                VStack(spacing: 4) {
                    Button {
                        Task {
                            isExporting = true
                            errorMessage = nil
                            let success = await onExport()
                            isExporting = false
                            if !success {
                                errorMessage = "Gagal mengekspor data."
                            }
                        }
                    } label: {
                        if isExporting {
                            ProgressView()
                                .progressViewStyle(
                                    CircularProgressViewStyle(
                                        tint: .white
                                    )
                                )
                        } else {
                            Label(
                                "Ekspor",
                                systemImage: "square.and.arrow.up"
                            )
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(selectedIds.isEmpty || isExporting)

                    // 👇 error message
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.subheadline)
                    }
                }
                .frame(maxWidth: 150)
            }
        }
        .padding()
        .background(.white)
        .cornerRadius(20)
    }
}

struct ReportTableView: View {
    @Binding var reports: [DailyReport]  // ✅ binding
    let foremanId: Int
    @Binding var selectedIds: [Int]  // ✅ binding array id

    var allSelected: Bool {
        !reports.isEmpty && reports.allSatisfy { $0.isChecked }
    }

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
                Button(action: {
                    if allSelected {
                        // Unselect all
                        for i in reports.indices {
                            reports[i].isChecked = false
                        }
                        selectedIds.removeAll()
                    } else {
                        // Select all
                        for i in reports.indices {
                            reports[i].isChecked = true
                        }
                        selectedIds = reports.map { $0.id }
                    }
                }) {
                    Image(
                        systemName: allSelected ? "checkmark.square" : "square"
                    )
                    .foregroundColor(
                        Color(red: 121 / 255, green: 162 / 255, blue: 34 / 255)
                    )
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(.vertical, reports.isEmpty ? 8 : 0)

            Divider()

            ScrollView(.vertical) {
                LazyVStack(spacing: 8) {

                    if reports.isEmpty {
                        HStack {
                            Text("Tidak ada data yang tersedia.")
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.2))
                        )
                    } else {
                        ForEach(Array(reports.enumerated()), id: \.element.id) {
                            index,
                            report in
                            ReportRowView(
                                id: String(index + 1),
                                foremanId: foremanId,
                                report: $reports[index],
                                selectedIds: $selectedIds  // ✅ binding ke row
                            )
                        }
                    }

                }
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(.white)
        .cornerRadius(20)
        .onAppear {
            //            print("Reports:", reports.count)
        }
    }
}

// MARK: - Report Row
struct ReportRowView: View {
    let id: String
    let foremanId: Int
    @Binding var report: DailyReport  // ✅ binding
    @Binding var selectedIds: [Int]

    var body: some View {
        NavigationStack {
            HStack {
                Text("\(id)")
                    .frame(maxWidth: .infinity, alignment: .center)
                Text(DateHelper.dayConverter(day: report.day))
                    .frame(maxWidth: .infinity, alignment: .center)
                Text(DateHelper.formattedDateWithoutDay(dateStr: report.date))  // date jadi string
                    .frame(maxWidth: .infinity, alignment: .center)

                NavigationLink {
                    DailyReportDetailViewWrapper(
                        foremanId: foremanId,
                        reportId: report.id
                    )
                } label: {
                    Text("Buka Detail")
                        .bold()
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                }

                .padding(.vertical, 6)
                .padding(.horizontal, 12)
                .background(
                    Color(red: 121 / 255, green: 162 / 255, blue: 34 / 255)
                ).foregroundColor(.white)
                .cornerRadius(6)
                .frame(maxWidth: .infinity)

                Button(action: {
                    report.isChecked.toggle()
                    if report.isChecked {
                        if !selectedIds.contains(report.id) {
                            selectedIds.append(report.id)
                        }
                    } else {
                        selectedIds.removeAll { $0 == report.id }
                    }
                }) {
                    Image(
                        systemName: report.isChecked
                            ? "checkmark.square" : "square"
                    )
                    .foregroundColor(
                        Color(red: 121 / 255, green: 162 / 255, blue: 34 / 255)
                    )
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
}

struct DailyReportView: View {
    @ObservedObject var viewModel: DailyReportViewModel
    let foremanId: Int

    @State private var startDate = Date()
    @State private var endDate = Date()

    @State private var selectedIds: [Int] = []

    @State private var errorMessage: String?
    @State private var isExporting: Bool = false

    var body: some View {

        NavigationStack {
            ScrollView {
                if viewModel.isLoading {
                    ProgressView("Memuat…")
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                } else {
                    VStack {
                        // Header atas
                        HeaderView(foremanId: foremanId)
                        // Filter tanggal
                        FilterView(
                            startDate: $startDate,
                            endDate: $endDate,
                            selectedIds: $selectedIds,
                            isExporting: $isExporting,
                            errorMessage: $errorMessage,
                            onSearch: {
                                Task {
                                    await viewModel.fetchDailyReportByDateRange(
                                        for: foremanId,
                                        startDate:
                                            DateHelper.formatDateToDDMMYYYY(
                                                startDate
                                            ),
                                        endDate:
                                            DateHelper.formatDateToDDMMYYYY(
                                                endDate
                                            )
                                    )
                                }
                            },
                            onExport: {
                                guard APIService.shared.accessToken != nil
                                else {
                                    print("⚠️ No token yet, please login")
                                    return false
                                }
                                do {
                                    let ids = Array(selectedIds)
                                    let query = ids.map { String($0) }
                                        .joined(separator: ",")
                                    let endpoint =
                                        "/foreman/\(foremanId)/daily-task/export?type=csv&daily_ids=[\(query)]"

                                    print("⬇️ Downloading:", endpoint)
                                    let fileURL =
                                        try await APIService.shared
                                        .downloadFileDaily(endpoint)

                                    DispatchQueue.main.async {
                                        FilePresenter.shared.present(
                                            url: fileURL,
                                            action: .share
                                        )
                                    }
                                    return true
                                } catch {
                                    print("❌ Export failed:", error)
                                    return false
                                }
                            }
                        )

                        ReportTableView(
                            reports: $viewModel.report,
                            foremanId: foremanId,
                            selectedIds: $selectedIds
                        )

                    }
                    .padding()
                }
            }
            .background(Color.secondary.opacity(0.1))  // ✅ abu-abu rata
            .task(id: foremanId) {
                await viewModel.fetchDailyReport(for: foremanId)
            }
        }

    }
}

#Preview {
    DailyReportView(viewModel: .init(), foremanId: 1)
}
