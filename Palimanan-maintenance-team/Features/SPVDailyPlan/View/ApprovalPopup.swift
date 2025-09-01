//
//  ApprovalPopup.swift
//  Palimanan-maintenance-team
//
//  Created by Syamsuddin Putra Riefli on 31/08/25.
//

import SwiftUI

struct ApprovalPopup: View {
    let date: String
    let provider: String
    let finishedCount: Int
    let totalCount: Int
    let inProgressCount: Int
    let onApprove: () -> Void
    let onClose: () -> Void
    
    var body: some View {
        ZStack {
            // Fullscreen dimmed background
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            // Popup card
            VStack(spacing: 20) {
                HStack {
                    Text("Setujui Laporan")
                        .font(.title2)
                        .bold()
                    Spacer()
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .foregroundColor(.gray)
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Tanggal :").bold()
                        Text(date)
                    }
                    HStack {
                        Text("Penyedia Tenaga Kerja :").bold()
                        Text(provider)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Divider()
                
                HStack {
                    Label("Pekerjaan Selesai", systemImage: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Spacer()
                    Text("\(finishedCount)/\(totalCount)")
                }
                
                Divider()
                
                HStack {
                    Label("Dalam Pengerjaan", systemImage: "figure.walk")
                        .foregroundColor(.gray)
                    Spacer()
                    Text("\(inProgressCount)/\(totalCount)")
                }
                
                Button(action: onApprove) {
                    Text("Setujui")
                        .bold()
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.top, 12)
                
            }
            .padding(.all, 50)
            .background(Color.white)
            .cornerRadius(16)
            .frame(maxWidth: 500, maxHeight: 500)
            .shadow(radius: 10)
        }
    }
}
