//
//  LoggingService.swift
//  CarInspectinator
//
//  Logging service following Dependency Inversion Principle
//

import Foundation
import OSLog

/// Logging levels
enum LogLevel {
    case debug
    case info
    case warning
    case error
}

/// Protocol for logging (enables testing and flexibility)
protocol LoggerProtocol {
    func log(_ message: String, level: LogLevel, file: String, function: String, line: Int)
    func debug(_ message: String, file: String, function: String, line: Int)
    func info(_ message: String, file: String, function: String, line: Int)
    func warning(_ message: String, file: String, function: String, line: Int)
    func error(_ message: String, file: String, function: String, line: Int)
}

/// Default implementation using OSLog
final class Logger: LoggerProtocol {
    private let subsystem: String
    private let category: String
    private let osLog: OSLog
    
    init(subsystem: String = Bundle.main.bundleIdentifier ?? "CarInspectinator", 
         category: String) {
        self.subsystem = subsystem
        self.category = category
        self.osLog = OSLog(subsystem: subsystem, category: category)
    }
    
    func log(_ message: String, level: LogLevel, file: String = #file, function: String = #function, line: Int = #line) {
        let fileName = (file as NSString).lastPathComponent
        let formattedMessage = "[\(fileName):\(line)] \(function) - \(message)"
        
        let osLogType: OSLogType
        switch level {
        case .debug:
            osLogType = .debug
        case .info:
            osLogType = .info
        case .warning:
            osLogType = .default
        case .error:
            osLogType = .error
        }
        
        os_log("%{public}@", log: osLog, type: osLogType, formattedMessage)
    }
    
    func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .debug, file: file, function: function, line: line)
    }
    
    func info(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .info, file: file, function: function, line: line)
    }
    
    func warning(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .warning, file: file, function: function, line: line)
    }
    
    func error(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .error, file: file, function: function, line: line)
    }
}

/// Logger factory for creating loggers by category
final class LoggerFactory {
    static let shared = LoggerFactory()
    
    private init() {}
    
    func logger(for category: String) -> LoggerProtocol {
        Logger(category: category)
    }
}

