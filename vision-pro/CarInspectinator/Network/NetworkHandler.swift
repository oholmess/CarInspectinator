//
//  NetworkHandler.swift
//  CarInspectinator
//
//  Refactored to follow Single Responsibility and Dependency Inversion principles
//

import Foundation

enum HttpMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

enum ContentType: String {
    case json = "application/json; charset=utf-8"
}

// MARK: - Protocol (Dependency Inversion Principle)

protocol NetworkHandlerProtocol {
    func request(
        _ url: URL,
        jsonDictionary: Any?,
        httpMethod: String,
        contentType: String,
        accessToken: String?
    ) async throws -> Data
    
    func request<ResponseType: Decodable>(
        _ url: URL,
        jsonDictionary: Any?,
        responseType: ResponseType.Type,
        httpMethod: String,
        contentType: String,
        accessToken: String?
    ) async throws -> ResponseType
}

// MARK: - Implementation

class NetworkHandler: NetworkHandlerProtocol {
    private let logger: LoggerProtocol
    private let urlSession: URLSession
    
    init(
        logger: LoggerProtocol = LoggerFactory.shared.logger(for: "Network"),
        urlSession: URLSession = .shared
    ) {
        self.logger = logger
        self.urlSession = urlSession
    }
    
    func request(
        _ url: URL,
        jsonDictionary: Any? = nil,
        httpMethod: String = HttpMethod.get.rawValue,
        contentType: String = ContentType.json.rawValue,
        accessToken: String? = nil
    ) async throws -> Data {
        var urlRequest = makeUrlRequest(url, httpMethod: httpMethod, contentType: contentType, accessToken: accessToken)
        
        if let jsonDictionary {
            guard let httpBody = try? JSONSerialization.data(withJSONObject: jsonDictionary) else {
                logger.error("Failed to serialize object to JSON data", file: #file, function: #function, line: #line)
                throw NetworkError.encodingError
            }
            urlRequest.httpBody = httpBody
        }
        
        let (data, response) = try await urlSession.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            logger.error("Could not create HTTPURLResponse for url: \(urlRequest.url?.absoluteString ?? "")", file: #file, function: #function, line: #line)
            throw NetworkError.noResponse
        }
        
        let statusCode = httpResponse.statusCode
        guard 200...299 ~= statusCode else {
            logger.error("Failed status code: \(statusCode)", file: #file, function: #function, line: #line)
            throw NetworkError.failedStatusCodeResponseData(statusCode, data)
        }
        
        return data
    }
    
    func request<ResponseType: Decodable>(
        _ url: URL,
        jsonDictionary: Any? = nil,
        responseType: ResponseType.Type,
        httpMethod: String = HttpMethod.get.rawValue,
        contentType: String = ContentType.json.rawValue,
        accessToken: String? = nil
    ) async throws -> ResponseType {
        let data = try await request(
            url, 
            jsonDictionary: jsonDictionary, 
            httpMethod: httpMethod, 
            contentType: contentType, 
            accessToken: accessToken
        )
        
        do {
            let decoded = try JSONDecoder().decode(responseType, from: data)
            logger.debug("Successfully decoded response of type \(ResponseType.self)", file: #file, function: #function, line: #line)
            return decoded
        } catch {
            logger.error("Failed to decode response: \(error.localizedDescription)", file: #file, function: #function, line: #line)
            throw NetworkError.decodingError
        }
    }
    
    // MARK: - Private Helpers
    
    private func makeUrlRequest(
        _ url: URL,
        httpMethod: String,
        contentType: String?,
        accessToken: String?
    ) -> URLRequest {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = httpMethod
        logger.debug("HTTP Method: \(httpMethod)", file: #file, function: #function, line: #line)
        
        if let contentType {
            urlRequest.addValue(contentType, forHTTPHeaderField: "Content-Type")
            
            if contentType.contains("json") {
                urlRequest.addValue(contentType, forHTTPHeaderField: "Accept")
            }
        }
        
        if let accessToken {
            let authorizationKey = "Bearer \(accessToken)"
            urlRequest.addValue(authorizationKey, forHTTPHeaderField: "Authorization")
        }
        
        return urlRequest
    }
}
