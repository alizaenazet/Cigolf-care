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
        VStack(spacing: 20) {
            Text("Palimanan-maintenance-team")
                .font(.title)
                .padding(.bottom, 20)
            
            TextField("Username", text: $viewModel.username)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            SecureField("Password", text: $viewModel.password)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            if viewModel.isLoading {
                ProgressView()
            } else {
                Button("Login") {
                    viewModel.login { success, accessToken, role, userId  in
                        if success, let token = accessToken, let userRole = role, let userId = userId {
                            session.login(token: token, role: userRole, userId: userId)
                        }
                    }
                }
            }

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding(.top)
            }
        }
        .padding()
        .frame(width: 400, height: 400)
    }
}

#Preview {
    LoginView()
}
