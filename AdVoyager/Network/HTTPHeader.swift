//
//  HTTPHeader.swift
//  LSLPBasic
//
//  Created by Minho on 4/9/24.
//

import Foundation

enum HTTPHeader: String {
    case authorization = "Authorization"
    case sesacKey = "SesacKey"
    case refresh = "Refresh"
    case contentType = "Content-Type"
    case json = "application/json"
    case multipart = "multipart/form-data"
}
