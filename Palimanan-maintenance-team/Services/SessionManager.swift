//
//  SessionManager.swift
//  Palimanan-maintenance-team
//
//  Created by Louis Mario Wijaya on 01/09/25.
//

import Foundation

class SessionManager: ObservableObject {
    static var shared = SessionManager()
    @Published var isLoggedIn: Bool = false
    @Published var userRole: String?
    @Published var accessToken: String?
    @Published var userId: Int?
    
    private let accessTokenKey = "accessToken"
    private let userRoleKey = "userRole"
    private let userIdKey = "userId"
    
    init() {
        let token = UserDefaults.standard.string(forKey: accessTokenKey)
        let role = UserDefaults.standard.string(forKey: userRoleKey)
        let userId = UserDefaults.standard.integer(forKey: userIdKey)
        
        if let token = token, !token.isEmpty {
            self.isLoggedIn = true
            self.accessToken = token
            self.userRole = role
            self.userId = userId
            APIService.shared.accessToken = token
        }
    }
    
    func login(token: String, role: String, userId: Int) {
        UserDefaults.standard.set(token, forKey: accessTokenKey)
        UserDefaults.standard.set(role, forKey: userRoleKey)
        UserDefaults.standard.set(userId, forKey: userIdKey)
        DispatchQueue.main.async {
            self.isLoggedIn = true
            self.accessToken = token
            APIService.shared.accessToken = token
            self.userRole = role
            self.userId = userId
        }
    }
    
    func logout() {
        UserDefaults.standard.removeObject(forKey: accessTokenKey)
        UserDefaults.standard.removeObject(forKey: userRoleKey)
        UserDefaults.standard.removeObject(forKey: userIdKey)
        DispatchQueue.main.async {
            self.isLoggedIn = false
            self.accessToken = nil
            self.userRole = nil
            APIService.shared.accessToken = nil
        }
        SessionManager.shared = SessionManager()
        
        print(#function, SessionManager.shared.isLoggedIn)
    }
}
