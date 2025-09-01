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

    // IMPORTANT: Make sure this URL is correct.
    // Is it your Postman mock or your real localhost backend?
    // Let's use the Constants file for now.
    private let loginURL = Constants.loginURL

    func login(completion: @escaping (Bool, String?, String?) -> Void) {
        guard let url = URL(string: loginURL) else {
            self.errorMessage = "Error: Invalid URL."
            completion(false, nil, nil)
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

                // 1. Check for network errors (e.g., server not running)
                if let error = error {
                    print("Network Error: \(error.localizedDescription)")
                    self.errorMessage = "Failed to connect to the server."
                    completion(false, nil, nil)
                    return
                }

                // 2. Check for data
                guard let data = data else {
                    print("Error: No data received from server.")
                    self.errorMessage = "No data received."
                    completion(false, nil, nil)
                    return
                }
                
                // 3. Print the raw server response AS TEXT. THIS IS THE MOST IMPORTANT STEP.
                print("Raw Response Data: \(String(data: data, encoding: .utf8) ?? "Unable to decode data")")

                // 4. Attempt to decode a SUCCESS response
                if let loginResponse = try? JSONDecoder().decode(LoginResponse.self, from: data), loginResponse.status == "success" {
                    print("✅ Success: Decoded LoginResponse successfully.")
                    print("Role: \(loginResponse.data.user.role), Token: \(loginResponse.data.accessToken)")
                    self.errorMessage = nil // Clear any previous errors
                    completion(true, loginResponse.data.accessToken, loginResponse.data.user.role)
                
                // 5. Attempt to decode an ERROR response
                } else if let errorResponse = try? JSONDecoder().decode(LoginErrorResponse.self, from: data) {
                    print("❌ Error: Decoded LoginErrorResponse.")
                    self.errorMessage = errorResponse.message
                    completion(false, nil, nil)

                // 6. If both decoders fail
                } else {
                    print("🚨 Fatal: Failed to decode JSON into either LoginResponse or LoginErrorResponse.")
                    self.errorMessage = "An unexpected error occurred. Could not read server response."
                    completion(false, nil, nil)
                }
            }
        }.resume()
    }
}
