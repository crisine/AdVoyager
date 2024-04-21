//
//  TargetType.swift
//  LSLPBasic
//
//  Created by Minho on 4/9/24.
//

import Foundation
import Alamofire

protocol TargetType: URLRequestConvertible {
    
    var baseURL: String { get }
    var method: HTTPMethod { get }
    var path: String { get }
    var header: [String: String] { get }
    var parameters: String? { get }
    var queryItems: [URLQueryItem]? { get }
    var body: Data? { get }
    
}

extension TargetType {
    
    func asURLRequest() throws -> URLRequest {
        
        // Router의 QueryItems를 사용하기 위해 url body에 queryItem 추가
        var components = URLComponents(string: baseURL.appending(path))
        components?.queryItems = queryItems
        
        guard let componentsURL = components?.url else { throw URLError(.badURL) }
        var urlRequest = try URLRequest(url: componentsURL, method: method)
        urlRequest.allHTTPHeaderFields = header
        urlRequest.httpBody = parameters?.data(using: .utf8)
        urlRequest.httpBody = body
        return urlRequest
    }
    
}
