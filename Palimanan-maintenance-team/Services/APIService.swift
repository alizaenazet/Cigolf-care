//
//  APIService.swift
//  Palimanan-maintenance-team
//
//  Created by Syamsuddin Putra Riefli on 01/09/25.
//

import Foundation
import Alamofire
import Combine

final class APIService {
    static let shared = APIService()
    private init() {}
    
    // MARK: - Base URL
    private let apiVersion = "v1"
    private let baseHost = "http://localhost:3000"
    
    var baseURL: String {
        "\(baseHost)/api/\(apiVersion)"
    }
    
    // MARK: - Session / Auth State
    @Published var accessToken: String? = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MiwidXNlcm5hbWUiOiJUcmVudDY3Iiwicm9sZSI6IkFkbWluIiwiaWF0IjoxNzU2ODk2MTczLCJleHAiOjE3NTY4OTk3NzN9.x38vlh5X5k90hLzjRZU-RN1O5za7czKfpKd1BlnnHn4"
    @Published var userId: String? = nil
    @Published var role: String? = nil
    
    func post<T: Decodable>(
        _ endpoint: String,
        parameters: Parameters,
        headers: HTTPHeaders? = nil,
        responseType: T.Type
    ) async throws -> T {
        try await request(
            endpoint,
            method: .post,
            parameters: parameters,
            encoding: JSONEncoding.default, // ✅ POST usually uses JSON
            headers: headers,
            responseType: responseType
        )
    }
    
    // MARK: - Generic Request
    func request<T: Decodable>(
        _ endpoint: String,
        method: HTTPMethod = .get,
        parameters: Parameters? = nil,
        encoding: ParameterEncoding = URLEncoding.default,
        headers: HTTPHeaders? = nil,
        responseType: T.Type
    ) async throws -> T {
        
        var finalHeaders: HTTPHeaders = headers ?? []
        
        // Inject JWT token if available
        if let token = accessToken {
            finalHeaders.add(.authorization(bearerToken: token))
        }
        
        let url = "\(baseURL)\(endpoint)"
        
        return try await withCheckedThrowingContinuation { continuation in
            AF.request(url, method: method, parameters: parameters, encoding: encoding, headers: finalHeaders)
                .validate()
                .responseDecodable(of: T.self) { response in
                    switch response.result {
                    case .success(let decoded):
                        continuation.resume(returning: decoded)
                    case .failure(let error):
                        // Detect expired token (401)
                        if response.response?.statusCode == 401 {
                            print("⚠️ Unauthorized — token may be expired")
                            var sm = SessionManager()
                            sm.logout()
                        }
                        continuation.resume(throwing: error)
                    }
                }
        }
    }
}
