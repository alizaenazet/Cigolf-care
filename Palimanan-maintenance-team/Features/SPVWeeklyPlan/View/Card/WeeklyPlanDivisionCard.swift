//
//  WeeklyPlanDivisionCard.swift
//  Palimanan-maintenance-team
//
//  Created by Syamsuddin Putra Riefli on 01/09/25.
//

import SwiftUI

struct WeeklyPlanDivisionCard: View {
    let division: WeeklyDetailDivision
    @State private var isExpanded = true   // auto expanded
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Division Header
            HStack {
                Text(division.name)
                    .font(.headline)
                
                Spacer()
                
                Button {
                    withAnimation {
                        isExpanded.toggle()
                    }
                } label: {
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .foregroundColor(.blue)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal)
            .padding(.vertical, 16)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 1)
            
            // Locations (expandable content)
            if isExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(division.locations) { location in
                        WeeklyPlanLocationCard(location: location)
                        
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }
}
