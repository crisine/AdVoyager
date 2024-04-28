//
//  TravelPlanModel.swift
//  AdVoyager
//
//  Created by Minho on 4/28/24.
//

import RealmSwift
import Foundation

final class TravelPlanModel: Object, Identifiable {
    
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var planTitle: String
    @Persisted var startDate: Date
    @Persisted var lastDate: Date
    
    convenience init(planTitle: String, startDate: Date, lastDate: Date) {
        self.init()
        self.planTitle = planTitle
        self.startDate = startDate
        self.lastDate = lastDate
    }
}
