//
//  AddTaskView.swift
//  Palimanan-maintenance-team
//
//  Created by Syamsuddin Putra Riefli on 09/09/25.
//

import SwiftUI

struct AddTaskView: View {
    @Environment(\.dismiss) var dismiss

    let foremanId: Int
    let onSubmit:
        (
            _ divisionId: Int, _ locationId: Int, _ jobType: String,
            _ area: [String], _ priority: Int, _ description: String
        ) async -> Bool

    @State private var selectedDivision: Int = -1
    @State private var selectedLocation: Int = -1
    @State private var jobType: String = ""
    @State private var priority: Int = 1
    @State private var selectedHoles: Set<String> = []
    @State private var notes: String = ""
    @State private var isNewDay: Bool = false
    @State private var isSending: Bool = false
    @State private var errorMessage: String?

    private var today: String {
        DateHelper.formattedIndonesianDate(Date())
    }
    
    let availableDivisions: [String] = [
        "Operasional",
        "Landscape",
        "Projek",
        "Irigasi",
        "Mekanik"
    ]

    let availableLocations: [String] = [
        "All", "Green", "Tee Box", "Fairway", "Apron", "Rough", "Bunker", "Nursery",
        "Driving Range", "Maingate", "Putting 10", "Paving Room", "Resto",
        "Mekanik", "Irigasi",
    ]

    private var availablePriorities: [Int] {
        Array(1...5)
    }

    func holeOptions(for foremanId: Int) -> [String] {
        let mandatory = [
            "CH", "FC", "Villa", "Main Gate", "Driving Range", "Parkiran",
        ]

        switch foremanId {
        case 1: return mandatory + (1...9).map { "Hole \($0)" }
        case 2: return mandatory + (10...18).map { "Hole \($0)" }
        case 3: return mandatory + (19...27).map { "Hole \($0)" }
        default: return mandatory
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Text("Tanggal")
                        Spacer()
                        Text(today)
                            .foregroundColor(.secondary)
                    }
                    Picker("Divisi", selection: $selectedDivision) {
                        Text("Pilih Divisi").tag(-1)
                        ForEach(availableDivisions.indices, id: \.self) { index in
                            Text(availableDivisions[index])
                                .tag(index + 1)
                        }
                    }

                    Picker("Area", selection: $selectedLocation) {
                        Text("Pilih Area").tag(-1)
                        ForEach(availableLocations.indices, id: \.self) { index in
                            Text(availableLocations[index])
                                .tag(index + 1)
                        }
                    }

                }

                Section {
                    TextField("Jenis Pekerjaan", text: $jobType)

                    Picker("Prioritas", selection: $priority) {
                        ForEach(availablePriorities, id: \.self) { prio in
                            Text("\(prio)").tag(prio)
                        }
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Hole/Area")

                        Menu {
                            ForEach(holeOptions(for: foremanId), id: \.self) {
                                option in
                                Button {
                                    if selectedHoles.contains(option) {
                                        selectedHoles.remove(option)
                                    } else {
                                        selectedHoles.insert(option)
                                    }
                                } label: {
                                    HStack {
                                        Text(option)
                                        if selectedHoles.contains(option) {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        } label: {
                            HStack {
                                Text(
                                    selectedHoles.isEmpty
                                        ? "Pilih lokasi/hole"
                                        : selectedHoles.sorted().joined(
                                            separator: ", "
                                        )
                                )
                                .foregroundColor(
                                    selectedHoles.isEmpty ? .gray : .primary
                                )
                                .lineLimit(1)
                                Spacer()
                                Image(systemName: "chevron.down")
                            }
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.gray.opacity(0.5))
                            )
                        }
                    }

                }

                Section(header: Text("Catatan")) {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                        .overlay(
                            Group {
                                if notes.isEmpty {
                                    Text("Belum diisi")
                                        .foregroundColor(.gray)
                                        .padding(.horizontal, 5)
                                        .padding(.vertical, 8)
                                        .frame(
                                            maxWidth: .infinity,
                                            alignment: .leading
                                        )
                                }
                            }
                        )
                }
            }
            .navigationTitle("Tambah Pekerjaan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(Color(hex: "#79A222"))
                        .fontWeight(.bold)
                }
            }

            VStack {
                Button(action: {
                    Task {
                        guard selectedDivision != -1,
                            selectedLocation != -1, !jobType.isEmpty,
                            !selectedHoles.isEmpty
                        else { return }
                        
                        isSending = true
                        errorMessage = nil

                        let success = await onSubmit(
                            selectedDivision,
                            selectedLocation,
                            jobType,
                            Array(selectedHoles),
                            priority,
                            notes
                        )
                        
                        isSending = false
                        if success {
                            dismiss()
                        } else {
                            errorMessage = "Gagal menambahkan pekerjaan"
                        }
                    }
                }) {
                    if isSending {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        HStack {
                            Image(systemName: "checkmark.circle")
                            Text("Tambah Pekerjaan")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                    }
                }
                .background(
                        (selectedDivision == -1 || selectedLocation == -1 || jobType.isEmpty || selectedHoles.isEmpty)
                        ? Color.gray
                        : Color(red: 121/255, green: 162/255, blue: 34/255)
                    )
                .foregroundColor(.white)
                .cornerRadius(12)
                .disabled(selectedDivision == -1 || selectedLocation == -1 || jobType.isEmpty || selectedHoles.isEmpty || isSending)
                .padding()
            }
        }
    }
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

//#Preview {
//    AddTaskView(
//        foremanId: 1,
//        onSubmit: { divisionId, locationId, jobType, area, priority, notes in
//            print("--- Preview Submit Button Tapped ---")
//            print("Division: \(divisionId), Location: \(locationId), Job: \(jobType)")
//            print("Area: \(area), Priority: \(priority), Notes: \(notes)")
//        }
//    )
//}
