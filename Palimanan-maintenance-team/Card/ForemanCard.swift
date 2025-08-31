//
//  ForemanCard.swift
//  Palimanan-maintenance-team
//
//  Created by Syamsuddin Putra Riefli on 31/08/25.
//

import SwiftUI

struct ForemanCard: View {
    let report: ForemanReport
    let onApproveTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Program Hari Ini")
                        .font(.title2).bold()
                    
                    Text("Penyedia Tenaga Kerja : \(report.outsourceCompany)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    if let firstDivision = report.divisions.first {
                        let areas = firstDivision.locations.map { $0.locationName }.joined(separator: ", ")
                        Text("Area: \(areas)")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 8) {
                    Text(DateHelper.formattedDate(report.createdAt))
                        .font(.headline)
                    
                    if report.approved.isApproved {
                        Button {} label: {
                            Label("Telah disetujui pada tanggal\(DateHelper.formattedDate(report.approved.approvedAt).split(separator: ",").dropFirst().joined(separator: ","))", systemImage: "checkmark.circle.fill")
                                .font(.caption)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color.green.opacity(0.2))
                                .cornerRadius(8)
                        }
                        .buttonStyle(.plain)
                        .disabled(true)
                    } else {
                        Button {
                            onApproveTap()
                        } label: {
                            Label("Setujui Laporan", systemImage: "checkmark")
                                .font(.caption)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                }
            }
            
            HStack(spacing: 16) {
                progressCard(
                    title: "Pekerjaan Selesai",
                    value: report.finishedTasks,
                    total: report.totalTasks,
                    color: .green,
                    systemImage: "checkmark.circle"
                )
                progressCard(
                    title: "Dalam Pengerjaan",
                    value: report.pendingTasks,
                    total: report.totalTasks,
                    color: .red,
                    systemImage: "figure.walk"
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Subview
    private func progressCard(title: String, value: Int, total: Int, color: Color, systemImage: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label(title, systemImage: systemImage)
                    .foregroundColor(.white)
                    .font(.subheadline.bold())
                Spacer()
                Text("\(value)/\(total)")
                    .foregroundColor(.white)
                    .font(.subheadline.bold())
            }
            
            ProgressView(value: Double(value), total: Double(total))
                .progressViewStyle(LinearProgressViewStyle(tint: .white))
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(color)
        .cornerRadius(12)
    }
}

