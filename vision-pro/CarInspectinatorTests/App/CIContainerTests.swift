//
//  CIContainerTests.swift
//  CarInspectinatorTests
//
//  Unit tests for CIContainer (Dependency Injection Container)
//

import XCTest
@testable import CarInspectinator

@MainActor
final class CIContainerTests: XCTestCase {
    
    var sut: CIContainer!
    
    override func setUp() {
        super.setUp()
        sut = CIContainer()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - loggerFactory Tests
    
    func testLoggerFactory_ReturnsLoggerFactory() {
        // When
        let factory = sut.loggerFactory
        
        // Then
        XCTAssertNotNil(factory)
    }
    
    func testLoggerFactory_ReturnsSameInstance() {
        // When
        let factory1 = sut.loggerFactory
        let factory2 = sut.loggerFactory
        
        // Then
        XCTAssertTrue(factory1 === factory2)
    }
    
    // MARK: - networkHandler Tests
    
    func testNetworkHandler_ReturnsNetworkHandler() {
        // When
        let handler = sut.networkHandler
        
        // Then
        XCTAssertNotNil(handler)
    }
    
    // MARK: - carService Tests
    
    func testCarService_ReturnsCarService() {
        // When
        let service = sut.carService
        
        // Then
        XCTAssertNotNil(service)
    }
    
    // MARK: - Default Value Tests
    // Note: CIContainer initialization is tested implicitly through setUp()
    // The static defaultValue property creates new containers which may have
    // initialization side effects in test environments.
}
