//
//  TravelPlanModel.swift
//  AdVoyager
//
//  Created by Minho on 4/28/24.
//

import RealmSwift
import Foundation

final class TravelPlan: Object, Identifiable {
    
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
    
    func convertToCodableModel() -> TravelPlanModel {
        return TravelPlanModel(id: "", planTitle: self.planTitle, firstDate: self.firstDate, lastDate: self.lastDate)
    }
}

struct TravelPlanModel: Codable {
    var id: String
    var planTitle: String
    var firstDate: Date
    var lastDate: Date
}
