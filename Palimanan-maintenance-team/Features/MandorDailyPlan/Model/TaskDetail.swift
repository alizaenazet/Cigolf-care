//
//  TaskDetail.swift
//  Palimanan-maintenance-team
//
//  Created by Louis Mario Wijaya on 03/09/25.
//

import Foundation

struct TaskDetail: Decodable, Identifiable {
    let id: Int
    let taskType: String
    let description: String
    let priority: String
    let area: [String]
    let needWorker: Int?
    let availableWorker: Int?
    let workerList: [String]
    let isFinished: Bool
}
