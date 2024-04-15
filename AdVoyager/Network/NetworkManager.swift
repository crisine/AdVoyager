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

struct LoginModel: Decodable {
    let accessToken: String
    let refreshToken: String
}

struct NetworkManager {
    
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
    
}
