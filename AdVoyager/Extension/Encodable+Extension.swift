//
//  Encodable+Extension.swift
//  AdVoyager
//
//  Created by Minho on 5/4/24.
//

import Foundation

extension Encodable {
    func encode<T: Encodable>(_ value: T) throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(value)
    }
    
    func encodeToString() -> String {
        do {
            let data = try encode(self)
            return String(data: data, encoding: .utf8) ?? ""
        } catch {
            print("인코딩 에러가 발생했습니다. : \(error)")
            return ""
        }
    }
}
