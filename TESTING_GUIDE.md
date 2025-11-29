# Testing Guide

## Overview
This document provides comprehensive information about the testing strategy, test coverage, and how to run tests for the CarInspectinator project.

## Test Coverage Goal: 70%+

The project aims for **at least 70% code coverage** across all components, with the following breakdown:

### Current Coverage by Component

| Component | Coverage Target | Test Count | Status |
|-----------|----------------|------------|--------|
| MeasurementCodec | 90%+ | 20+ tests | ✅ Complete |
| NetworkHandler | 80%+ | 10+ tests | ✅ Complete |
| CarService | 85%+ | 12+ tests | ✅ Complete |
| ModelDownloader | 75%+ | 10+ tests | ✅ Complete |
| HomePageViewModel | 85%+ | 12+ tests | ✅ Complete |
| Integration Tests | N/A | 10+ tests | ✅ Complete |

## Test Structure

```
CarInspectinatorTests/
├── Mocks/
│   ├── MockLogger.swift
│   ├── MockNetworkHandler.swift
│   ├── MockCarService.swift
│   ├── MockConfigurationService.swift
│   └── MockModelDownloader.swift
├── Utilities/
│   └── MeasurementCodecTests.swift
├── Network/
│   └── NetworkHandlerTests.swift
├── Services/
│   ├── CarServiceTests.swift
│   └── ModelDownloaderTests.swift
├── ViewModels/
│   └── HomePageViewModelTests.swift
└── Integration/
    └── CarServiceIntegrationTests.swift
```

## Running Tests

### Command Line

```bash
# Run all tests
cd vision-pro
xcodebuild test \
  -project CarInspectinator.xcodeproj \
  -scheme CarInspectinator \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
  -enableCodeCoverage YES

# Run specific test class
xcodebuild test \
  -project CarInspectinator.xcodeproj \
  -scheme CarInspectinator \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
  -only-testing:CarInspectinatorTests/CarServiceTests

# Run specific test method
xcodebuild test \
  -project CarInspectinator.xcodeproj \
  -scheme CarInspectinator \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
  -only-testing:CarInspectinatorTests/CarServiceTests/testGetCarsSuccess
```

### Xcode

1. Open `CarInspectinator.xcodeproj`
2. Select the test navigator (⌘6)
3. Click the play button next to a test class or individual test
4. View results in the test navigator

### Coverage Report

```bash
# Generate coverage report
xcrun xccov view --report DerivedData/Logs/Test/*.xcresult

# Generate JSON coverage report
xcrun xccov view --report --json DerivedData/Logs/Test/*.xcresult > coverage.json

# View coverage for specific file
xcrun xccov view --file CarService.swift DerivedData/Logs/Test/*.xcresult
```

## Test Types

### 1. Unit Tests

**Purpose**: Test individual components in isolation

**Examples**:
- `MeasurementCodecTests` - Tests measurement encoding/decoding
- `CarServiceTests` - Tests car service methods
- `NetworkHandlerTests` - Tests network layer

**Characteristics**:
- Fast execution (< 1s per test)
- Uses mocks/stubs for dependencies
- Focuses on single responsibility
- High coverage of edge cases

### 2. Integration Tests

**Purpose**: Test interactions between components

**Examples**:
- `CarServiceIntegrationTests` - Tests full service stack
- Tests dependency injection container
- Tests data flow through layers

**Characteristics**:
- Medium execution time (1-5s per test)
- May use real dependencies
- Tests component interactions
- Validates SOLID principles

### 3. UI Tests (Future)

**Purpose**: Test user interface and user flows

**Status**: To be implemented

**Planned Tests**:
- Home page car list display
- Car detail view navigation
- 3D model loading
- Error state handling

## Mock Objects

All protocol-based dependencies have corresponding mock implementations for testing:

### MockLogger
```swift
let logger = MockLogger()
// Use in tests
logger.hasLoggedMessage(containing: "test", level: .info)
logger.messageCount(for: .error)
```

### MockNetworkHandler
```swift
let networkHandler = MockNetworkHandler()
networkHandler.mockData = testData
networkHandler.shouldThrowError = true
```

### MockCarService
```swift
let carService = MockCarService()
carService.mockCars = [testCar]
carService.shouldThrowError = false
```

### MockModelDownloader
```swift
let downloader = MockModelDownloader()
downloader.mockCachedFiles.insert("test-model")
```

## Writing New Tests

### Test Naming Convention

```swift
func test[ComponentName][Scenario][ExpectedBehavior]() {
    // Example:
    // testGetCarsSuccess()
    // testGetCarsNetworkFailure()
    // testGetCarsLogsSuccessMessage()
}
```

### Test Structure (AAA Pattern)

```swift
func testExample() {
    // Arrange - Set up test data and mocks
    let mockService = MockCarService()
    mockService.mockCars = [testCar]
    let sut = HomePageViewModel(carService: mockService)
    
    // Act - Execute the code under test
    try await sut.getCars()
    
    // Assert - Verify the results
    XCTAssertEqual(sut.cars.count, 1)
    XCTAssertFalse(sut.isLoading)
}
```

### Best Practices

1. **One assertion per test** (when possible)
2. **Test one thing at a time**
3. **Use descriptive test names**
4. **Clean up resources in tearDown()**
5. **Use mocks for external dependencies**
6. **Test both success and failure cases**
7. **Test edge cases and boundary conditions**

## Continuous Integration

### GitHub Actions

The CI pipeline automatically:
1. Builds the application
2. Runs all tests
3. Measures code coverage
4. Fails if coverage < 70%
5. Generates coverage report
6. Comments coverage on PRs

