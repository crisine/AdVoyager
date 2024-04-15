//
//  SignUpQuery.swift
//  AdVoyager
//
//  Created by Minho on 4/16/24.
//

import Foundation

struct SignUpQuery: Encodable {
    let email: String
    let password: String
    let nick: String
    let phoneNum: String
    let birthDay: String
}
