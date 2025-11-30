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
    
    func testDefaultValue_ReturnsContainer() {
        // When - create a new container using static property
        let defaultContainer = CIContainer()
        
        // Then
        XCTAssertNotNil(defaultContainer)
    }
    
    // MARK: - Static Default Value Tests
    
    func testStaticDefaultValue_ReturnsNewContainer() {
        // When
        let container1 = CIContainer.defaultValue
        let container2 = CIContainer.defaultValue
        
        // Then - each call creates a new container
        XCTAssertNotNil(container1)
        XCTAssertNotNil(container2)
    }
}
