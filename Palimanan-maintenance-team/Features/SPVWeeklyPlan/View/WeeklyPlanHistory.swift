//
//  WeeklyPlanHistory.swift
//  Palimanan-maintenance-team
//
//  Created by Ali zaenal on 01/09/25.
//

import SwiftUI

struct WeeklyPlanHistory: View {
    @State private var exportedFileURL: URL?
    @State private var showShareSheet = false
    @State private var selectedWeeklyIds: Set<Int> = []
    @StateObject var viewModel = WeeklyPlanHistoryViewModel()
    @State private var errorMessage: String?
    @State private var isExporting: Bool = false

    func presentShareSheet(url: URL) {
        guard
            let root = UIApplication.shared.connectedScenes
                .compactMap({ ($0 as? UIWindowScene)?.keyWindow })
                .first?.rootViewController
        else { return }

        let vc = UIActivityViewController(
            activityItems: [url],
            applicationActivities: nil
        )
        root.present(vc, animated: true)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if viewModel.isLoading {
                    ProgressView("Memuat…")
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    VStack {
                        // This responsive filter bar is correct.
                        HStack(spacing: 12) {
                            Text("Cari Riwayat")
                                .font(.title)
                                .layoutPriority(1)

                            Spacer()

                            Text("Dari")
                                .minimumScaleFactor(0.8)

                            DatePicker(
                                "",
                                selection: $viewModel.startAt,
                                displayedComponents: .date
                            )

                            Text("Hingga")
                                .minimumScaleFactor(0.8)

                            DatePicker(
                                "",
                                selection: $viewModel.endAt,
                                displayedComponents: .date
                            )

                            Button(action: {
                                Task {
                                    await viewModel
                                        .fetchLastWeeklyPlanHistoryByFilter()
                                }
                            }) {
                                Label("", systemImage: "magnifyingglass")
                            }.buttonStyle(.borderedProminent)

                            VStack(alignment: .leading, spacing: 4) {
                                Button {
                                    Task {
                                        guard
                                            APIService.shared.accessToken != nil
                                        else {
                                            print(
                                                "⚠️ No token yet, please login"
                                            )
                                            errorMessage = "Anda belum login."
                                            return
                                        }
                                        do {
                                            isExporting = true
                                            errorMessage = nil

                                            let ids = Array(selectedWeeklyIds)
                                            let query = ids.map { String($0) }
                                                .joined(separator: ",")
                                            let endpoint =
                                                "/weekly-plan/export?type=csv&weekly_ids=[\(query)]"

                                            print("⬇️ Downloading:", endpoint)
                                            let fileURL =
                                                try await APIService.shared
                                                .downloadFile(endpoint)

                                            DispatchQueue.main.async {
                                                FilePresenter.shared.present(
                                                    url: fileURL,
                                                    action: .share
                                                )
                                            }
                                        } catch {
                                            print("❌ Export failed:", error)
                                            errorMessage = "Gagal mengekspor data."
                                        }
                                        isExporting = false
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
                                .disabled(
                                    selectedWeeklyIds.isEmpty || isExporting
                                )

                                if let errorMessage = errorMessage {
                                    Text(errorMessage)
                                        .foregroundColor(.red)
                                        .font(.subheadline)
                                }
                            }
                        }
                        .padding()
                        .background(Color(uiColor: UIColor.systemBackground))
                        .cornerRadius(16)

                        ScrollView {
                            // This view now correctly contains the logic for both features.
                            TablePreviews(
                                selectedWeeklyIds: $selectedWeeklyIds,
                                weeklyHistory: $viewModel.weeklyPlanHistoryPreview
                            )
                        }
                        .background(Color(uiColor: UIColor.systemBackground))
                        .cornerRadius(16)
                    }
                }
            }
            .padding()
            .background(Color(hex: "f4f4f4"))
            .navigationTitle("Program mingguan")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink("Buat Program Baru") {
                        CreateWeeklyPlan()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .task {
                await viewModel.fetchLastWeeklyPlanHistory()
            }
        }
    }
}

struct TablePreviews: View {
    @Binding var selectedWeeklyIds: Set<Int>
    @Binding var weeklyHistory: [WeeklyPlanPreview]
    @State private var isAllSelected: Bool = false

