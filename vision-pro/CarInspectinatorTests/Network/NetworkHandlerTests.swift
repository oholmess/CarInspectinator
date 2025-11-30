//
//  NetworkHandlerTests.swift
//  CarInspectinatorTests
//
//  Unit tests for NetworkHandler
//

import XCTest
@testable import CarInspectinator

final class NetworkHandlerTests: XCTestCase {
    
    var sut: NetworkHandler!
    var mockLogger: MockLogger!
    var mockURLSession: URLSession!
    
    override func setUp() {
        super.setUp()
        mockLogger = MockLogger()
        
        // Use a default configuration for testing
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [MockURLProtocol.self]
        mockURLSession = URLSession(configuration: configuration)
        
        sut = NetworkHandler(logger: mockLogger, urlSession: mockURLSession)
    }
    
    override func tearDown() {
        sut = nil
        mockLogger = nil
        mockURLSession = nil
        MockURLProtocol.mockData = nil
        MockURLProtocol.mockError = nil
        MockURLProtocol.mockStatusCode = 200
        super.tearDown()
    }
    
    // MARK: - Request Tests
    
    func testRequestSuccessReturnsData() async throws {
        // Arrange
        let testURL = URL(string: "https://test.com/api")!
        let expectedData = "test data".data(using: .utf8)!
        
        MockURLProtocol.mockData = expectedData
        MockURLProtocol.mockStatusCode = 200
        
        // Act
        let result = try await sut.request(testURL)
        
        // Assert
        XCTAssertEqual(result, expectedData)
    }
    
    func testRequestWithInvalidStatusCodeThrowsError() async {
        // Arrange
        let testURL = URL(string: "https://test.com/api")!
        MockURLProtocol.mockStatusCode = 404
        MockURLProtocol.mockData = Data()
        
        // Act & Assert
        do {
            _ = try await sut.request(testURL)
            XCTFail("Expected error to be thrown")
        } catch let error as NetworkError {
            if case .failedStatusCodeResponseData(let code, _) = error {
                XCTAssertEqual(code, 404)
            } else {
                XCTFail("Wrong error type")
            }
        }
    }
    
    func testRequestLogsHTTPMethod() async throws {
        // Arrange
        let testURL = URL(string: "https://test.com/api")!
        MockURLProtocol.mockData = Data()
        MockURLProtocol.mockStatusCode = 200
        
        // Act
        _ = try await sut.request(testURL, httpMethod: "POST")
        
        // Assert
        XCTAssertTrue(mockLogger.hasLoggedMessage(containing: "POST", level: .debug))
    }
    
    // MARK: - Decodable Request Tests
    
    func testRequestWithDecodableSuccess() async throws {
        // Arrange
        struct TestResponse: Codable {
            let name: String
            let value: Int
        }
        
        let testURL = URL(string: "https://test.com/api")!
        let testObject = TestResponse(name: "test", value: 42)
        let testData = try JSONEncoder().encode(testObject)
        
        MockURLProtocol.mockData = testData
        MockURLProtocol.mockStatusCode = 200
        
        // Act
        let result: TestResponse = try await sut.request(
            testURL,
            responseType: TestResponse.self
        )
        
        // Assert
        XCTAssertEqual(result.name, "test")
        XCTAssertEqual(result.value, 42)
    }
    
    func testRequestWithInvalidJSONThrowsDecodingError() async {
        // Arrange
        struct TestResponse: Codable {
            let name: String
        }
        
        let testURL = URL(string: "https://test.com/api")!
        let invalidData = "invalid json".data(using: .utf8)!
        
        MockURLProtocol.mockData = invalidData
        MockURLProtocol.mockStatusCode = 200
        
        // Act & Assert
        do {
            let _: TestResponse = try await sut.request(
                testURL,
                responseType: TestResponse.self
            )
            XCTFail("Expected error to be thrown")
        } catch is NetworkError {
            // Expected
        } catch {
            XCTFail("Wrong error type: \(error)")
        }
    }
    
    // MARK: - JSON Serialization Tests
    
    func testRequestWithJSONDictionarySerializesCorrectly() async throws {
        // Arrange
        let testURL = URL(string: "https://test.com/api")!
        let jsonDict: [String: Any] = ["key": "value", "number": 42]
        
        MockURLProtocol.mockData = Data()
        MockURLProtocol.mockStatusCode = 200
        
        // Act
        _ = try await sut.request(testURL, jsonDictionary: jsonDict, httpMethod: "POST")
        
        // Assert
        // If no error is thrown, serialization succeeded
        XCTAssertTrue(mockLogger.messageCount(for: .debug) > 0)
    }
    
    func testRequestWithInvalidJSONDictionaryThrowsError() async {
        // Arrange
        let testURL = URL(string: "https://test.com/api")!
        // Create an object that can't be serialized to JSON
        class NonSerializable {}
        let jsonDict: [String: Any] = ["object": NonSerializable()]
        
        // Act & Assert
        do {
            _ = try await sut.request(testURL, jsonDictionary: jsonDict, httpMethod: "POST")
            XCTFail("Expected error to be thrown")
        } catch is NetworkError {
            // Expected
            XCTAssertTrue(mockLogger.hasLoggedMessage(containing: "Failed to serialize", level: .error))
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
}

// MARK: - Mock URL Protocol

class MockURLProtocol: URLProtocol {
    static var mockData: Data?
    static var mockError: Error?
    static var mockStatusCode: Int = 200
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        if let error = MockURLProtocol.mockError {
            client?.urlProtocol(self, didFailWithError: error)
            return
        }
        
        let response = HTTPURLResponse(
            url: request.url!,
            statusCode: MockURLProtocol.mockStatusCode,
            httpVersion: nil,
            headerFields: nil
        )!
        
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        
        if let data = MockURLProtocol.mockData {
            client?.urlProtocol(self, didLoad: data)
        }
        
        client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {}
}

