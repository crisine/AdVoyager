//
//  Repository.swift
//  AdVoyager
//
//  Created by Minho on 4/27/24.
//

import Foundation
import RealmSwift

final class Repository {
    
    private let realm = try! Realm()
    
    func fetchTravelPlan() -> Results<TravelPlanModel> {
        print(realm.configuration.fileURL)
        return realm.objects(TravelPlanModel.self)
    }
    
    func fetchSchedule(planId: ObjectId) -> Results<TravelSchedule> {
        return realm.objects(TravelSchedule.self).where { schedule in
            schedule.planId == planId
        }
    }
    
    func addTravelPlan(_ travelPlan: TravelPlanModel) {
        do {
            try realm.write {
                realm.add(travelPlan)
            }
        } catch {
            print(error)
        }
    }

    func addSchedule(_ schedule: TravelSchedule) {
        do {
            try realm.write {
                realm.add(schedule)
            }
        } catch {
            print(error)
        }
    }
    
    func updateSchedule(schedule: TravelSchedule, modifiedSchedule: TravelSchedule) {
        do {
            try realm.write {
                schedule.order = modifiedSchedule.order
                schedule.date = modifiedSchedule.date
                schedule.scheduleTitle = modifiedSchedule.scheduleTitle
                schedule.scheduleDescription = modifiedSchedule.scheduleDescription
                schedule.latitude = modifiedSchedule.latitude
                schedule.longitude = modifiedSchedule.longitude
                
                realm.add(schedule, update: .modified)
            }
        } catch {
            print(error)
        }
    }
    
    func deleteSchedule(_ schedule: TravelSchedule) {
        do {
            try realm.write {
                realm.delete(schedule)
            }
        } catch {
            print(error)
        }
    }
}
