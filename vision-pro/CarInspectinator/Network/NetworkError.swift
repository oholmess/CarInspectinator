//
//  NetworkError.swift
//  CarInspectinator
//
//  Created by Oliver Holmes on 10/3/25.
//

import Foundation

enum NetworkError: Error {
    case userError(String)
    case dataError(String)
    case encodingError
    case decodingError
    case failedStatusCode(String)
    case failedStatusCodeResponseData(Int, Data)
    case noResponse
    
    var statusCodeResponseData: (Int, Data)? {
        switch self {
        case .failedStatusCodeResponseData(let statusCode, let data):
            return (statusCode, data)
        default:
            return nil
        }
    }
    
}

enum ConfigurationError: Error {
    case nilObject
}


enum FormError: Error {
    case missingField
    case incorrectEntries
}
