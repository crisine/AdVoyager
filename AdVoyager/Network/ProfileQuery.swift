//
//  ProfileQuery.swift
//  AdVoyager
//
//  Created by Minho on 4/19/24.
//

import Foundation

struct EditProfileQuery: Encodable {
    let nick: String
    let phoneNum: String
    let birthDay: String
    let profile: Data
}
