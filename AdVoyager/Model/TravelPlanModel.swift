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
    @Persisted var firstDate: Date
    @Persisted var lastDate: Date
    
    convenience init(planTitle: String, firstDate: Date, lastDate: Date) {
        self.init()
        self.planTitle = planTitle
        self.firstDate = firstDate
        self.lastDate = lastDate
    }
}
