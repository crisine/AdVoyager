//
//  TravelPlanModel.swift
//  AdVoyager
//
//  Created by Minho on 4/24/24.
//

import Foundation

struct TravelPlanModel: Codable {
    let post_id: String
    let id: UUID
    let order: Int
    let date: Date
    let placeTitle: String
    let description: String
    let latitude: String
    let longitude: String
}
