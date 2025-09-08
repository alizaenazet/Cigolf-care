//
//  CreateWeeklyPlanViewModel.swift
//  Palimanan-maintenance-team
//
//  Created by Ali zaenal on 02/09/25.
//

import Combine
import Foundation

// Division Id is Index + 1
let availableDivsion = [
    "Operasional", "Landscape", "Projek", "Irigasi", "Mekanik",
]

let availableLocations: [String] = [
    "All", "Green", "Tee Box", "Fairway", "Apron", "Rough", "Bunker", "Nursery",
    "Driving Range", "Maingate", "Putting 10", "Paving Room", "Resto",
    "Mekanik", "Irigasi",
]

let availableAreas: [String] = [
    "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14",
    "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26",
    "27", "CH", "FC", "VILLA", "Main Gate", "Driving Range", "Parkiran",
]

class WeeklyDivision: ObservableObject {
    @Published var id: Int
    @Published var name: String
    @Published var locations: [DivisionLocation] = []

    private var cancellables = Set<AnyCancellable>()

    init(id: Int, name: String) {
        self.id = id
        self.name = name

        // Listen for changes in locations array
        $locations
            .sink { [weak self] locations in
                // Subscribe to each location's changes
                self?.subscribeToLocations(locations)
            }
            .store(in: &cancellables)
    }

    private func subscribeToLocations(_ locations: [DivisionLocation]) {
        // Clear existing subscriptions
        cancellables.removeAll()

        // Re-subscribe to locations array changes
        $locations
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)

        // Subscribe to each location's objectWillChange
        for location in locations {
            location.objectWillChange
                .sink { [weak self] _ in
                    self?.objectWillChange.send()
                }
                .store(in: &cancellables)
        }
    }

    func getAvailableLocation() -> [String] {
        let tempAlreadyAddedLocations = locations.map { $0.location }

        let filteredAvailableLocations = availableLocations.filter {
            !tempAlreadyAddedLocations.contains($0)
        }

        return filteredAvailableLocations
    }

    func addLocation(locationId: Int) {
        self.locations.append(
            DivisionLocation(
                locationId: locationId,
                location: availableLocations[locationId - 1]
            )
        )
        subscribeToLocations(self.locations)
    }

    func deleteLocation(locationId: Int) {
        self.locations.removeAll { $0.locationId == locationId }
    }
}

class DivisionLocation: ObservableObject {
    @Published var locationId: Int
    @Published var location: String
    @Published var tasks: [DivisionTask] = [
        DivisionTask(id: 1, taskType: "", day: "", description: "", area: [])
    ]

    private var cancellables = Set<AnyCancellable>()

    init(locationId: Int, location: String) {
        self.locationId = locationId
        self.location = location

        // Listen for changes in tasks array
        $tasks
            .sink { [weak self] tasks in
                self?.subscribeToTasks(tasks)
            }
            .store(in: &cancellables)
    }

    private func subscribeToTasks(_ tasks: [DivisionTask]) {
        // Clear existing task subscriptions (keep the tasks array subscription)
        let tasksSubscription = cancellables.first { _ in true }
        cancellables.removeAll()
        if let subscription = tasksSubscription {
            cancellables.insert(subscription)
        }

        // Re-subscribe to tasks array changes
        $tasks
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)

        // Subscribe to each task's objectWillChange
        for task in tasks {
            task.objectWillChange
                .sink { [weak self] _ in
                    self?.objectWillChange.send()
                }
                .store(in: &cancellables)
        }
    }

    func addTask(task: DivisionTask) {
        self.tasks.append(task)
        subscribeToTasks(self.tasks)
    }

    func deleteTask(taskId: Int) {
        self.tasks.removeAll { $0.id == taskId }
    }
}

struct DayMapping {
    let bahasa: String
    let english: String
    let id: Int
}

class DivisionTask: ObservableObject {
    @Published var id: Int
    @Published var taskType: String
    @Published var day: String
    @Published var description: String
    @Published var area: [String]

    init(
        id: Int,
        taskType: String,
        day: String,
        description: String,
        area: [String] = []
    ) {
        self.id = id
        self.taskType = taskType
        self.day = day
        self.description = description
        self.area = area
    }

}

class CreateWeeklyPlanViewModel: ObservableObject {
    @Published var startAt: Date
    @Published var endAt: Date
    @Published var divisions: [WeeklyDivision]

    private var cancellables = Set<AnyCancellable>()

