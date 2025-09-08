//
//  CreateWeeklyPlan.swift
//  Palimanan-maintenance-team
//
//  Created by Ali zaenal on 02/09/25.
//
import SwiftUI

struct CreateWeeklyPlan: View {
    @ObservedObject var viewModel = CreateWeeklyPlanViewModel()
    @State private var showSaveConfirmation = false
    @State private var expandedDivisions: Set<Int> = []
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header Section
                headerSection

                // Main Content: Division List
                mainContentSection

                // Footer Section
                footerSection
            }
            .padding()
        }
        .background(Color.gray.opacity(0.1))
        .navigationTitle("Buat Program Mingguan")
        .alert("Konfirmasi Simpan", isPresented: $showSaveConfirmation) {
            Button("Batal", role: .cancel) {}
            Button("Simpan") {
                viewModel.createWeeklyPlan() {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        } message: {
            Text("Apakah Anda yakin ingin menyimpan program mingguan ini?")
        }
    }

    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading) {
    
            
            HStack() {
                HStack(){
                    Text("Dari")
                        .fontWeight(.semibold)
                        .font(.title3)
                    DatePicker("", selection: $viewModel.startAt, displayedComponents: .date)
                        .labelsHidden()
                        .padding(9)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(6)
                    
                    Text("Hingga")
                        .fontWeight(.semibold)
                        .font(.title3)
                    DatePicker("", selection: $viewModel.endAt, displayedComponents: .date)
                        .labelsHidden()
                        .padding(9)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(6)
                }
                Spacer()
                Button("Simpan Program") {
                    showSaveConfirmation = true
                }
                .buttonStyle(.borderedProminent)
                .tint(.accent)
            }
        }
    }

    // MARK: - Main Content Section
    private var mainContentSection: some View {
        VStack(spacing: 15) {
            ForEach(viewModel.divisions, id: \.id) { division in
                DisclosureGroup(
                    isExpanded: Binding(
                        get: { expandedDivisions.contains(division.id) },
                        set: { isExpanded in
                            if isExpanded {
                                expandedDivisions.insert(division.id)
                            } else {
                                expandedDivisions.remove(division.id)
                            }
                        }
                    )
                ) {
                    divisionContent(for: division)
                } label: {
                    HStack {
                        Menu {
                            // Current division option
                            Button(division.name) {
                                // Already selected, no action needed
                            }
                            .disabled(true)

                            if !viewModel.getAvailableDivisions().isEmpty {
                                Divider()

                                // Available divisions
                                ForEach(
                                    viewModel.getAvailableDivisions(),
                                    id: \.id
                                ) { availableDivision in
                                    Button(availableDivision.name) {
                                        changeDivision(
                                            division,
                                            to: availableDivision
                                        )
                                    }
                                }
                            }
                        } label : {
                            HStack() {
                                Text(division.name)
                                    .font(.title2)
                                    .fontWeight(.medium)
                                    .multilineTextAlignment(.leading)
                                    .foregroundStyle(.black)
                            }
                            .frame(width: 120, alignment: .leading)
                            .padding(6)
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(6)
                        }
                        .buttonStyle(.plain)
                        Spacer()

                        Button {
                            viewModel.deleteDivision(DivisionId: division.id)
                        } label: {
//                            Image(systemName: "xmark")
//                                .font(.title3)
//                                .foregroundColor(.white.opacity(0.6))
                            Text("Hapus")
                                .foregroundStyle(.red)
                                .underline()
                                .padding(.horizontal, 10)
                            
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(8)
            }
        }
        .onAppear {
            // Initialize all divisions to be expanded by default
            for division in viewModel.divisions {
                expandedDivisions.insert(division.id)
            }
        }
    }

    // MARK: - Division Content
    private func divisionContent(for division: WeeklyDivision) -> some View {
        VStack(spacing: 10) {
            ForEach(division.locations, id: \.locationId) { location in
                locationSection(for: location, in: division)
            }
            
            Button {
                addLocationToDivision(division)
            } label: {
                Text("Tambah Lokasi")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accent)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .animation(nil)
            }
            .transition(.opacity)
        }
        .padding(.top)
    }

    // MARK: - Location Section
    private func locationSection(
        for location: DivisionLocation,
        in division: WeeklyDivision
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Menu {
                    // Current location option
                    Button(location.location) {
                        // Already selected, no action needed
                    }
                    .disabled(true)

                    if !division.getAvailableLocation().isEmpty {
                        Divider()

                        // Available locations
                        ForEach(division.getAvailableLocation(), id: \.self) {
                            availableLocation in
                            Button(availableLocation) {
                                changeLocationForDivisionLocation(
                                    location,
                                    to: availableLocation,
                                    in: division
                                )
                            }
                        }
                    }
                } label: {
                    HStack() {
                        Text(location.location)
                            .font(.title3)
                            .fontWeight(.medium)
                            .multilineTextAlignment(.leading)
                    }
                    .frame(width: 150, alignment: .leading)
                    .padding(6)
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(10)
                    .shadow(radius: 2)
                }
                .disabled(division.getAvailableLocation().isEmpty)
                
                Spacer()
                Button {
                    division.deleteLocation(locationId: location.locationId)
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title)
                        .foregroundStyle(.gray.opacity(0.3))
                }
                .buttonStyle(.plain)
                
            }
            .padding(.horizontal)
            .padding(.vertical, 5)

            // Task Headers
            HStack(spacing: 10) {
                Text("Nomor")
                    .frame(width: 55, alignment: .leading)
                    .font(.body)
                    .foregroundColor(.secondary)

                Text("Jenis Pekerjaan")
                    .frame(width: 550, alignment: .leading)
                    .font(.body)
                    .foregroundColor(.secondary)

                Text("Hole/Area")
                    .frame(width: 250, alignment: .center)
                    .font(.body)
                    .foregroundColor(.secondary)

                Text("Hari")
                    .frame(width: 100, alignment: .center)
                    .font(.body)
                    .foregroundColor(.secondary)

                Text("Keterangan")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .font(.body)
                    .foregroundColor(.secondary)

                Text("")
                    .frame(width: 30)
            }
            .padding(.horizontal)

            Divider()

            // Task Rows
            ForEach(location.tasks.indices, id: \.self) { index in
                taskRow(for: location.tasks[index], at: index, in: location)
            }
        }
        .padding()
        .background(Color.white.opacity(0.01))
        .clipShape(.rect(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(.gray.opacity(0.15), lineWidth: 2)
        )
    }

    // MARK: - Task Row
    private func taskRow(
        for task: DivisionTask,
        at index: Int,
        in location: DivisionLocation
    ) -> some View {
        HStack(spacing: 10) {
            // Nomor
            Text(String(format: "%02d", index + 1))
                .frame(width: 50, alignment: .leading)
                .font(.body)
            
            // Jenis Pekerjaan
            TextField("Jenis Pekerjaan", text: Binding(
                get: { task.taskType },
                set: { newValue in
                    task.taskType = newValue
                    checkAndAddNewTaskIfNeeded(for: location, at: index)
                }
            ))
                .textFieldStyle(.roundedBorder)
                .frame(width: 550)
                .font(.body)
            
            // Hole/Area - Using available locations as options
            Menu {
                ForEach(availableAreas, id: \.self) { area in
                    Button {
                        if task.area.contains(area) {
                            task.area.removeAll { $0 == area }
                        } else {
                            task.area.append(area)
                        }
                        checkAndAddNewTaskIfNeeded(for: location, at: index)
                    } label: {
                        HStack {
                            if task.area.contains(area) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            } else {
                                Image(systemName: "circle")
                                    .foregroundColor(.white)
                            }
                            Text(area)
                                .foregroundColor(
                                    task.area.contains(area) ? .blue : .primary
                                )
                        }
                    }
                }
            } label: {
                HStack {
                    Text(task.area.isEmpty ? "Pilih" : task.area.joined(separator: ", "))
                        .foregroundColor(task.area.isEmpty ? .secondary : .primary)
                        .font(.body)
                        .lineLimit(1)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.body)
                }
                .frame(width: 250)
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.1))
                .cornerRadius(6)
            }

            // Hari
            Menu {
                ForEach(viewModel.getBahasaDays(), id: \.self) { day in
                    Button(day) {
                        if let englishDay = viewModel.getEnglishDay(fromBahasa: day)
                        {
                            task.day = englishDay  // ✅ store English ("Monday", "Tuesday")
                            print(englishDay)
                        }
                        checkAndAddNewTaskIfNeeded(for: location, at: index)
                    }
                }
            } label: {
                HStack {
                    Text(viewModel.getBahasaDay(fromEnglish: task.day) ?? (task.day.isEmpty ? "Pilih" : task.day))
                        .foregroundColor(task.day.isEmpty ? .secondary : .primary)
                        .font(.body)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.body)
                }
                .frame(width: 80)
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.1))
                .cornerRadius(6)
            }

            // Keterangan
            TextField("Potong dengan ukuran...", text: Binding(
                get: { task.description },
                set: { newValue in
                    task.description = newValue
                    checkAndAddNewTaskIfNeeded(for: location, at: index)
                }
            ))
                .textFieldStyle(.roundedBorder)
                .frame(maxWidth: .infinity)
                .font(.body)
            
            // Delete Button
            Button {
                location.deleteTask(taskId: task.id)
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.gray.opacity(0.3))
                    .font(.title2)
            }
            .buttonStyle(.plain)
            .frame(width: 30)
        }
        .padding(.horizontal)
    }

    // MARK: - Footer Section
    private var footerSection: some View {
        VStack{
            Button {
                addDivision()
            } label: {
                Text("Tambah Divisi")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundColor(Color.accent)
                    .background(Color.white)
                    .cornerRadius(8)
                    .animation(nil)
            }
            .transition(.opacity)
        }
        .padding(.vertical,15)
    }

    // MARK: - Helper Functions
    private func addLocationToDivision(_ division: WeeklyDivision) {
        let availableLocationsList = division.getAvailableLocation()
        guard !availableLocationsList.isEmpty else { return }

        // Get the first available location name
        let locationName = availableLocationsList.first!

        // Find the correct locationId by finding the index in the global availableLocations array
        guard
            let locationIndex = availableLocations.firstIndex(of: locationName)
        else { return }
        let locationId = locationIndex + 1

        division.addLocation(locationId: locationId)
    }

    private func changeLocationForDivisionLocation(
        _ location: DivisionLocation,
        to newLocationName: String,
        in division: WeeklyDivision
    ) {
        // Find the correct locationId by finding the index in the global availableLocations array
        guard
            let locationIndex = availableLocations.firstIndex(
                of: newLocationName
            )
        else { return }
        let newLocationId = locationIndex + 1

        // Update the location's properties
        location.locationId = newLocationId
        location.location = newLocationName
    }

    private func addTaskToLocation(_ location: DivisionLocation) {
        let newTaskId = (location.tasks.map { $0.id }.max() ?? 0) + 1
        let newTask = DivisionTask(
            id: newTaskId,
            taskType: "",
            day: "",
            description: "",
            area: []
        )
        location.addTask(task: newTask)
    }

    private func addDivision() {
        let availableDivisions = viewModel.getAvailableDivisions()
        guard let firstAvailable = availableDivisions.first else { return }
        viewModel.addDivision(Division: firstAvailable)
    }

    private func changeDivision(
        _ division: WeeklyDivision,
        to newDivision: WeeklyDivision
    ) {
        // Only update the division's id and name, preserve locations and tasks
        division.id = newDivision.id
        division.name = newDivision.name
        // Don't reset locations - keep existing locations and tasks intact
    }

    // MARK: - Check and Add New Task
    private func checkAndAddNewTaskIfNeeded(
        for location: DivisionLocation,
        at index: Int
    ) {
        // Check if this is the last task in the location
        guard index == location.tasks.count - 1 else { return }

        let task = location.tasks[index]

        // Check if any field has been filled (task type, day, description, or area)
        let hasTaskType = !task.taskType.isEmpty
        let hasDay = !task.day.isEmpty
        let hasDescription = !task.description.isEmpty
        let hasArea = !task.area.isEmpty

        // If any field is filled and this is the last task, add a new empty task
        if hasTaskType || hasDay || hasDescription || hasArea {
            addTaskToLocation(location)
        }
    }
}

#Preview {
    CreateWeeklyPlan()
}
