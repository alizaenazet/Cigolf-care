//
//  APIService.swift
//  Palimanan-maintenance-team
//
//  Created by Syamsuddin Putra Riefli on 01/09/25.
//

import Alamofire
import Combine
import Foundation

final class APIService {
    static let shared = APIService()
    private init() {}
    
    // MARK: - Base URL
    private let apiVersion = "v1"
        private let baseHost =
            "https://cigolf-backend-yebology3212-s53p6k3p.apn.leapcell.dev"
//    private let baseHost = "http://localhost:3000"
    
    var baseURL: String {
        "\(baseHost)/api/\(apiVersion)"
    }
    
    // MARK: - Session / Auth State
    @Published var accessToken: String? = nil
    @Published var userId: String? = nil
    @Published var role: String? = nil
    
    func requestRaw(_ path: String, method: String = "GET") async throws -> Data {
        // Buat full URL String
        let urlString = baseURL + path
        print("Final URL String:", urlString)
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/zip", forHTTPHeaderField: "Accept")
        
        // Tambahkan Authorization Bearer
        if let token = self.accessToken { // misal token disimpan di APIService
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        return data
    }

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
            encoding: JSONEncoding.default,  // ✅ POST usually uses JSON
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
            AF.request(
                url,
                method: method,
                parameters: parameters,
                encoding: encoding,
                headers: finalHeaders
            )
            .validate()
            .responseDecodable(of: T.self) { response in
                switch response.result {
                case .success(let decoded):
                    continuation.resume(returning: decoded)
                case .failure(let error):
                    print(
                        "🚨 API Request Failed. Error: \(error.localizedDescription)"
                    )
                    print(
                        "📄 Raw failure data: \(String(data: response.data ?? Data(), encoding: .utf8) ?? "Unable to decode raw data")"
                    )
                    // Detect expired token (401)
                    if response.response?.statusCode == 401 {
                        print("⚠️ Unauthorized — token may be expired")
                        SessionManager.shared.logout()
                    }
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    // MARK: - Generic PUT (Form-Data)
    func putFormData<T: Decodable>(
        _ endpoint: String,
        formDataBuilder: @escaping (MultipartFormData) -> Void,
        headers: HTTPHeaders? = nil,
        responseType: T.Type
    ) async throws -> T {
        var finalHeaders: HTTPHeaders = headers ?? []
        if let token = accessToken {
            finalHeaders.add(.authorization(bearerToken: token))
        }

        let url = "\(baseURL)\(endpoint)"

        return try await withCheckedThrowingContinuation { continuation in
            AF.upload(
                multipartFormData: formDataBuilder,
                to: url,
                method: .put,
                headers: finalHeaders
            )
            .validate()
            .responseDecodable(of: T.self) { response in
                switch response.result {
                case .success(let decoded):
                    continuation.resume(returning: decoded)
                case .failure(let error):
                    print(
                        "🚨 PUT Request Failed. Error: \(error.localizedDescription)"
                    )
                    print(
                        "📄 Raw failure data: \(String(data: response.data ?? Data(), encoding: .utf8) ?? "Unable to decode raw data")"
                    )
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func downloadFile(
        _ endpoint: String,
        method: HTTPMethod = .get,
        parameters: Parameters? = nil,
        encoding: ParameterEncoding = URLEncoding.default,
        headers: HTTPHeaders? = nil
    ) async throws -> URL {
        var finalHeaders: HTTPHeaders = headers ?? []

        // Inject Bearer token if available
        if let token = accessToken {
            finalHeaders.add(.authorization(bearerToken: token))
            print(token)
        }

        let url = "\(baseURL)\(endpoint)"
        print(url)

        return try await withCheckedThrowingContinuation { continuation in
            AF.request(
                url,
                method: method,
                parameters: parameters,
                encoding: encoding,
                headers: finalHeaders
            )
            .validate()
            .responseData { response in
                switch response.result {
                case .success(let data):
                    print(data)
                    print(response)
                    let fileName = "weekly_reports.zip"
                    let destinationURL = FileManager.default.urls(
                        for: .documentDirectory,
                        in: .userDomainMask
                    )[0].appendingPathComponent(fileName)

                    do {
                        if FileManager.default.fileExists(atPath: destinationURL.path) {
                            try FileManager.default.removeItem(at: destinationURL)
                        }
                        try data.write(to: destinationURL)
                        continuation.resume(returning: destinationURL)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                case .failure(let error):
                    print(
                        "🚨 File download failed: \(error.localizedDescription)"
                    )
                    if let data = response.data {
                        print(
                            "📄 Raw response: \(String(data: data, encoding: .utf8) ?? "")"
                        )
                    }
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
