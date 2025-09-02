//
//  SessionManager.swift
//  Palimanan-maintenance-team
//
//  Created by Louis Mario Wijaya on 01/09/25.
//

import Foundation

class SessionManager: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var userRole: String?
    @Published var accessToken: String?
    
    private let accessTokenKey = "accessToken"
    private let userRoleKey = "userRole"
    
    init() {
        let token = UserDefaults.standard.string(forKey: accessTokenKey)
        let role = UserDefaults.standard.string(forKey: userRoleKey)
        
        if let token = token, !token.isEmpty {
            self.isLoggedIn = true
            self.accessToken = token
            self.userRole = role
            APIService.shared.accessToken = token
        }
    }
    
    func login(token: String, role: String) {
        UserDefaults.standard.set(token, forKey: accessTokenKey)
        UserDefaults.standard.set(role, forKey: userRoleKey)
        DispatchQueue.main.async {
            self.isLoggedIn = true
            self.accessToken = token
            APIService.shared.accessToken = token
            self.userRole = role
        }
    }
    
    func logout() {
        UserDefaults.standard.removeObject(forKey: accessTokenKey)
        UserDefaults.standard.removeObject(forKey: userRoleKey)
        DispatchQueue.main.async {
            self.isLoggedIn = false
            self.accessToken = nil
            self.userRole = nil
            APIService.shared.accessToken = nil
        }
    }
}
