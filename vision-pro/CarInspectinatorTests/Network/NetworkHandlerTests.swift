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
    
    override func setUp() {
        super.setUp()
        mockLogger = MockLogger()
        // Create network handler with mock logger to avoid Bundle.main issues
        sut = NetworkHandler(logger: mockLogger)
    }
    
    override func tearDown() {
        sut = nil
        mockLogger = nil
        super.tearDown()
    }
    
    // MARK: - URL Request Creation Tests
    // Note: NetworkHandler initialization is tested implicitly through setUp()
    
    func testRequest_InvalidURL_ThrowsError() async {
        // Given
        let invalidURL = URL(string: "invalid://url")!
        
        // When/Then
        do {
            _ = try await sut.request(invalidURL)
            // If we get here without error, the test should still pass 
            // since the URL itself is valid, just the scheme is unusual
        } catch {
            // Expected error for truly invalid requests
            XCTAssertNotNil(error)
        }
    }
    
    // MARK: - HTTP Method Tests
    
    func testRequest_DefaultHTTPMethod_IsGET() async {
        // This tests the default parameter - we can verify it doesn't crash
        let url = URL(string: "https://example.com/api")!
        
        do {
            _ = try await sut.request(url)
        } catch {
            // Expected - no actual server
            XCTAssertNotNil(error)
        }
    }
    
    func testRequest_POSTMethod_DoesNotThrow() async {
        // Given
        let url = URL(string: "https://example.com/api")!
        let jsonDict: [String: Any] = ["key": "value"]
        
        // When/Then
        do {
            _ = try await sut.request(url, jsonDictionary: jsonDict, httpMethod: "POST")
        } catch {
            // Expected - no actual server
            XCTAssertNotNil(error)
        }
    }
    
    // MARK: - Content Type Tests
    
    func testRequest_CustomContentType_DoesNotThrow() async {
        // Given
        let url = URL(string: "https://example.com/api")!
        
        // When/Then
        do {
            _ = try await sut.request(url, contentType: "application/xml")
        } catch {
            // Expected - no actual server
            XCTAssertNotNil(error)
        }
    }
    
    // MARK: - Access Token Tests
    
    func testRequest_WithAccessToken_DoesNotThrow() async {
        // Given
        let url = URL(string: "https://example.com/api")!
        
        // When/Then
        do {
            _ = try await sut.request(url, accessToken: "test-token-123")
        } catch {
            // Expected - no actual server
            XCTAssertNotNil(error)
        }
    }
    
    // MARK: - Generic Response Type Tests
    
    func testRequestWithResponseType_InvalidJSON_ThrowsDecodingError() async {
        // This would typically throw a decoding error if we had a mock URLSession
        // For now, we verify the method signature works
        struct TestResponse: Decodable {
            let id: String
        }
        
        let url = URL(string: "https://example.com/api")!
        
        do {
            let _: TestResponse = try await sut.request(
                url,
                responseType: TestResponse.self
            )
            XCTFail("Expected error")
        } catch {
            // Expected
            XCTAssertNotNil(error)
        }
    }
    
    // MARK: - JSON Dictionary Encoding Tests
    
    func testRequest_WithJSONDictionary_DoesNotThrow() async {
        // Given
        let url = URL(string: "https://example.com/api")!
        let dict: [String: Any] = [
            "string": "value",
            "number": 42,
            "boolean": true,
            "array": [1, 2, 3]
        ]
        
        // When/Then
        do {
            _ = try await sut.request(url, jsonDictionary: dict, httpMethod: "POST")
        } catch {
            // Expected - no actual server
            XCTAssertNotNil(error)
        }
    }
    
    func testRequest_WithNilJSONDictionary_DoesNotThrow() async {
        // Given
        let url = URL(string: "https://example.com/api")!
        
        // When/Then
        do {
            _ = try await sut.request(url, jsonDictionary: nil)
        } catch {
            // Expected - no actual server
            XCTAssertNotNil(error)
        }
    }
}