    init() {
        let indonesiaTimeZone = TimeZone(identifier: "Asia/Jakarta")!
        var calendar = Calendar.current
        calendar.timeZone = indonesiaTimeZone

        let now = Date()
        let currentWeekday = calendar.component(.weekday, from: now)

        // Calculate days to next Sunday (weekday 1 = Sunday)
        let daysToNextSunday: Int
        if currentWeekday == 1 {  // Today is Sunday
            daysToNextSunday = 7  // Next week's Sunday
        } else {
            daysToNextSunday = 8 - currentWeekday  // Days until next Sunday
        }

        // Get next Sunday at start of day (00:00:00)
        let nextSunday = calendar.date(
            byAdding: .day,
            value: daysToNextSunday,
            to: now
        )!
        let nextSundayStartOfDay = calendar.startOfDay(for: nextSunday)

        // End date is Saturday (6 days after Sunday)
        let nextSaturday = calendar.date(
            byAdding: .day,
            value: 6,
            to: nextSundayStartOfDay
        )!
        let nextSaturdayEndOfDay = calendar.date(
            bySettingHour: 23,
            minute: 59,
            second: 59,
            of: nextSaturday
        )!

        self.startAt = nextSundayStartOfDay
        self.endAt = nextSaturdayEndOfDay

        self.divisions = [
            WeeklyDivision(id: 1, name: "Operasional"),
            WeeklyDivision(id: 2, name: "Landscape"),
            WeeklyDivision(id: 3, name: "Projek"),
            WeeklyDivision(id: 4, name: "Irigasi"),
            WeeklyDivision(id: 5, name: "Mekanik"),
        ]

        // Subscribe to division changes
        subscribeToDivisions()
    }

    private func subscribeToDivisions() {
        // Clear existing subscriptions
        cancellables.removeAll()

        // Subscribe to divisions array changes
        $divisions
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)

        // Subscribe to each division's objectWillChange
        for division in divisions {
            division.objectWillChange
                .sink { [weak self] _ in
                    self?.objectWillChange.send()
                }
                .store(in: &cancellables)
        }
    }

    func getAvailableDivisions() -> [WeeklyDivision] {
        let tempAlreadyAddedDivisions = divisions.map { $0.id }

        let tempAvailableDivisions = availableDivsion.enumerated().filter {
            !tempAlreadyAddedDivisions.contains($0.offset + 1)
        }

        let tempAvailableDivisionsToObjects: [WeeklyDivision] =
            tempAvailableDivisions.map {
                WeeklyDivision(id: $0.offset + 1, name: $0.element)
            }

        return tempAvailableDivisionsToObjects
    }

    func addDivision(Division: WeeklyDivision) {
        self.divisions.append(Division)
        subscribeToDivisions()
    }

    func deleteDivision(DivisionId: Int) {
        self.divisions.removeAll { $0.id == DivisionId }
    }

    // days Id is Index + 1
    // Create mappings with IDs for easy conversion
    let dayMappings: [DayMapping] = [
        DayMapping(bahasa: "Senin", english: "Monday", id: 0),
        DayMapping(bahasa: "Selasa", english: "Tuesday", id: 1),
        DayMapping(bahasa: "Rabu", english: "Wednesday", id: 2),
        DayMapping(bahasa: "Kamis", english: "Thursday", id: 3),
        DayMapping(bahasa: "Jumat", english: "Friday", id: 4),
        DayMapping(bahasa: "Sabtu", english: "Saturday", id: 5),
        DayMapping(bahasa: "Minggu", english: "Sunday", id: 6),
    ]

    // WORK WITH Day MAPPINGS :
    //    Picker("Hari", selection: $selectedDayBahasa) {
    //        ForEach(viewModel.getBahasaDays(), id: \.self) { day in
    //            Text(day).tag(day)
    //        }
    //    }

    // Helper functions for conversion
    func getBahasaDays() -> [String] {
        return dayMappings.map { $0.bahasa }
    }

    func getEnglishDay(fromBahasa bahasa: String) -> String? {
        return dayMappings.first(where: { $0.bahasa == bahasa })?.english
    }

    func getBahasaDay(fromEnglish english: String) -> String? {
        return dayMappings.first(where: { $0.english == english })?.bahasa
    }

    func getDayMapping(byId id: Int) -> DayMapping? {
        return dayMappings.first(where: { $0.id == id })
    }

    //    func createWeeklyPlan() {
    //        print("Creating Weekly Plan...")
    //        // FOR NOW JUST MOCK WITH PRINT STATEMENT
    //    }

    func createWeeklyPlan(onSuccess: (() -> Void)? = nil) {
        Task {
            do {
                let formatter = DateFormatter()
                formatter.dateFormat = "dd-MM-yyyy"
                formatter.locale = Locale(identifier: "en_US_POSIX")

                let payload: [String: Any] = [
                    "startAt": formatter.string(from: startAt),
                    "endAt": formatter.string(from: endAt),
                    "divisions": divisions.map { division in
                        [
                            "id": division.id,
                            "locations": division.locations.map { location in
                                [
                                    "locationId": location.locationId,
                                    "tasks": location.tasks
                                        .filter {
                                            !$0.taskType.trimmingCharacters(
                                                in: .whitespaces
                                            ).isEmpty
                                        }
                                        .map { task in
                                            [
                                                "taskType": task.taskType,
                                                "day": task.day.lowercased(),
                                                "description": task.description,
                                                "Area": task.area,
                                            ]
                                        },
                                ]
                            },
                        ]
                    },
                ]

                print(payload)

                let response: NormalResponse = try await APIService.shared.post(
                    "/weekly-plan",
                    parameters: payload,
                    responseType: NormalResponse.self
                )

                print("✅ Weekly plan created: \(response.message)")
                DispatchQueue.main.async {
                    onSuccess?()
                }
            } catch {
                print("❌ Failed to create weekly plan:", error)
            }
        }
    }
}
