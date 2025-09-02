//
//  LocationCard.swift
//  Palimanan-maintenance-team
//
//  Created by Syamsuddin Putra Riefli on 31/08/25.
//

import SwiftUI

struct DailyRepLocCard: View {
    let location: Location
    let division: Division
    @State private var isExpanded = false
    
    // Shared grid definition
    private let taskColumns: [GridItem] = [
        GridItem(.fixed(50), alignment: .leading),   // Nomor
        GridItem(.flexible(minimum: 120), alignment: .leading), // Jenis Pengerjaan
        GridItem(.fixed(100), alignment: .leading),  // Hole/Area
        GridItem(.fixed(70), alignment: .center),    // Prioritas
        GridItem(.fixed(120), alignment: .center),   // Gambar
        GridItem(.flexible(), alignment: .leading),  // Keterangan
        GridItem(.fixed(50), alignment: .center)     // Status
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(location.locationName)
                    .font(.headline)
                
                Spacer()
                
                Button {
                    withAnimation {
                        isExpanded.toggle()
                    }
                } label: {
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .foregroundColor(.green)
                }
                .buttonStyle(.plain)
            }
            .padding()
            .background(Color.white)
            
            if isExpanded {
                VStack(spacing: 0) {
                    // Table header
                    LazyVGrid(columns: taskColumns, spacing: 12) {
                        Text("Nomor")
                        Text("Jenis Pengerjaan")
                        Text("Hole/Area")
                        Text("Prioritas")
                        Text("Gambar")
                        Text("Keterangan")
                        Text("Status")
                    }
                    .font(.subheadline.bold())
                    .foregroundColor(.secondary)
                    .padding(.vertical, 8)
                    .padding(.horizontal)
                    
                    Divider()
                    
                    
                    ForEach(Array(location.tasks.enumerated()), id: \.1.id) { index, task in
                        DailyRepTaskCard(task: task, index: index, columns: taskColumns)
                        
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