    private let columns: [GridItem] = [
        GridItem(.fixed(60), alignment: .leading),  // No
        GridItem(.flexible(minimum: 120), alignment: .leading),  // Tanggal Program
        GridItem(.flexible(minimum: 120), alignment: .center),  // Detail
        GridItem(.fixed(60), alignment: .center),  // Checkbox
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            LazyVGrid(columns: columns, spacing: 12) {
                // Header row
                Text("No.")
                    .font(.title3).foregroundColor(.gray).bold()
                Text("Tanggal Program")
                    .font(.title3).foregroundColor(.gray).bold()
                Text("Detail")
                    .font(.title3).foregroundColor(.gray).bold()
                Toggle(
                    "",
                    isOn: Binding(
                        get: { isAllSelected },
                        set: { newValue in
                            if newValue {
                                selectedWeeklyIds = Set(
                                    weeklyHistory.map { $0.id }
                                )
                            } else {
                                selectedWeeklyIds.removeAll()
                            }
                        }
                    )
                )
                .toggleStyle(iOSCheckboxToggleStyle())
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 16)

            Divider()
                .padding(.bottom, 4)

            // Content rows
            ForEach(weeklyHistory.indices, id: \.self) { index in
                TablePreviewRow(
                    index: index,
                    weeklyPlan: weeklyHistory[index],
                    selectedWeeklyIds: $selectedWeeklyIds,
                    columns: columns
                )
                .padding(.vertical, 4)
            }
        }
        .padding()
        .onChange(of: selectedWeeklyIds) { newSelection in
            if newSelection.count == weeklyHistory.count
                && !weeklyHistory.isEmpty
            {
                isAllSelected = true
            } else {
                isAllSelected = false
            }
        }

    }
}

struct TablePreviewRow: View {
    let index: Int
    let weeklyPlan: WeeklyPlanPreview
    @Binding var selectedWeeklyIds: Set<Int>
    let columns: [GridItem]

    var isSelected: Bool {
        selectedWeeklyIds.contains(weeklyPlan.id)
    }

    var body: some View {
        LazyVGrid(columns: columns,spacing: 12) {
            Text("\(index + 1)")
                .lineLimit(nil)  // unlimited lines
                .multilineTextAlignment(.leading)

            Text(
                "\(weeklyPlan.startDate?.toFormattedString() ?? "-") - \(weeklyPlan.endDate?.toFormattedString() ?? "-")"
            )
            .lineLimit(nil)  // unlimited lines
            .multilineTextAlignment(.leading)

            NavigationLink {
                WeeklyPlanDetailViewWrapper(weeklyId: weeklyPlan.id)
            } label: {
                Text("Buka Detail")
                    .bold()
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .lineLimit(nil)  // unlimited lines
                    .multilineTextAlignment(.leading)
            }
            .buttonStyle(.borderedProminent)
            .font(.caption2)

            Toggle(
                "",
                isOn: Binding(
                    get: { isSelected },
                    set: { newValue in
                        if newValue {
                            selectedWeeklyIds.insert(weeklyPlan.id)
                        } else {
                            selectedWeeklyIds.remove(weeklyPlan.id)
                        }
                    }
                )
            )
            .toggleStyle(iOSCheckboxToggleStyle())
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: NO CHANGES below this line

//#Preview {
//    SupervisorDashboardView()
//}

struct iOSCheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(
            action: {
                configuration.isOn.toggle()
            },
            label: {
                HStack {
                    Image(
                        systemName: configuration.isOn
                            ? "checkmark.square" : "square"
                    )
                    configuration.label
                }
            }
        )
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(
            in: CharacterSet.alphanumerics.inverted
        )
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a: UInt64
        let r: UInt64
        let g: UInt64
        let b: UInt64
        switch hex.count {
        case 3:  // RGB (12-bit)
            (a, r, g, b) = (
                255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17
            )
        case 6:  // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:  // ARGB (32-bit)
            (a, r, g, b) = (
                int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF
            )
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
