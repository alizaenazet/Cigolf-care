//
//  LoginView.swift
//  Palimanan-maintenance-team
//
//  Created by Louis Mario Wijaya on 01/09/25.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @EnvironmentObject var session: SessionManager
    
    private var isIPadOrMac: Bool {
#if os(macOS)
        return true
#else
        return UIDevice.current.userInterfaceIdiom == .pad
#endif
    }
    
    private var isIPhone: Bool {
#if os(macOS)
        return false
#else
        return UIDevice.current.userInterfaceIdiom == .phone
#endif
    }
    
    var body: some View {
        ZStack {
            if isIPadOrMac {
                Image("login_bg")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            }
            
            VStack {
                
                if isIPhone {
                    Spacer()
                        .frame(height: 104)
                }
                
                Image("logo_ciputra")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 100)
                    .padding(.bottom, 16)
                
                Text("Akses program golf course maintenance")
                    .font(.caption2)
                    .foregroundStyle(Color(hex: "#989898"))
                    .padding(.bottom, 48)
                
                HStack {
                    Image(systemName: "person")
                        .foregroundColor(Color(hex: "#A9A9A9"))
                    
                    ZStack(alignment: .leading) {
                        if viewModel.username.isEmpty {
                            Text("Username")
                                .font(.subheadline)
                                .foregroundColor(Color(hex: "#A9A9A9"))
                        }
                        TextField("", text: $viewModel.username)
                            .foregroundColor(.black)
                            .textFieldStyle(.plain)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 13)
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: Color(hex: "#A9A9A9"), radius: 0, x: 1, y: 1)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(hex: "#A9A9A9"), lineWidth: 0.5)
                )
                
                Spacer()
                    .frame(height: 20)
                
                HStack {
                    Image(systemName: "key")
                        .foregroundColor(Color(hex: "#A9A9A9"))
                    
                    ZStack(alignment: .leading) {
                        if viewModel.password.isEmpty {
                            Text("Password")
                                .font(.subheadline)
                                .foregroundColor(Color(hex: "#A9A9A9"))
                        }
                        
                        SecureField("", text: $viewModel.password)
                            .foregroundColor(.black)
                            .textFieldStyle(.plain)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 13)
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: Color(hex: "#A9A9A9"), radius: 0.5, x: 1, y: 1)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(hex: "#A9A9A9"), lineWidth: 0.5)
                )
                
                Spacer()
                    .frame(height: 20)
                
                if viewModel.isLoading {
                    ProgressView()
                        .padding(.vertical, 10)
                } else {
                    Button(action: {
                        viewModel.login { success, accessToken, role, userId in
                            if success, let token = accessToken, let userRole = role, let id = userId {
                                session.login(token: token, role: userRole, userId: id)
                            }
                        }
                    }) {
                        Text("Masuk")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(hex: "#79A222"))
                            .cornerRadius(10)
                    }
                    .buttonStyle(.plain)
                }
                
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                if isIPhone {
                    Spacer()
                }
            }
            .padding(.horizontal, 40)
            .padding(.vertical, isIPadOrMac ? 40 : 0)
            .background(isIPadOrMac ? Color.white : Color.clear)
            .cornerRadius(isIPadOrMac ? 16 : 0)
            .shadow(
                color: isIPadOrMac ? Color(hex: "#A9A9A9") : .clear,
                radius: isIPadOrMac ? 5 : 0,
                x: isIPadOrMac ? 2 : 0,
                y: isIPadOrMac ? 2 : 0
            )
            .frame(width: isIPadOrMac ? 450 : nil)
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(SessionManager())
}
