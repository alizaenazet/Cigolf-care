//
//  AddDailyProgram.swift
//  Palimanan-maintenance-team
//
//  Created by Yobel Nathaniel Filipus on 02/09/25.
//

import SwiftUI

struct HeaderViewAddDailyProgram: View {
    
    @State var start: Date
    let foremanId: Int
    @StateObject var viewModel: DailyReportViewModel
    
    // Tambahan state untuk alert
    @State private var showConfirmation = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text("Tanggal: ")
                    .fontWeight(.regular)
                    .font(.title3)
                
                Text(start, format: Date.FormatStyle()
                    .day(.defaultDigits)
                    .month(.abbreviated)
                    .year())
                .padding(8)
                .fontWeight(.medium)
                .font(.title3)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.2))
                )
            }
            
            HStack {
                Spacer()
                Button(action: {
                    submitProgram()
                }) {
                    HStack {
                        Image(systemName: "checkmark.circle")
                            .foregroundStyle(.white)
                        Text("Simpan Program")
                            .fontWeight(.medium)
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 12)
                .background(Color(red: 121/255, green: 162/255, blue: 34/255))
                .cornerRadius(12)
            }
        }
        .alert("Error", isPresented: $showError, actions: {
            Button("OK", role: .cancel) {}
        }, message: {
            Text(errorMessage.isEmpty ? "Terjadi kesalahan" : errorMessage)
        })
        .alert("Simpan Program Harian", isPresented: $showConfirmation, actions: {
            Button("Ya") {
                Task {
                    await viewModel.createDailyProgram(foremanId: foremanId)
                    print("✅ Program harian berhasil disimpan!")
                }
            }
            Button("Batal", role: .cancel) {}
            
        }, message: {
            Text("Periode: \(DateHelper.formattedIndonesianDate(start))")
        })
        .alert("Info", isPresented: $viewModel.showSuccessAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.successMessage)
        }
    }
    
    private func submitProgram() {
        do {
            let request = try viewModel.formatToDailyProgramRequest()
            // Jika sukses, tampilkan konfirmasi
            viewModel.dailyProgramRequest = request  // ✅ simpan ke property
            showConfirmation = true
            
        } catch {
            // Tampilkan error modal
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}


struct AddDailyProgramView: View {
    let foremanId: Int
    
    @State private var start: Date = Date()
    
    @State private var division: [String: Int] = [
        "Operasional": 1,
        "Landscape": 2,
        "Projek": 3,
        "Irigasi": 4,
        "Mekanik": 5
    ]
    
    @StateObject private var viewModel = DailyReportViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                
                if (viewModel.isLoading) {
                    ProgressView("Loading…")
                }
                else {
                    VStack(spacing: 20) {
                        HeaderViewAddDailyProgram(start: start, foremanId: foremanId, viewModel: viewModel)
                        
                        DivisionListView(viewModel: viewModel)
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Buat Program Harian")
        .navigationBarTitleDisplayMode(.large)
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
                        .background(Color(red: 121/255, green: 162/255, blue: 34/255))
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
    @State private var isExpanded: Bool = true
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(division.name)
                    .font(.title)
                    .fontWeight(.bold)
                Button {
                    division.isSelected = false
                    division.locations.removeAll()
                } label: {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
                Spacer()
                
                Button {
                    withAnimation {
                        isExpanded.toggle()
                    }
                } label: {
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.up")
                        .padding(8)
                        .bold(true)
                        .foregroundColor(.black)
                        .overlay(
                            Rectangle()
                                .foregroundStyle(Color.secondary.opacity(0.2))
                                .cornerRadius(8)
                        )
                        .shadow(radius: 2)
                }
                
            }
            
            if isExpanded {
                ForEach(division.locations.indices, id: \.self) { locIndex in
                    LocationSection(
                        division: $division,
                        location: $division.locations[locIndex],
                        viewModel: viewModel,
                        locIndex: locIndex,
                        onDeleteLocation: {
                            division.locations.remove(at: locIndex)   // ✅ hapus location
                        }
                    )
                }
                
                Button {
                    viewModel.addLocation(id: division.id - 1)
                } label: {
                    Text("Tambah Lokasi")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(red: 121/255, green: 162/255, blue: 34/255))
                        .cornerRadius(10)
                }
            }
            
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct LocationSection: View {
    @Binding var division: CigolfDivision
    @Binding var location: CigolfLocation
    let viewModel: DailyReportViewModel
    let locIndex: Int
    let onDeleteLocation: () -> Void   // ✅ tambahin ini
    
    @State var selectedLocation: String = "Pilih Lokasi"
    
    @State private var locationsPicker: [String] = [
        "All",
        "Green",
        "Tee Box",
        "Fairway",
        "Apron",
        "Rough",
        "Bunker",
        "Nursery",
        "Driving Range",
        "Maingate",
        "Putting 10",
        "Paving Room",
        "Resto",
        "Mekanik",
        "Irigasi"
    ]
    
    var body: some View {
        
        VStack {
            HStack {
                Picker("Lokasi", selection: $selectedLocation) {
                    
                    Text("Pilih Lokasi")
                        .tag("Pilih Lokasi")
                        .frame(alignment: .leading)
                    
                    ForEach(locationsPicker, id: \.self) { loc in
                        Text(loc).tag(loc)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .onChange(of: selectedLocation) { newValue in
                    
                    if newValue == "Pilih Lokasi" {
                        location.id = 0
                        location.name = ""
                    } else {
                        location.id = viewModel.locationMap[newValue] ?? 0
                        location.name = newValue
                    }
                }
                .onAppear {
                    if selectedLocation == "Pilih Lokasi" {
                        location.id = 0
                        location.name = ""
                    } else {
                        location.id = viewModel.locationMap[selectedLocation] ?? 0
                        location.name = selectedLocation
                    }
                }
                
                Button {
                    onDeleteLocation()
                } label: {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
                Spacer()
                
            }
            
            JobTable()
            
//            ForEach(location.jobs.indices, id: \.self) { index in
//                JobRow(
//                    job: $location.jobs[index],
//                    number: index + 1,
//                    viewModel: viewModel, isLastRow: index == location.jobs.count - 1,
//                    onAddRow: {
//                        viewModel.addJob(divId: division.id - 1, locId: locIndex)
//                    },
//                    onDelete: {
//                        if index >= 0 && index < location.jobs.count {
//                            location.jobs.remove(at: index)
//                            if location.jobs.isEmpty {
//                                onDeleteLocation()
//                            }
//                        } else {
//                            print("⚠️ Index \(index) out of range, tidak bisa menghapus job")
//                        }
//                    }
//                )
//            }
            
            ForEach($location.jobs, id: \.id) { $job in
                JobRow(
                    job: $job,
                    number: location.jobs.firstIndex(where: { $0.id == job.id })! + 1,
                    viewModel: viewModel,
                    isLastRow: location.jobs.last?.id == job.id,
                    onAddRow: {
                        viewModel.addJob(divId: division.id - 1, locId: locIndex)
                    },
                    onDelete: {
                        if let idx = location.jobs.firstIndex(where: { $0.id == job.id }) {
                            location.jobs.remove(at: idx)
                            if location.jobs.isEmpty {
                                onDeleteLocation()
                            }
                        }
                    }
                )
            }

            
        }
        .padding()
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                .shadow(radius: 2)
        )
        
    }
}

struct JobTable : View {
    
    var body: some View {
        HStack {
            Text("Nomor")
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .frame(width: 60, alignment: .leading)
            
            Text("Jenis Pekerjaan")
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text("Hole/Area")
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .frame(width: 150, alignment: .leading)
            
            Text("Prioritas")
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .frame(width: 80, alignment: .leading)
            
            Text("Keterangan")
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 8)
        
        Divider()
    }
}

struct JobRow: View {
    @Binding var job: DailyJob
    let number: Int
    let viewModel: DailyReportViewModel
    let isLastRow: Bool
    var onAddRow: () -> Void
    var onDelete: () -> Void
    
    @State private var holes: [String] = (1...27).map { "\($0)" } + ["CH", "FC", "Villa", "Main Gate", "Driving Range", "Parkiran"]
    
    var body: some View {
        HStack {
            Text("0\(String(number))")
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .frame(width: 60, alignment: .leading)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .foregroundStyle(.secondary)
            
            TextField("Jenis Pekerjaan", text: $job.jobType)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onChange(of: job.jobType) { _ in triggerAddRowIfNeeded() } // ✅ cek otomatis
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Menu {
                ForEach(holes, id: \.self) { hole in
                    Button {
                        if job.holes.contains(hole) {
                            job.holes.removeAll { $0 == hole }
                        } else {
                            job.holes.append(hole)
                        }
                        triggerAddRowIfNeeded() // ✅ cek otomatis
                    } label: {
                        HStack {
                            Text(hole)
                            if job.holes.contains(hole) {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                Text(job.holes.isEmpty ? "Pilih" : job.holes.joined(separator: ", "))
                    .font(.subheadline)
                    .foregroundColor(job.holes.isEmpty ? .gray : .primary)
                    .frame(width: 150, alignment: .leading)
                    .padding(6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
            }
            
            Picker("Prioritas", selection: $job.priority) {
                Text("Pilih").tag("")
                ForEach(1...5, id: \.self) { value in
                    Text("\(value)").tag(String(value))
                }
            }
            .pickerStyle(MenuPickerStyle())
            .onChange(of: job.priority) { _ in triggerAddRowIfNeeded() } // ✅ cek otomatis
            .frame(width: 80, alignment: .leading)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
            
            TextField("Keterangan", text: $job.description)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onChange(of: job.description) { _ in triggerAddRowIfNeeded() } // ✅ cek otomatis
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
        }
        .padding(.vertical, 4)
    }
    
    
    private func triggerAddRowIfNeeded() {
        if isLastRow &&
            (!job.jobType.isEmpty || !job.holes.isEmpty || !job.priority.isEmpty || !job.description.isEmpty) {
            onAddRow()
        }
    }
}


#Preview {
    AddDailyProgramView(foremanId: 1)
}
