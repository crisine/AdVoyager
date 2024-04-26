//
//  TravelPlanModel.swift
//  AdVoyager
//
//  Created by Minho on 4/24/24.
//

import Foundation

// MARK: 각 일정 데이터마다 post_id를 들고 있는 것이 맞을까? 부모 오브젝트가 있는게 좋지 않을까..?
struct TravelPlanModel: Codable {
    let post_id: String
    let id: UUID
    let order: Int
    let date: Date
    let placeTitle: String
    let description: String
    let latitude: String?
    let longitude: String?
}
