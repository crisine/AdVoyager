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
    let next_cursor: String
}

struct Post: Decodable {
    let post_id: String
    let product_id: String?
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

struct ImageModel: Decodable {
    let files: [String]
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

struct AccessToken: Decodable {
    let accessToken: String
}


struct NetworkManager {
    
    static let kingfisherImageRequest = AnyModifier { request in
        var requestBody = request
        
        requestBody.setValue(UserDefaults.standard.string(forKey: "accessToken"), forHTTPHeaderField: HTTPHeader.authorization.rawValue)
        requestBody.setValue(APIKey.sesacKey.rawValue, forHTTPHeaderField: HTTPHeader.sesacKey.rawValue)
        
        return requestBody
    }
    
    // TODO: Generic Type 으로 메서드 합칠 것
    
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
                            print("로그인 성공: \(loginModel)")
                            single(.success(loginModel))
                        case .failure(let error):
                            print("로그인 실패: \(error)")
                            single(.failure(error))
                        }
                    }
            } catch {
                print("로그인 요청 실패: \(error)")
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
    
    static func uploadImage(query: UploadPostImageQuery) -> Single<ImageModel> {
        return Single<ImageModel>.create { single in
            do {
                print("이미지 업로드 통신 시작")
                let urlRequest = try Router.uploadImage(query: query).asURLRequest()
                
                AF.upload(multipartFormData: Router.uploadImage(query: query).multipart, with: urlRequest)
                    .validate(statusCode: 200..<300)
                    .responseDecodable(of: ImageModel.self) { response in
                        switch response.result {
                        case .success(let imageModel):
                            single(.success(imageModel))
                        case .failure(let error):
                            print("이미지 업로드 실패(Response Error): \(error)")
                            single(.failure(error))
                        }
                    }
            } catch {
                print("이미지 업로드 실패(AFError): \(error)")
                single(.failure(error))
            }
            
            return Disposables.create()
        }
    }
    
    static func fetchPost(query: PostQuery) -> Single<PostModel> {
        return Single<PostModel>.create { single in
            do {
                let urlRequest = try Router.fetchPost(queryString: query).asURLRequest()
                
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
    
    static func fetchSpecificPost(postId: String) -> Single<Post> {
        return Single<Post>.create { single in
            do {
                let urlRequest = try Router.fetchSpecificPost(postId: postId).asURLRequest()
                
                AF.request(urlRequest)
                    .validate(statusCode: 200..<300)
                    .responseDecodable(of: Post.self) { response in
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
    
    static func createPost(query: UploadPostQuery) -> Single<Post> {
        return Single<Post>.create { single in
            do {
                let urlRequest = try Router.uploadPost(query: query).asURLRequest()
                
                AF.request(urlRequest)
                    .responseDecodable(of: Post.self) { response in
                        switch response.result {
                        case .success(let postModel):
                            print("포스트 업로드 성공")
                            single(.success(postModel))
                        case .failure(let error):
                            dump("포스트 업로드 실패: \(error)")
                            single(.failure(error))
                        }
                    }
            } catch {
                single(.failure(error))
            }
            
            return Disposables.create()
        }
    }
    
    static func createComment(query: UploadCommentQuery, postId: String) -> Single<Comment> {
        return Single<Comment>.create { single in
            do {
                let urlRequest = try Router.uploadComment(query: query, postId: postId).asURLRequest()
                
                print("요청하려는 주소\(urlRequest)")
                
                AF.request(urlRequest)
                    .validate(statusCode: 200..<300)
                    .responseDecodable(of: Comment.self) { response in
                        switch response.result {
                        case .success(let comment):
                            single(.success(comment))
                        case .failure(let error):
                            print("댓글 업로드 실패: \(error)")
                            single(.failure(error))
                        }
                    }
            } catch {
                print("댓글 업로드 실패: \(error)")
                single(.failure(error))
            }
            
            return Disposables.create()
        }
    }
    
    static func deleteComment(postId: String, commentId: String) -> Single<Void> {
        return Single<Void>.create { single in
            do {
                print("댓글 삭제 요청 전송")
                let urlRequest = try Router.deleteComment(postId: postId, commentId: commentId).asURLRequest()
                
                AF.request(urlRequest)
                    .validate(statusCode: 200...200)
                    .response { response in
                        switch response.result {
                        case .success:
                            single(.success(()))
                        case .failure(let error):
                            print("댓글 삭제 실패: \(error)")
                            single(.failure(error))
                        }
                    }
            } catch {
                print("댓글 삭제 실패: \(error)")
                single(.failure(error))
            }
            
            return  Disposables.create()
        }
    }
    
    static func deletePost(postId: String) -> Single<Void> {
        return Single<Void>.create { single in
            do {
                print("게시글 삭제 요청 전송")
                let urlRequest = try Router.deletePost(postId: postId).asURLRequest()
                
                AF.request(urlRequest)
                    .validate(statusCode: 200...200)
                    .response { response in
                        switch response.result {
                        case .success:
                            single(.success(()))
                        case .failure(let error):
                            print("게시글 삭제 실패: \(error)")
                            single(.failure(error))
                        }
                    }
            } catch {
                print("게시글 삭제 실패: \(error)")
                single(.failure(error))
            }
            
            return  Disposables.create()
        }
    }
    
    static func refreshToken() -> Single<String> {
        return Single<String>.create { single in
            do {
                print("토큰 리프레시 요청중...")
                let urlRequest = try Router.refresh.asURLRequest()
                
                AF.request(urlRequest)
                    .validate(statusCode: 200..<300)
                    .responseDecodable(of: AccessToken.self) { response in
                        switch response.result {
                        case .success(let accessToken):
                            print("액세스 토큰 갱신 성공")
                            single(.success(accessToken.accessToken))
                        case .failure(let error):
                            print("인증할 수 없는 토큰이거나, 토큰이 만료되어 에러 발생")
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
