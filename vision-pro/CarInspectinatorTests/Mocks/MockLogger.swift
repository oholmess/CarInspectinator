//
//  MockLogger.swift
//  CarInspectinatorTests
//
//  Mock implementation of LoggerProtocol for testing
//

import Foundation
@testable import CarInspectinator

final class MockLogger: LoggerProtocol {
    // Track all logged messages
    var loggedMessages: [(message: String, level: LogLevel)] = []
    
    func log(_ message: String, level: LogLevel, file: String, function: String, line: Int) {
        loggedMessages.append((message, level))
    }
    
    func debug(_ message: String, file: String, function: String, line: Int) {
        log(message, level: .debug, file: file, function: function, line: line)
    }
    
    func info(_ message: String, file: String, function: String, line: Int) {
        log(message, level: .info, file: file, function: function, line: line)
    }
    
    func warning(_ message: String, file: String, function: String, line: Int) {
        log(message, level: .warning, file: file, function: function, line: line)
    }
    
    func error(_ message: String, file: String, function: String, line: Int) {
        log(message, level: .error, file: file, function: function, line: line)
    }
    
    // Helper methods for testing
    func reset() {
        loggedMessages.removeAll()
    }
    
    func hasLoggedMessage(containing text: String, level: LogLevel? = nil) -> Bool {
        loggedMessages.contains { message in
            let matchesText = message.message.contains(text)
            if let level = level {
                return matchesText && message.level == level
            }
            return matchesText
        }
    }
    
    func messageCount(for level: LogLevel) -> Int {
        loggedMessages.filter { $0.level == level }.count
    }
}

