//
//  TravelScheduleModel.swift
//  AdVoyager
//
//  Created by Minho on 4/24/24.
//

import Foundation
import RealmSwift

final class TravelSchedule: Object, Identifiable {
    @Persisted var planId: ObjectId
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var order: Int
    @Persisted var date: Date
    @Persisted var scheduleTitle: String
    @Persisted var scheduleDescription: String?
    @Persisted var latitude: String?
    @Persisted var longitude: String?
    
    convenience init(planId: ObjectId,
                     order: Int,
                     date: Date,
                     scheduleTitle: String,
                     scheduleDescription: String? = nil,
                     latitude: String? = nil,
                     longitude: String? = nil) {
        self.init()
        self.planId = planId
        self.order = order
        self.date = date
        self.scheduleTitle = scheduleTitle
        self.scheduleDescription = scheduleDescription
        self.latitude = latitude
        self.longitude = longitude
    }
}

struct TravelScheduleModel: Codable {
    let planId: ObjectId
    let id: ObjectId
    let order: Int
    let date: Date
    let scheduleTitle: String
    let scheduleDescription: String
    let latitude: String?
    let longitude: String?
}
