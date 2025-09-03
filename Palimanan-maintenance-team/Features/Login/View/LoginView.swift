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
    
    var body: some View {
        ZStack {
            Image("login_bg")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
          VStack(spacing: 25) {
                Image("logo_ciputra")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 80)
                    .padding(.bottom, 20)
                
                HStack {
                    Image(systemName: "person.fill")
                        .foregroundColor(.gray)
                    
                    ZStack(alignment: .leading) {
                        if viewModel.username.isEmpty {
                            Text("Username")
                                .foregroundColor(.gray)
                        }
                        TextField("", text: $viewModel.username)
                            .foregroundColor(.black)
                            .textFieldStyle(.plain)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.15))
                .cornerRadius(10)
                
                HStack {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.gray)
                    
                    ZStack(alignment: .leading) {
                        if viewModel.password.isEmpty {
                            Text("Password")
                                .foregroundColor(.gray)
                        }
                        
                        SecureField("", text: $viewModel.password)
                            .foregroundColor(.black)
                            .textFieldStyle(.plain)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.15))
                .cornerRadius(10)
                
                if viewModel.isLoading {
                    ProgressView()
                        .padding(.vertical, 10)
                } else {
                    Button(action: {
                        viewModel.login { success, accessToken, role in
                            if success, let token = accessToken, let userRole = role {
                                session.login(token: token, role: userRole)
                            }
                        }
                    }) {
                        Text("Masuk")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(red: 0.2, green: 0.8, blue: 0.25))
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
            }
            .padding(40)
            .background(.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.2), radius: 15, x: 0, y: 10)
            .frame(width: 400)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .frame(minWidth: 800, minHeight: 600)
    }
}

#Preview {
    LoginView()
        .environmentObject(SessionManager())
}
