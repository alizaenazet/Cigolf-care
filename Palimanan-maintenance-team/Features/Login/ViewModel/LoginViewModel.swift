//
//  LoginViewModel.swift
//  Palimanan-maintenance-team
//
//  Created by Louis Mario Wijaya on 01/09/25.
//

import Foundation

class LoginViewModel: ObservableObject {
    @Published var username = ""
    @Published var password = ""
    @Published var errorMessage: String?
    @Published var isLoading = false

    private let loginURL = Constants.loginURL

    func login(completion: @escaping (Bool, String?, String?, Int?) -> Void) {
        guard let url = URL(string: loginURL) else {
            self.errorMessage = "Error: Invalid URL."
            completion(false, nil, nil, nil)
            return
        }

        isLoading = true
        errorMessage = nil

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["username": username, "password": password]
        request.httpBody = try? JSONEncoder().encode(body)

        print("--- Starting Login Request ---")
        print("URL: \(url.absoluteString)")
        print("Body: \(String(data: request.httpBody ?? Data(), encoding: .utf8) ?? "{}")")

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                print("--- Received Response ---")

                if let error = error {
                    print("Network Error: \(error.localizedDescription)")
                    self.errorMessage = "Failed to connect to the server."
                    completion(false, nil, nil, nil)
                    return
                }

                guard let data = data else {
                    print("Error: No data received from server.")
                    self.errorMessage = "No data received."
                    completion(false, nil, nil, nil)
                    return
                }
                
                print("Raw Response Data: \(String(data: data, encoding: .utf8) ?? "Unable to decode data")")

                if let loginResponse = try? JSONDecoder().decode(LoginResponse.self, from: data), loginResponse.status == "success" {
                    print("✅ Success: Decoded LoginResponse successfully.")
                    print("Role: \(loginResponse.data.user.role), Token: \(loginResponse.data.accessToken), User ID: \(loginResponse.data.user.id)")
                    self.errorMessage = nil // Clear any previous errors
                    completion(true, loginResponse.data.accessToken, loginResponse.data.user.role, loginResponse.data.user.id)
                    APIService.shared.accessToken = loginResponse.data.accessToken
                    print("API Service Token: \(APIService.shared.accessToken), SM Token: \(SessionManager.shared.accessToken)")
                
                } else if let errorResponse = try? JSONDecoder().decode(LoginErrorResponse.self, from: data) {
                    print("❌ Error: Decoded LoginErrorResponse.")
                    self.errorMessage = errorResponse.message
                    completion(false, nil, nil, nil)

                } else {
                    print("🚨 Fatal: Failed to decode JSON into either LoginResponse or LoginErrorResponse.")
                    self.errorMessage = "An unexpected error occurred. Could not read server response."
                    completion(false, nil, nil, nil)
                }
            }
        }.resume()
    }
}
