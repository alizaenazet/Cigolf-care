//
//  AddTaskPopup.swift
//  Palimanan-maintenance-team
//
//  Created by Syamsuddin Putra Riefli on 31/08/25.
//

import SwiftUI

struct SelectedContext: Identifiable {
    let id = UUID()
    let division: Division
    let location: Location
    let foreman: ForemanMenu
}

struct AddTaskPopup: View {
    @Binding var isPresented: Bool
    let division: Division
    let location: Location
    let foreman: ForemanMenu
    let onSubmit: (_ jobType: String, _ area: [String], _ priority: Int, _ description: String) -> Void
    let onClose: () -> Void
    
    // Form states
    @State private var jobType: String = ""
    @State private var selectedHoles: Set<Int> = []
    @State private var priority: String = "P1"
    @State private var notes: String = ""
    
    let priorities = ["P1", "P2", "P3", "P4", "P5"]
    
    var body: some View {
        
        VStack(spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Tambah Pekerjaan")
                        .font(.title2).bold()
                    Text("\(foreman.title) | \(foreman.holeRange.first!)-\(foreman.holeRange.last!)")
                        .font(.subheadline)
                    Text("Divisi : \(division.name)")
                        .font(.subheadline).foregroundColor(.gray)
                }
                Spacer()
                Button(action: { isPresented = false }) {
                    Image(systemName: "xmark")
                        .font(.title3).bold()
                        .foregroundColor(.gray)
                }
            }
            
            Divider()
            
            // Jenis Pekerjaan
            VStack(alignment: .leading, spacing: 4) {
                Text("Jenis Pekerjaan")
                TextField("Isi jenis pekerjaan", text: $jobType)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            // Hole/Area (Multi-select dropdown)
            VStack(alignment: .leading, spacing: 4) {
                Text("Hole/Area")
                
                Menu {
                    ForEach(foreman.holeRange, id: \.self) { hole in
                        Button {
                            if selectedHoles.contains(hole) {
                                selectedHoles.remove(hole)
                            } else {
                                selectedHoles.insert(hole)
                            }
                        } label: {
                            HStack {
                                Text("Hole \(hole)")
                                if selectedHoles.contains(hole) {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack {
                        Text(selectedHoles.isEmpty ? "Pilih hole" :
                                selectedHoles.map { String($0) }.joined(separator: ", "))
                        .foregroundColor(selectedHoles.isEmpty ? .gray : .primary)
                        Spacer()
                        Image(systemName: "chevron.down")
                    }
                    .padding(8)
                    .background(RoundedRectangle(cornerRadius: 6).stroke(Color.gray.opacity(0.5)))
                }
            }
            
            // Prioritas
            VStack(alignment: .leading, spacing: 4) {
                Text("Prioritas")
                Picker("Prioritas", selection: $priority) {
                    ForEach(priorities, id: \.self) { pr in
                        Text(pr).tag(pr)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(8)
                .background(RoundedRectangle(cornerRadius: 6).stroke(Color.gray.opacity(0.5)))
            }
            
            // Keterangan
            VStack(alignment: .leading, spacing: 4) {
                Text("Keterangan Tambahan")
                TextEditor(text: $notes)
                    .frame(minHeight: 100) // 👈 make it taller
                    .padding(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.gray.opacity(0.5))
                    )
                    .background(Color.white)
            }
            
            // Submit Button
            Button(action: {
                let priorityValue = Int(priority.dropFirst()) ?? 1 // "P1" → 1
                onSubmit(jobType, selectedHoles.map { String($0) }, priorityValue, notes)
            }) {
                Text("Submit")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.top, 8)
            
        }
        .padding(.all, 25)
    }
}
