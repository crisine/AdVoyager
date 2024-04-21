//
//  NetworkManager.swift
//  LSLPBasic
//
//  Created by Minho on 4/9/24.
//

import Foundation
import RxSwift
import RxCocoa
import Alamofire
import Kingfisher

struct LoginModel: Decodable {
    let accessToken: String
    let refreshToken: String
}

struct SignUpModel: Decodable {
    let user_id: String
    let email: String
    let nick: String
}

struct ProfileModel: Decodable {
    let user_id: String
    let email: String
    let nick: String
    let phoneNum: String?
    let birthDay: String?
    let profileImage: String?
    let followers: [Follower]
}

struct Follower: Decodable {
    let user_id: String
    let nick: String
    let profileImage: String
}

struct PostModel: Decodable {
    let data: [Post]
}

struct Post: Decodable {
    let post_id: String
    let product_id: String
    let title: String?
    let content: String?
    let content1: String?
    let content2: String?
    let content3: String?
    let content4: String?
    let content5: String?
    let createdAt: String
    let creator: Creator
    let files: [String]
    let likes: [String]
    let likes2: [String]
    let hashTags: [String]
    let comments: [Comment]
}

struct Creator: Decodable {
    let user_id: String
    let nick: String
    let profileImage: String?
}

struct Comment: Decodable {
    let comment_id: String
    let content: String
    let createdAt: String
    let creator: Creator
}


struct NetworkManager {
    
    static let kingfisherImageRequest = AnyModifier { request in
        var requestBody = request
        
        requestBody.setValue(UserDefaults.standard.string(forKey: "accessToken"), forHTTPHeaderField: HTTPHeader.authorization.rawValue)
        requestBody.setValue(APIKey.sesacKey.rawValue, forHTTPHeaderField: HTTPHeader.sesacKey.rawValue)
        
        return requestBody
    }
    
    static func createLogin(query: LoginQuery) -> Single<LoginModel> {
        return Single<LoginModel>.create { single in
            do {
                // MARK: url, parameter, encoder, header 등등이 이 LoginQuery모델 안에 다 들어있으므로 이렇게 짧은 문장으로 API콜이 가능해진다.
                let urlRequest = try Router.login(query: query).asURLRequest()
                                
                AF.request(urlRequest)
                    .validate(statusCode: 200..<300)
                    .responseDecodable(of: LoginModel.self) { response in
                        switch response.result {
                        case .success(let loginModel):
                            single(.success(loginModel))
                        case .failure(let error):
                            single(.failure(error))
                        }
                    }
            } catch {
                single(.failure(error))
            }
            
            return Disposables.create()
        }
    }
    
    static func createSignUp(query: SignUpQuery) -> Single<SignUpModel> {
        return Single<SignUpModel>.create { single in
            do {
                let urlRequest = try Router.signUp(query: query).asURLRequest()
                                
                print("쿼리 내용: \(query)")
                
                AF.request(urlRequest)
                    .validate(statusCode: 200..<300)
                    .responseDecodable(of: SignUpModel.self) { response in
                        switch response.result {
                        case .success(let signUpModel):
                            single(.success(signUpModel))
                        case .failure(let error):
                            single(.failure(error))
                        }
                    }
            } catch {
                single(.failure(error))
            }
            
            return Disposables.create()
        }
    }
    
    static func fetchProfile() -> Single<ProfileModel> {
        return Single<ProfileModel>.create { single in
            do {
                let urlRequest = try Router.profile.asURLRequest()
                
                AF.request(urlRequest)
                    .validate(statusCode: 200..<300)
                    .responseDecodable(of: ProfileModel.self) { response in
                        switch response.result {
                        case .success(let profileModel):
                            single(.success(profileModel))
                        case .failure(let error):
                            single(.failure(error))
                        }
                    }
            } catch {
                single(.failure(error))
            }
            
            return Disposables.create()
        }
    }
    
    static func editProfile(query: EditProfileQuery) -> Single<ProfileModel> {
        return Single<ProfileModel>.create { single in
            do {
                let urlRequest = try Router.editProfile(query: query).asURLRequest()
                
                AF.upload(multipartFormData: Router.editProfile(query: query).multipart, with: urlRequest)
                .validate(statusCode: 200..<300)
                .responseDecodable(of: ProfileModel.self) { response in
                    switch response.result {
                    case .success(let profileModel):
                        single(.success(profileModel))
                    case .failure(let error):
                        single(.failure(error))
                    }
                }
                
            } catch {
                print("프로필 수정 과정에서 에러 발생: ",error, error.localizedDescription)
                single(.failure(error))
            }
            
            return Disposables.create()
        }
    }
    
    static func fetchPost(query: PostQuery) -> Single<PostModel> {
        return Single<PostModel>.create { single in
            do {
                let urlRequest = try Router.fetchPost(query: query).asURLRequest()
                
                AF.request(urlRequest)
                    .validate(statusCode: 200..<300)
                    .responseDecodable(of: PostModel.self) { response in
                        switch response.result {
                        case .success(let postModel):
                            print("post 조회 성공")
                            single(.success(postModel))
                        case .failure(let error):
                            print("post 조회 실패: \(error)")
                            single(.failure(error))
                        }
                    }
            } catch {
                single(.failure(error))
            }
            
            return Disposables.create()
        }
    }
}
