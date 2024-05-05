//
//  Decodable+Extension.swift
//  AdVoyager
//
//  Created by Minho on 5/4/24.
//

import Foundation

extension Decodable {
    static func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        let decoder = JSONDecoder()
        return try decoder.decode(type, from: data)
    }
    
    static func decode<T: Decodable>(_ type: T.Type, from string: String) throws -> T {
        guard let data = string.data(using: .utf8) else {
            throw NSError(domain: "com.mydomain.app", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid string data"])
        }
        return try decode(type, from: data)
    }
}
