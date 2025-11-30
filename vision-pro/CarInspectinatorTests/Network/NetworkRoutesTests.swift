//
//  NetworkRoutesTests.swift
//  CarInspectinatorTests
//
//  Unit tests for NetworkRoutes
//

import XCTest
@testable import CarInspectinator

final class NetworkRoutesTests: XCTestCase {
    
    // MARK: - getCars Tests
    
    func testGetCars_URL_IsNotNil() {
        // Given
        let route = NetworkRoutes.getCars
        
        // When
        let url = route.url
        
        // Then
        XCTAssertNotNil(url)
    }
    
    func testGetCars_URL_ContainsV1Cars() {
        // Given
        let route = NetworkRoutes.getCars
        
        // When
        let url = route.url
        
        // Then
        XCTAssertTrue(url?.absoluteString.contains("/v1/cars") ?? false)
    }
    
    func testGetCars_URL_DoesNotContainCarId() {
        // Given
        let route = NetworkRoutes.getCars
        
        // When
        let url = route.url
        
        // Then
        // Should end with /cars and not have additional path components
        XCTAssertTrue(url?.absoluteString.hasSuffix("/v1/cars") ?? false)
    }
    
    func testGetCars_Method_IsGET() {
        // Given
        let route = NetworkRoutes.getCars
        
        // When
        let method = route.method
        
        // Then
        XCTAssertEqual(method, .get)
    }
    
    // MARK: - getCar Tests
    
    func testGetCar_URL_IsNotNil() {
        // Given
        let route = NetworkRoutes.getCar(carId: "test-123")
        
        // When
        let url = route.url
        
        // Then
        XCTAssertNotNil(url)
    }
    
    func testGetCar_URL_ContainsCarId() {
        // Given
        let carId = "test-car-456"
        let route = NetworkRoutes.getCar(carId: carId)
        
        // When
        let url = route.url
        
        // Then
        XCTAssertTrue(url?.absoluteString.contains(carId) ?? false)
    }
    
    func testGetCar_URL_ContainsV1Cars() {
        // Given
        let route = NetworkRoutes.getCar(carId: "test")
        
        // When
        let url = route.url
        
        // Then
        XCTAssertTrue(url?.absoluteString.contains("/v1/cars/") ?? false)
    }
    
    func testGetCar_Method_IsGET() {
        // Given
        let route = NetworkRoutes.getCar(carId: "test")
        
        // When
        let method = route.method
        
        // Then
        XCTAssertEqual(method, .get)
    }
    
    func testGetCar_URL_DifferentCarIds_ProduceDifferentURLs() {
        // Given
        let route1 = NetworkRoutes.getCar(carId: "car1")
        let route2 = NetworkRoutes.getCar(carId: "car2")
        
        // When
        let url1 = route1.url
        let url2 = route2.url
        
        // Then
        XCTAssertNotEqual(url1, url2)
    }
    
    // MARK: - URL Validation Tests
    
    func testGetCars_URL_IsHTTPS() {
        // Given
        let route = NetworkRoutes.getCars
        
        // When
        let url = route.url
        
        // Then
        XCTAssertEqual(url?.scheme, "https")
    }
    
    func testGetCar_URL_IsHTTPS() {
        // Given
        let route = NetworkRoutes.getCar(carId: "test")
        
        // When
        let url = route.url
        
        // Then
        XCTAssertEqual(url?.scheme, "https")
    }
}

