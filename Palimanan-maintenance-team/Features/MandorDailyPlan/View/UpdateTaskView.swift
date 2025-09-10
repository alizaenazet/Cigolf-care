//
//  AddTaskView.swift
//  Palimanan-maintenance-team
//
//  Created by Syamsuddin Putra Riefli on 09/09/25.
//

import SwiftUI

struct UpdateTaskView: View {
    @Environment(\.dismiss) var dismiss

    let task: TaskDetail
    let foremanId: Int
    let locationId: Int
    let onSubmit: (
        _ jobType: String,
        _ locationId: Int,
        _ area: String,
        _ priority: String,
        _ notes: String,
        _ neededWorkers: Int,
        _ availableWorker: Int,
        _ workerNames: String,
        _ image: UIImage?
    ) -> Void

    // Inputs
    @State private var notes: String = ""
    @State private var workerNames: String = ""
    @State private var neededWorkers: String = ""
    @State private var availableWorkers: String = ""
    @State private var image: UIImage? = nil
    @State private var showImagePicker = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                formContent

                saveButton
            }
            .navigationTitle("Simpan Pekerjaan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.green)
                }
            }
            .sheet(isPresented: $showImagePicker) {
                PhotoPicker(image: $image)
            }
        }
    }

    // MARK: - Subviews

    private var formContent: some View {
        Form {
            Section {
                labeledRow("Jenis Pekerjaan", value: task.taskType)
                labeledRow("Prioritas", value: "\(task.priority)")
                labeledRow("Lokasi/Hole", value: task.area.joined(separator: ", "))
            }

            Section(header: Text("Tenaga Kerja")) {
                TextField("Nama Tenaga Kerja", text: $workerNames)
            }

            Section {
                TextField("Jumlah TK Diminta", text: $neededWorkers)
                    .keyboardType(.numberPad)
                TextField("Jumlah TK Tersedia", text: $availableWorkers)
                    .keyboardType(.numberPad)
            }

            Section(header: Text("Dokumentasi Pekerjaan")) {
                photoPickerButton

                if let img = image {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .padding(.top, 4)
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
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    )
            }
        }
    }

    private var photoPickerButton: some View {
        Button {
            showImagePicker = true
        } label: {
            HStack {
                Image(systemName: image == nil ? "plus" : "arrow.trianglehead.2.clockwise.rotate.90")
                Text(image == nil ? "Tambah Foto" : "Ganti Foto")
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(12)
        }
    }

    private var saveButton: some View {
        Button(action: {
            guard let needed = Int(neededWorkers),
                  let available = Int(availableWorkers)
            else { return }

            onSubmit(
                task.taskType,
                locationId,
                "\(task.area)",
                task.priority,
                notes,
                needed,
                available,
                "\([workerNames])",
                image
            )
            dismiss()
            print(task.area.joined(separator: ", "))
        }) {
            HStack {
                Image(systemName: "checkmark.circle")
                Text("Simpan Pekerjaan")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(red: 121/255, green: 162/255, blue: 34/255))
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .padding()
    }

    // Helper for rows
    private func labeledRow(_ label: String, value: String) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text(value).foregroundColor(.secondary)
        }
    }
}

// --- PREVIEW CODE ADDED HERE ---
#Preview {
    // 1. Create a mock 'TaskDetail' object to pass into the view.
    let mockTask = TaskDetail(
        id: 1284,
        taskType: "Perbaiki Roda Golf Cart 241",
        description: "Roda depan kiri macet dan tidak bisa berputar.",
        priority: "P1",
        area: ["Garasi", "Hole 6"],
        needWorker: 2,
        availableWorker: 1,
        workerList: ["Budi"],
        isFinished: false
    )
    
    // 2. Initialize the UpdateTaskView with the mock data.
    return UpdateTaskView(
        task: mockTask,
        foremanId: 1, // Dummy foremanId
        locationId: 14 // Dummy locationId
    ) { jobType, locationId, area, priority, notes, neededWorkers, availableWorker, workerNames, image in
        // The onSubmit closure can be empty or print for preview purposes.
        print("--- Preview Save Button Tapped ---")
        print("Job: \(jobType), Location ID: \(locationId), Area: \(area)")
        print("Priority: \(priority), Notes: \(notes)")
        print("Workers Needed: \(neededWorkers), Available: \(availableWorker)")
        print("Worker Names: \(workerNames)")
        print("Image Attached: \(image != nil)")
    }
}
