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
    let onSubmit:
        (
            _ jobType: String,
            _ locationId: Int,
            _ area: String,
            _ priority: String,
            _ description: String,
            _ neededWorkers: Int,
            _ availableWorker: Int,
            _ workerNames: String,
            _ image: UIImage?
        ) async -> Bool

    @State private var description: String
    @State private var workerNames: String
    @State private var neededWorkers: String
    @State private var availableWorkers: String
    @State private var image: UIImage?
    @State private var showImagePicker = false
    @State private var isSaving = false
    @State private var errorMessage: String?

    init(
        task: TaskDetail,
        foremanId: Int,
        locationId: Int,
        onSubmit: @escaping (
            String, Int, String, String, String, Int, Int, String, UIImage?
        ) async -> Bool
    ) {
        self.task = task
        self.foremanId = foremanId
        self.locationId = locationId
        self.onSubmit = onSubmit

        _description = State(initialValue: task.description ?? "")
        _workerNames = State(
            initialValue: task.workerList.joined(separator: ", ")
        )
        _neededWorkers = State(initialValue: "\(task.needWorker ?? 0)")
        _availableWorkers = State(initialValue: "\(task.availableWorker ?? 0)")
        _image = State(initialValue: task.image)
    }

    var body: some View {
        NavigationStack {
            VStack {
                formContent

                saveButton
            }
            .navigationTitle("Simpan Pekerjaan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(Color(hex: "#79A222"))
                        .font(.headline)
                }
            }
            .sheet(isPresented: $showImagePicker) {
                PhotoPicker(image: $image)
            }
        }
    }

    private var formContent: some View {
        Form {
            Section {
                labeledRow("Jenis Pekerjaan", value: task.taskType)
                labeledRow("Prioritas", value: "\(task.priority)")
                labeledRow(
                    "Lokasi/Hole",
                    value: task.area.joined(separator: ", ")
                )
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
                TextEditor(text: $description)
                    .frame(minHeight: 100)
                    .overlay(
                        Group {
                            if description.isEmpty {
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
    }

    private var photoPickerButton: some View {
        Button {
            showImagePicker = true
        } label: {
            HStack {
                Image(
                    systemName: image == nil
                        ? "plus" : "arrow.trianglehead.2.clockwise.rotate.90"
                )
                Text(image == nil ? "Tambah Foto" : "Ganti Foto")
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(12)
        }
    }

    private var saveButton: some View {
        VStack(spacing: 8) {
            Button(action: {
                Task {
                    guard let needed = Int(neededWorkers),
                        let available = Int(availableWorkers)
                    else { return }

                    isSaving = true
                    errorMessage = nil

                    let success = await onSubmit(
                        task.taskType,
                        locationId,
                        "\(task.area)",
                        task.priority,
                        description,
                        needed,
                        available,
                        "\([workerNames])",
                        image
                    )

                    isSaving = false
                    if success {
                        dismiss()
                    } else {
                        errorMessage = "Gagal menyimpan data"
                    }
                }
            }) {
                if isSaving {
                    ProgressView()
                        .progressViewStyle(
                            CircularProgressViewStyle(tint: .white)
                        )
                        .frame(maxWidth: .infinity)
                        .padding()
                } else {
                    HStack {
                        Image(systemName: "checkmark.circle")
                        Text("Simpan Pekerjaan")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                }
            }
            .background(Color(red: 121 / 255, green: 162 / 255, blue: 34 / 255))
            .foregroundColor(.white)
            .cornerRadius(12)
            .disabled(isSaving)

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .padding(.top, 4)
            }
        }
        .padding()
    }

    private func labeledRow(_ label: String, value: String) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text(value).foregroundColor(.secondary)
        }
    }
}

//#Preview {
//    let mockTask = TaskDetail(
//        id: 1284,
//        taskType: "Perbaiki Roda Golf Cart 24",
//        description: "Roda depan kiri macet dan tidak bisa berputar.",
//        priority: "P1",
//        area: ["Garasi", "Hole 6"],
//        needWorker: 2,
//        availableWorker: 1,
//        workerList: ["Budi", "Andi"],
//        isFinished: false,
//        image: nil
//    )
//
//    UpdateTaskView(
//        task: mockTask,
//        foremanId: 1,
//        locationId: 14
//    ) {
//        jobType,
//        locationId,
//        area,
//        priority,
//        notes,
//        neededWorkers,
//        availableWorker,
//        workerNames,
//        image in
//        print("--- Preview Save Button Tapped ---")
//        print("Job: \(jobType), Location ID: \(locationId), Area: \(area)")
//        print("Priority: \(priority), Notes: \(notes)")
//        print("Workers Needed: \(neededWorkers), Available: \(availableWorker)")
//        print("Worker Names: \(workerNames)")
//        print("Image Attached: \(image != nil)")
//    }
//}
