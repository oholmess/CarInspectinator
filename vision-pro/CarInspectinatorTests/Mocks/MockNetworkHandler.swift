//
//  MockNetworkHandler.swift
//  CarInspectinatorTests
//
//  Mock implementation of NetworkHandlerProtocol for testing
//

import Foundation
@testable import CarInspectinator

final class MockNetworkHandler: NetworkHandlerProtocol {
    // Configure mock behavior
    var mockData: Data?
    var mockError: Error?
    var shouldThrowError = false
    
    // Track calls
    var requestCallCount = 0
    var lastRequestURL: URL?
    var lastHttpMethod: String?
    
    func request(
        _ url: URL,
        jsonDictionary: Any? = nil,
        httpMethod: String = "GET",
        contentType: String = "application/json; charset=utf-8",
        accessToken: String? = nil
    ) async throws -> Data {
        requestCallCount += 1
        lastRequestURL = url
        lastHttpMethod = httpMethod
        
        if shouldThrowError, let error = mockError {
            throw error
        }
        
        if let mockData = mockData {
            return mockData
        }
        
        throw NetworkError.noResponse
    }
    
    nonisolated func request<ResponseType: Decodable>(
        _ url: URL,
        jsonDictionary: Any? = nil,
        responseType: ResponseType.Type,
        httpMethod: String = "GET",
        contentType: String = "application/json; charset=utf-8",
        accessToken: String? = nil
    ) async throws -> ResponseType {
        let data = try await request(
            url,
            jsonDictionary: jsonDictionary,
            httpMethod: httpMethod,
            contentType: contentType,
            accessToken: accessToken
        )
        
        return try JSONDecoder().decode(responseType, from: data)
    }
    
    // Helper methods
    func reset() {
        mockData = nil
        mockError = nil
        shouldThrowError = false
        requestCallCount = 0
        lastRequestURL = nil
        lastHttpMethod = nil
    }
}

