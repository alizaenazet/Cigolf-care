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
                    .font(.title)
                    .fontWeight(.bold)
                Button {
                    division.isSelected = false
                } label: {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
                Spacer()
                
            }
            
            // List Jobs
//            ForEach($division.locations) { $location in
////                if location.isSelected == true {
////                    LocationSection(
////                        division: $division,
////                        location: $location,
////                        viewModel: viewModel
////                    )
////                }
//                LocationSection(
//                    division: $division,
//                    location: $location,
//                    viewModel: viewModel
//                )
//                
//            }
            
            ForEach(division.locations.indices, id: \.self) { locIndex in
                LocationSection(
                    division: $division,
                    location: $division.locations[locIndex],
                    viewModel: viewModel,
                    locIndex: locIndex, // <-- kirim index asli
                )
            }
            
//            if (!viewModel.isSelectedAllLocation(id: division.id - 1)) {
//                Button {
//                    viewModel.addLocation(id: division.id - 1)
//                } label: {
//                    Text("Tambah Lokasi")
//                        .font(.headline)
//                        .foregroundColor(.white)
//                        .padding()
//                        .frame(maxWidth: .infinity)
//                        .background(Color.green)
//                        .cornerRadius(10)
//                }
//            }
            
            Button {
                viewModel.addLocation(id: division.id - 1)
            } label: {
                Text("Tambah Lokasi")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .cornerRadius(10)
            }
            
//            Button {
//                division.locations.append(
//                    CigolfLocation(id: division.locations.count + 1)
//                )
//            } label: {
//                Text("Tambah Lokasi")
//                    .font(.headline)
//                    .foregroundColor(.white)
//                    .padding()
//                    .frame(maxWidth: .infinity)
//                    .background(Color.green)
//                    .cornerRadius(10)
//            }

            
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
    //    var jobs: [DailyJob]
    let viewModel: DailyReportViewModel
    let locIndex: Int
    
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
                    
                    location.id = viewModel.locationMap[newValue] ?? 0
                    location.name = newValue
                    
                    print("Lokasi dipilih: \(location.id) \(location.name)")
                }
                //                Text(location.name)
                //                    .font(.title2)
                //                    .fontWeight(.semibold)
                
                Button {
                    location.isSelected = false
                } label: {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
                Spacer()
                
            }
            
            JobTable()
            
            ForEach(location.jobs.indices, id: \.self) { index in
                JobRow(
                    job: $location.jobs[index],
                    number: index + 1, // increment mulai dari 1,
                    viewModel: viewModel,
                    onDelete: {
                        location.jobs.remove(at: index)
                    }
                )
            }
            
            
            Button(action: {
                viewModel.addJob(divId: division.id - 1, locId: locIndex)
//                print(location)
            }) {
                Text("Tambah Baris")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .cornerRadius(10)
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
            
            
            Text("Hari")
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .frame(width: 100, alignment: .leading)
            
            Text("Jenis Pekerjaan")
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .frame(minWidth: 150, maxWidth: .infinity, alignment: .leading)
            
            Text("Hole/Area")
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .frame(width: 100, alignment: .leading)
            
            Text("Prioritas")
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .frame(width: 100, alignment: .leading)
            
            Text("Keterangan")
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .frame(minWidth: 150, maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 8)
        
        Divider()
    }
}

struct JobRow: View {
    @Binding var job: DailyJob
    let number: Int
    let viewModel: DailyReportViewModel
    var onDelete: () -> Void
    
    @State private var days: [String] = [
        "Minggu",
        "Senin",
        "Selasa",
        "Rabu",
        "Kamis",
        "Jumat",
        "Sabtu",
    ]
    
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
            
//            TextField("Hari", text: $job.day)
//                .textFieldStyle(RoundedBorderTextFieldStyle())
//                .frame(width: 100, alignment: .leading)
            
//            Picker("Hari", selection: $job.day) {
//                
//                ForEach(days, id: \.self) { day in
//                    Text(day).tag(day)
//                }
//            }
//            .pickerStyle(MenuPickerStyle())
            
            Picker("Hari", selection: $job.day) {
                Text("Pilih").tag(nil as String?)        // placeholder
                ForEach(days, id: \.self) { day in
                    Text(day).tag(Optional(day))              // pilihan nyata
                }
            }
            .pickerStyle(MenuPickerStyle())
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
            
            TextField("Jenis Pekerjaan", text: $job.jobType)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(minWidth: 150, maxWidth: .infinity, alignment: .leading)
            
            TextField("Hole/Area", text: $job.holeArea)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 100, alignment: .leading)
            
            TextField("Prioritas", text: $job.priority)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 100, alignment: .leading)
            
            TextField("Keterangan", text: $job.description)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(minWidth: 150, maxWidth: .infinity, alignment: .leading)
            
            
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
        }
        .padding(.vertical, 4)
    }
}


#Preview {
    AddDailyProgramView(foremanId: 1)
}
