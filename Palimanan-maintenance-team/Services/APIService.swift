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
    @Published var accessToken: String? = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MiwidXNlcm5hbWUiOiJUcmVudDY3Iiwicm9sZSI6IkFkbWluIiwiaWF0IjoxNzU2Nzg0NjA4LCJleHAiOjE3NTY3ODgyMDh9.1VC1j3fL5_5Oc5t8tLHmkcgBl-5fgAiaWHZd9bB0ylg"
    @Published var userId: String? = nil
    @Published var role: String? = nil
    
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
                            // Here we could try refresh flow
                        }
                        continuation.resume(throwing: error)
                    }
                }
        }
    }
}
