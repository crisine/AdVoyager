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
    case fetchPost(queryString: PostQuery)
    case uploadPost(query: UploadPostQuery)
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
        case .uploadPost: .post
        }
    }
    
    var path: String {
        switch self {
        case .login: "/users/login"
        case .signUp: "/users/join"
        case .profile: "/users/me/profile"
        case .editProfile: "/users/me/profile"
        case .fetchPost: "/posts"
        case .uploadPost: "/posts"
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
        case .uploadPost:
            [HTTPHeader.authorization.rawValue: UserDefaults.standard.string(forKey: "accessToken") ?? "",
             HTTPHeader.contentType.rawValue: HTTPHeader.json.rawValue,
             HTTPHeader.sesacKey.rawValue: APIKey.sesacKey.rawValue]
        }
    }
    
    var parameters: String? {
        return nil
    }
    
    var queryItems: [URLQueryItem]? {
        switch self {
        case .fetchPost(let query):
            return [
                URLQueryItem(name: "limit", value: query.limit),
                URLQueryItem(name: "next", value: query.next),
                URLQueryItem(name: "product_id", value: query.product_id)
            ]
        default:
            return nil
        }
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
        case .uploadPost(let query):
            encoder.keyEncodingStrategy = .convertToSnakeCase
            return try? encoder.encode(query)
        default:
            return nil
        }
    }
    
    var multipart: MultipartFormData {
        let multipart = MultipartFormData()
        
        switch self {
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
        default:
            return multipart
        }
    }
}