### Configuration

See `.github/workflows/ci.yml` for full configuration.

### Coverage Threshold

The CI pipeline enforces a **70% minimum coverage threshold**. Builds fail if coverage drops below this level.

## Coverage Report

### Viewing Reports

After running tests with coverage enabled:

```bash
# Text report
xcrun xccov view --report DerivedData/Logs/Test/*.xcresult

# JSON report
xcrun xccov view --report --json DerivedData/Logs/Test/*.xcresult

# HTML report (using xcov gem)
gem install xcov
xcov --scheme CarInspectinator
```

### Interpreting Results

- **Green (80-100%)**: Excellent coverage
- **Yellow (70-80%)**: Acceptable coverage
- **Red (< 70%)**: Insufficient coverage - add more tests

### Example Output

```
CarInspectinator.app
├── Services
│   ├── CarService.swift: 92.3% (24/26 lines)
│   ├── ModelDownloader.swift: 85.7% (42/49 lines)
│   └── ConfigurationService.swift: 100.0% (12/12 lines)
├── Utilities
│   ├── MeasurementCodec.swift: 95.2% (40/42 lines)
│   └── ErrorHandler.swift: 88.9% (16/18 lines)
└── Network
    ├── NetworkHandler.swift: 87.5% (35/40 lines)
    └── NetworkRoutes.swift: 100.0% (15/15 lines)

Total Coverage: 89.4%
```

## Test Maintenance

### Adding Tests for New Features

1. Create test file in appropriate directory
2. Follow naming conventions
3. Create mocks if needed
4. Write unit tests first
5. Add integration tests
6. Verify coverage meets threshold

### Updating Tests

When modifying code:
1. Update affected tests
2. Run tests locally
3. Verify coverage hasn't decreased
4. Fix failing tests before committing

### Deleting Tests

Only delete tests when:
- Code being tested is removed
- Test is redundant
- Test is replaced by better test

Always check coverage impact before deleting tests.

## Troubleshooting

### Tests Failing Locally

```bash
# Clean build folder
rm -rf ~/Library/Developer/Xcode/DerivedData

# Reset simulator
xcrun simctl shutdown all
xcrun simctl erase all

# Rebuild and test
xcodebuild clean test [...]
```

### Coverage Not Generating

1. Ensure `-enableCodeCoverage YES` flag is set
2. Check that tests are running successfully
3. Verify scheme has "Gather coverage data" enabled
4. Look for `.xcresult` file in DerivedData/Logs/Test/

### CI Pipeline Failing

1. Check GitHub Actions logs
2. Verify tests pass locally
3. Check coverage percentage
4. Review error messages
5. Ensure dependencies are installed

## Test Examples

### Unit Test Example

```swift
func testCarServiceGetCarsSuccess() async throws {
    // Arrange
    let mockNetworkHandler = MockNetworkHandler()
    let testCars = [Car(make: "BMW", model: "M3")]
    let testData = try JSONEncoder().encode(testCars)
    mockNetworkHandler.mockData = testData
    
    let sut = CarService(networkHandler: mockNetworkHandler)
    
    // Act
    let result = try await sut.getCars()
    
    // Assert
    XCTAssertEqual(result.count, 1)
    XCTAssertEqual(result[0].make, "BMW")
}
```

### Integration Test Example

```swift
func testFullStackCarFetching() async throws {
    // Arrange
    let container = CIContainer()
    let viewModel = container.makeHomePageView()
    
    // Act
    try await viewModel.vm.getCars()
    
    // Assert - Verify full stack works
    XCTAssertFalse(viewModel.vm.isLoading)
    XCTAssertNil(viewModel.vm.error)
    // Note: Would verify cars loaded in real integration test
}
```

### Async Test Example

```swift
func testAsyncOperation() async throws {
    // Arrange
    let expectation = XCTestExpectation(description: "Async operation")
    
    // Act
    Task {
        try await someAsyncFunction()
        expectation.fulfill()
    }
    
    // Assert
    await fulfillment(of: [expectation], timeout: 5.0)
}
```

## Future Improvements

### Planned Enhancements

1. **UI Testing**
   - Add UI tests for critical user flows
   - Test 3D model rendering
   - Test navigation and transitions

2. **Performance Testing**
   - Add performance benchmarks
   - Test memory usage
   - Test model loading times

3. **Snapshot Testing**
   - Add view snapshot tests
   - Ensure consistent UI rendering

4. **Test Parallelization**
   - Enable parallel test execution
   - Reduce CI pipeline time

5. **Code Coverage Dashboard**
   - Create visual coverage dashboard
   - Track coverage trends over time
   - Set per-file coverage targets

## Resources

- [XCTest Documentation](https://developer.apple.com/documentation/xctest)
- [Testing in Xcode](https://developer.apple.com/documentation/xcode/testing-your-apps-in-xcode)
- [Code Coverage in Xcode](https://developer.apple.com/documentation/xcode/code-coverage)
- [GitHub Actions for iOS](https://docs.github.com/en/actions/guides/building-and-testing-swift)

## Summary

- ✅ 70%+ code coverage requirement
- ✅ Comprehensive unit tests
- ✅ Integration tests
- ✅ CI/CD pipeline with coverage enforcement
- ✅ Mock implementations for all protocols
- ✅ Automated test reports

**Current Overall Coverage: Target 70%+ (to be measured on first CI run)**

The testing infrastructure is now in place to ensure code quality and maintainability throughout the project lifecycle.

