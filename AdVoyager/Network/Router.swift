//
//  Router.swift
//  LSLPBasic
//
//  Created by Minho on 4/9/24.
//

import Foundation
import Alamofire

/*
 회원가입: up, in, email, logout
 포스트: post, get, put(update), delete
 댓글: post, get, put(update), delete
 */

enum Router {

    case login(query: LoginQuery)
    case signUp(query: SignUpQuery)
    case profile
//    case withdraw
//    case fetchPost
//    case uploadPost
}

extension Router: TargetType {
    
    var baseURL: String {
        return APIKey.baseURL.rawValue
    }
    
    var method: Alamofire.HTTPMethod {
        switch self {
        case .login: .post
        case .signUp: .post
        case .profile: .get
        }
    }
    
    var path: String {
        switch self {
        case .login: "/users/login"
        case .signUp: "/users/join"
        case .profile: "/users/me/profile"
        }
    }
    
    var header: [String : String] {
        switch self {
        case .login:
            [HTTPHeader.contentType.rawValue: HTTPHeader.json.rawValue,
             HTTPHeader.sesacKey.rawValue: APIKey.sesacKey.rawValue]
        case .signUp:
            [HTTPHeader.contentType.rawValue: HTTPHeader.json.rawValue,
             HTTPHeader.sesacKey.rawValue: APIKey.sesacKey.rawValue]
        case .profile:
            [HTTPHeader.contentType.rawValue: HTTPHeader.json.rawValue,
             HTTPHeader.authorization.rawValue: UserDefaults.standard.string(forKey: "accessToken") ?? "",
             HTTPHeader.sesacKey.rawValue: APIKey.sesacKey.rawValue]
        }
    }
    
    var parameters: String? {
        return nil
    }
    
    var queryItems: [URLQueryItem]? {
        return nil
    }
    
    var body: Data? {
        switch self {
        case .login(let query):
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            return try? encoder.encode(query)
        case .signUp(let query):
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            return try? encoder.encode(query)
        case .profile:
            return nil
        }
    }
}
