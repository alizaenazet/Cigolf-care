//
//  WeeklyPlanHistory.swift
//  Palimanan-maintenance-team
//
//  Created by Ali zaenal on 01/09/25.
//

import SwiftUI

struct WeeklyPlanHistory: View {
    @StateObject var viewModel = WeeklyPlanHistoryViewModel()
    var body: some View {
        NavigationStack {
            VStack(spacing: 20){
                if viewModel.isLoading {
                    ProgressView("Loading…")
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    HStack{
                        Text("Cari Riwayat")
                            .font(.title)
                        Spacer()
                        HStack(){
                            Spacer()
                            Text("Dari")
                            DatePicker("", selection: $viewModel.startAt, displayedComponents: .date)
                                .frame(width: 131)
                            Text("Hingga")
                            DatePicker("", selection: $viewModel.endAt, displayedComponents: .date)
                                .frame(width: 131)
                            
                            Button(action: {
                                Task{
                                    await viewModel.fetchLastWeeklyPlanHistoryByFilter()
                                }
                            }){
                                Label("", systemImage: "magnifyingglass")
                            }.buttonStyle(.borderedProminent)
                            
                            Button("Export", systemImage: "square.and.arrow.up", action: {}).buttonStyle(.borderedProminent)
                            
                        }
                        .frame(width: 800)
                    }
                    .padding()
                    .background(Color(uiColor: UIColor.systemBackground) )
                    .cornerRadius(16)
                    ScrollView{
                        TablePreviews(
                            weeklyHistory: $viewModel.weeklyPlanHistoryPreview
                        )
                    }
                    .background(Color(uiColor: UIColor.systemBackground) )
                    .cornerRadius(16)
                }
            }
            .padding()
            .background(Color(hex: "f4f4f4"))
            .navigationTitle("Program mingguan")
            .toolbar{
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink("Buat Program Baru") {
                        CreateWeeklyPlan()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .task {
                await viewModel.fetchLastWeeklyPlanHistory()
                print("fetchLastWeeklyPlanHistory", viewModel.weeklyPlanHistoryPreview)
                
                print("\n\n", viewModel.startAt, viewModel.endAt)
            }
        }
    }
}

struct TablePreviews: View {
    @Binding var weeklyHistory: [WeeklyPlanPreview]
    var body: some View {
        VStack{
            HStack(spacing:100){
                
                Text("No")
                    .frame(width: 53, alignment: .leading)
                    .font(.title3)
                    .foregroundColor(.gray)
                Text("Tanggal Program")
                    .frame(width: 262, alignment: .leading)
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
            
            ForEach(weeklyHistory) { history in
                TablePreviewRow(index: 0, weeklyPlan: history)
            }
            
        }.padding()
    }
}

struct TablePreviewRow: View {
    let index: Int
    let weeklyPlan: WeeklyPlanPreview
    @State private var isToggled = false
    
    var body : some View {
        HStack(spacing:100){
            
            Text("\(index + 1)")
                .frame(width: 53, alignment: .leading)
            Text("\(weeklyPlan.startDate?.toFormattedString() ?? "-") - \(weeklyPlan.endDate?.toFormattedString() ?? "-")")
                .frame(width: 292, alignment: .leading)
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
            Toggle("", isOn: $isToggled)
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
        Button(action: {
            
            // 2
            configuration.isOn.toggle()
            
        }, label: {
            HStack {
                // 3
                Image(systemName: configuration.isOn ? "checkmark.square" : "square")
                
                configuration.label
            }
        })
    }
}


extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
