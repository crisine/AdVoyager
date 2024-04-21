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
    case editProfile(query: EditProfileQuery)
    case fetchPost(query: PostQuery)
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
        case .editProfile: .put
        case .fetchPost: .get
        }
    }
    
    var path: String {
        switch self {
        case .login: "/users/login"
        case .signUp: "/users/join"
        case .profile: "/users/me/profile"
        case .editProfile: "/users/me/profile"
        case .fetchPost: "/posts"
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
        case .editProfile:
            [HTTPHeader.authorization.rawValue: UserDefaults.standard.string(forKey: "accessToken") ?? "",
             HTTPHeader.contentType.rawValue: HTTPHeader.multipart.rawValue,
             HTTPHeader.sesacKey.rawValue: APIKey.sesacKey.rawValue]
        case .fetchPost:
            [HTTPHeader.authorization.rawValue: UserDefaults.standard.string(forKey: "accessToken") ?? "",
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
        let encoder = JSONEncoder()
        switch self {
        case .login(let query):
            encoder.keyEncodingStrategy = .convertToSnakeCase
            return try? encoder.encode(query)
        case .signUp(let query):
            encoder.keyEncodingStrategy = .convertToSnakeCase
            return try? encoder.encode(query)
        case .profile:
            return nil
        case .editProfile:
            return nil
        case .fetchPost(let query):
            return nil
        }
    }
    
    var multipart: MultipartFormData {
        let multipart = MultipartFormData()
        
        switch self {
        case .login:
            return multipart
        case .signUp:
            return multipart
        case .profile:
            return multipart
        case .editProfile(let query):
            let multipart = MultipartFormData()
            
            let birthDay = query.birthDay.data(using: .utf8) ?? Data()
            let nick = query.nick.data(using: .utf8) ?? Data()
            let phoneNum = query.phoneNum.data(using: .utf8) ?? Data()
            let profile = query.profile
            
            multipart.append(birthDay, withName: "birthDay")
            multipart.append(nick, withName: "nick")
            multipart.append(phoneNum, withName: "phoneNum")
            multipart.append(profile, withName: "profile", fileName: "profileImage.jpeg", mimeType: "image/jpeg")
            
            return multipart
        case .fetchPost(let query):
            return multipart
        }
    }
}
