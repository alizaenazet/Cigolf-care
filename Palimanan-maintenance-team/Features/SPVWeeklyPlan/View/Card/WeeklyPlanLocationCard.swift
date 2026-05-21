//
//  LocationCard.swift
//  Palimanan-maintenance-team
//
//  Created by Syamsuddin Putra Riefli on 31/08/25.
//

import SwiftUI

struct WeeklyPlanLocationCard: View {
    let location: WeeklyDetailLocation
    @State private var isExpanded = true
    
    // Shared grid definition
    private let taskColumns: [GridItem] = [
        GridItem(.fixed(50), alignment: .leading),   // Nomor
        GridItem(.flexible(minimum: 120), alignment: .leading), // Jenis Pengerjaan
        GridItem(.fixed(100), alignment: .leading),  // Hole/Area
        GridItem(.fixed(70), alignment: .center),  // Hari
        GridItem(.flexible(), alignment: .leading) // Keterangan
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(location.location)
                    .font(.headline)
                
                Spacer()
                
                Button {
                    withAnimation {
                        isExpanded.toggle()
                    }
                } label: {
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .foregroundColor(.accentColor)
                }
                .buttonStyle(.plain)
            }
            .padding()
            .background(Color.white)
            
            if isExpanded {
                VStack(spacing: 0) {
                    // Table header
                    LazyVGrid(columns: taskColumns, spacing: 12) {
                        Text("No.")
                        Text("Jenis Pengerjaan")
                        Text("Hole/Area")
                        Text("Hari")
                        Text("Keterangan")
                    }
                    .font(.subheadline.bold())
                    .foregroundColor(.secondary)
                    .padding(.vertical, 8)
                    .padding(.horizontal)
                    
                    Divider()
                    
                    
                    ForEach(Array(location.tasks.enumerated()), id: \.1.id) { index, task in
                        WeeklyPlanTaskCard(task: task, index: index, columns: taskColumns)
                        
                        if index < location.tasks.count - 1 {
                            Divider()
                        }
                    }
                }
                .background(Color.white)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 1)
        .padding(.vertical, 6)
    }
}
