//
//  SessionManager.swift
//  Palimanan-maintenance-team
//
//  Created by Louis Mario Wijaya on 01/09/25.
//

import Foundation

class SessionManager: ObservableObject {
    
    static var shared: SessionManager!
    
    @Published var isLoggedIn: Bool = false
    @Published var userRole: String?
    @Published var accessToken: String?
    @Published var userId: Int?
    @Published var foremanId: Int?
    
    private let accessTokenKey = "accessToken"
    private let userRoleKey = "userRole"
    private let userIdKey = "userId"
    private let foremanIdKey = "foremanId"
    
    init() {
        let token = UserDefaults.standard.string(forKey: accessTokenKey)
        let role = UserDefaults.standard.string(forKey: userRoleKey)
        let id = UserDefaults.standard.integer(forKey: userIdKey)
        let fId = UserDefaults.standard.integer(forKey: foremanIdKey)
        if let token = token, !token.isEmpty {
            self.isLoggedIn = true
            self.accessToken = token
            self.userRole = role
            APIService.shared.accessToken = token
            if id != 0 {
                self.userId = id
                APIService.shared.userId = String(id)
            }
            if fId != 0 {
                self.foremanId = fId
            }
        }
    }
    
    func login(token: String, role: String, userId: Int) {
        UserDefaults.standard.set(token, forKey: accessTokenKey)
        UserDefaults.standard.set(role, forKey: userRoleKey)
        UserDefaults.standard.set(userId, forKey: userIdKey)
        
        var currentForemanId: Int?
        if role == "Mandor" {
            if let foreman = ForemanMapper(rawValue: userId) {
                currentForemanId = foreman.foremanId
            }
        }
        
        if let fId = currentForemanId {
            UserDefaults.standard.set(fId, forKey: foremanIdKey)
        }
        
        APIService.shared.accessToken = token
        APIService.shared.userId = String(userId)
        
        DispatchQueue.main.async {
            self.isLoggedIn = true
            self.accessToken = token
            self.userRole = role
            self.userId = userId
            self.foremanId = currentForemanId
        }
    }
    
    func logout() {
        UserDefaults.standard.removeObject(forKey: accessTokenKey)
        UserDefaults.standard.removeObject(forKey: userRoleKey)
        UserDefaults.standard.removeObject(forKey: userIdKey)
        UserDefaults.standard.removeObject(forKey: foremanIdKey)
        
        APIService.shared.accessToken = nil
        APIService.shared.userId = nil
        
        DispatchQueue.main.async {
            self.isLoggedIn = false
            self.accessToken = nil
            self.userRole = nil
            self.userId = nil
            self.foremanId = nil
        }
        
        print(#function, "User has been logged out. IsLoggedIn: \(self.isLoggedIn)")
    }
}
