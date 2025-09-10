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
    
    func presentShareSheet(url: URL) {
        guard let root = UIApplication.shared.connectedScenes
            .compactMap({ ($0 as? UIWindowScene)?.keyWindow })
            .first?.rootViewController else { return }

        let vc = UIActivityViewController(activityItems: [url], applicationActivities: nil)
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
                    HStack {
                        Text("Cari Riwayat")
                            .font(.title)
                        Spacer()
                        HStack {
                            Spacer()
                            Text("Dari")
                            DatePicker(
                                "",
                                selection: $viewModel.startAt,
                                displayedComponents: .date
                            )
                            .frame(width: 131)
                            Text("Hingga")
                            DatePicker(
                                "",
                                selection: $viewModel.endAt,
                                displayedComponents: .date
                            )
                            .frame(width: 131)

                            Button(action: {
                                Task {
                                    await viewModel
                                        .fetchLastWeeklyPlanHistoryByFilter()
                                }
                            }) {
                                Label("", systemImage: "magnifyingglass")
                            }.buttonStyle(.borderedProminent)

                            Button("Ekspor", systemImage: "square.and.arrow.up")
                            {
                                Task {
                                    guard APIService.shared.accessToken != nil
                                    else {
                                        print("⚠️ No token yet, please login")
                                        return
                                    }
                                    do {
                                        // Reset old file before starting
                                        exportedFileURL = nil
                                        showShareSheet = false

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
                                            FilePresenter.shared.present(url: fileURL, action: .share)
                                        }
                                    } catch {
                                        print("❌ Export failed:", error)
                                    }
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(selectedWeeklyIds.isEmpty)

                        }
                        .frame(width: 800)
                    }
                    .padding()
                    .background(Color(uiColor: UIColor.systemBackground))
                    .cornerRadius(16)
                    ScrollView {
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
                print(
                    "fetchLastWeeklyPlanHistory",
                    viewModel.weeklyPlanHistoryPreview
                )

                print("\n\n", viewModel.startAt, viewModel.endAt)
            }
        }
    }
}

struct TablePreviews: View {
    @Binding var selectedWeeklyIds: Set<Int>
    @Binding var weeklyHistory: [WeeklyPlanPreview]
    var body: some View {
        VStack {
            HStack(spacing: 100) {

                Text("No")
                    .frame(width: 53, alignment: .leading)
                    .font(.title3)
                    .foregroundColor(.gray)
                Text("Tanggal Program")
                    .frame(width: 325, alignment: .leading)
                    .font(.title3)
                    .foregroundColor(.gray)

                Spacer()
                Text("Detail")
                    .frame(width: 88, alignment: .center)
                    .font(.title3)
                    .foregroundColor(.gray)
                Spacer()
                Text("Pilih")
                    .frame(width: 55, alignment: .center)
                    .font(.title3)
                    .foregroundColor(.gray)
            }
            Divider()

            ForEach(weeklyHistory.indices, id: \.self) { index in
                TablePreviewRow(
                    index: index,
                    weeklyPlan: weeklyHistory[index],
                    selectedWeeklyIds: $selectedWeeklyIds
                )
            }

        }.padding()
    }
}

struct TablePreviewRow: View {
    let index: Int
    let weeklyPlan: WeeklyPlanPreview
    @Binding var selectedWeeklyIds: Set<Int>
    //    @State private var isToggled = false

    var isSelected: Bool {
        selectedWeeklyIds.contains(weeklyPlan.id)
    }

    var body: some View {
        HStack(spacing: 100) {

            Text("\(index + 1)")
                .frame(width: 53, alignment: .leading)
            Text("\(weeklyPlan.startDate?.toFormattedString() ?? "-") - \(weeklyPlan.endDate?.toFormattedString() ?? "-")")
                .frame(width: 325, alignment: .leading)
            Spacer()
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
            .frame(width: 128, alignment: .center)
            Spacer()
            //            Toggle("", isOn: $isToggled)
            //                .toggleStyle(iOSCheckboxToggleStyle())
            //                .frame(width: 45, alignment: .center)
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
            .frame(width: 45, alignment: .center)
        }
    }
}

#Preview {
    WeeklyPlanHistory()
}

struct iOSCheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        // 1
        Button(
            action: {

                // 2
                configuration.isOn.toggle()

            },
            label: {
                HStack {
                    // 3
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
