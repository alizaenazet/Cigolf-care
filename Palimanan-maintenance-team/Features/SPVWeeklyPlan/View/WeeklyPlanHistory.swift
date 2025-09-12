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
                    ProgressView("Loading…")
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
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


// =================================================================
// MARK: CORRECTED SECTION - TablePreviews with "Select All" Logic
// =================================================================

struct TablePreviews: View {
    @Binding var selectedWeeklyIds: Set<Int>
    @Binding var weeklyHistory: [WeeklyPlanPreview]
    
    // MARK: FIX 1 - The Missing State Variable
    // This was the piece of code lost during the merge. It's needed to
    // track the state of the "select all" checkbox in the header.
    @State private var isAllSelected: Bool = false
    
    var body: some View {
        Grid(alignment: .leading, horizontalSpacing: 20, verticalSpacing: 15) {
            
            // The responsive GridRow header is correct.
            GridRow {
                Text("No")
                    .font(.title3)
                    .foregroundColor(.gray)

                Text("Tanggal Program")
                    .font(.title3)
                    .foregroundColor(.gray)

                Text("Detail")
                    .font(.title3)
                    .foregroundColor(.gray)
                    .gridColumnAlignment(.center)
                
                // MARK: FIX 2 - Teammate's "Select All" Checkbox
                // This code implements your teammate's feature. It now works
                // because it's correctly bound to the `isAllSelected` state variable.
                Toggle(
                    "",
                    isOn: Binding(
                        get: { isAllSelected },
                        set: { newValue in
                            // This logic is correct: when the toggle changes,
                            // select or deselect all items.
                            if newValue {
                                selectedWeeklyIds = Set(weeklyHistory.map { $0.id })
                            } else {
                                selectedWeeklyIds.removeAll()
                            }
                        }
                    )
                )
                .toggleStyle(iOSCheckboxToggleStyle())
                .gridColumnAlignment(.center)
            }
            .bold()

            Divider()
            
            // The ForEach loop for rows is correct.
            ForEach(weeklyHistory.indices, id: \.self) { index in
                GridRow(alignment: .center) {
                    TablePreviewRow(
                        index: index,
                        weeklyPlan: weeklyHistory[index],
                        selectedWeeklyIds: $selectedWeeklyIds
                    )
                }
                Divider()
            }
        }
        .padding()
        // MARK: FIX 3 - State Synchronization
        // This modifier is crucial. It watches for changes in the individual
        // row selections and updates the header checkbox accordingly. This part
        // was present but didn't work without the @State variable.
        .onChange(of: selectedWeeklyIds) { newSelection in
            if newSelection.count == weeklyHistory.count && !weeklyHistory.isEmpty {
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

    var isSelected: Bool {
        selectedWeeklyIds.contains(weeklyPlan.id)
    }

    var body: some View {
        // Your responsive GridRow content is correct.
        Text("\(index + 1)")
        
        Text(
            "\(weeklyPlan.startDate?.toFormattedString() ?? "-") - \(weeklyPlan.endDate?.toFormattedString() ?? "-")"
        )
        
        NavigationLink {
            WeeklyPlanDetailViewWrapper(weeklyId: weeklyPlan.id)
        } label: {
            Text("Buka Detail")
                .bold()
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
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
}


// MARK: NO CHANGES below this line

#Preview {
    SupervisorDashboardView()
}

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
