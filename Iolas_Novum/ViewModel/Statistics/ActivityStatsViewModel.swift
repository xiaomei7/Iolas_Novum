//
//  ActivityStatsViewModel.swift
//  Iolas_Novum
//
//  Created by Iolas on 15/07/2023.
//

import Foundation
import CoreData

class ActivityStatsViewModel: ObservableObject {
    
    @Published var activity: ActivityEntity? = nil
    
    func createOrUpdateActivityStats(context: NSManagedObjectContext, oldDurations: [Date: TimeInterval] = [:], newDurations: [Date: TimeInterval]) -> Bool {
        print("inside createOrUpdateActivityStats.")
        
        do {
            // Get the date range spanned by the old and new timelines
            let startDate = min(oldDurations.keys.min() ?? Date(), newDurations.keys.min() ?? Date())
            let endDate = max(oldDurations.keys.max() ?? Date(), newDurations.keys.max() ?? Date())
            
            // Fetch all ActivityStats entities for the activity and date range
            let fetchRequest: NSFetchRequest<ActivityStats> = ActivityStats.fetchRequest()
            if let activity = activity {
                fetchRequest.predicate = NSPredicate(format: "activity == %@ AND date >= %@ AND date <= %@", activity, startDate as NSDate, endDate as NSDate)
            } else {
                fetchRequest.predicate = NSPredicate(format: "activity == %@ AND date >= %@ AND date <= %@", NSNull(), startDate as NSDate, endDate as NSDate)
            }
            let results = try context.fetch(fetchRequest)
            
            // Update the accumulateTime for each ActivityStats entity
            for activityStats in results {
                let oldDuration = oldDurations[activityStats.date!] ?? 0
                let newDuration = newDurations[activityStats.date!] ?? 0
                
                activityStats.accumulateTime += newDuration - oldDuration
            }
            
            // Create new ActivityStats entities for any dates in the new timeline that did not have an existing entity
            for (date, duration) in newDurations {
                if !results.contains(where: { $0.date! == date }) {
                    let activityStats = ActivityStats(context: context)
                    activityStats.id = UUID()
                    activityStats.activity = activity
                    activityStats.date = date
                    activityStats.accumulateTime = duration
                    
                    // Fetch or create the DailyStats entity for the date
                    let dailyStatsFetchRequest: NSFetchRequest<DailyStats> = DailyStats.fetchRequest()
                    dailyStatsFetchRequest.predicate = NSPredicate(format: "date == %@", date.startOfDay as NSDate)
                    let dailyStats = try context.fetch(dailyStatsFetchRequest).first ?? DailyStats(context: context)
                    dailyStats.id = UUID()
                    dailyStats.date = date.startOfDay
                    
                    // Add the new ActivityStats entity to the DailyStats entity
                    dailyStats.addToActivitiesStats(activityStats)
                }
            }
        } catch {
            print("⛔️ Failed to fetch ActivityStats: \(error)")
            return false
        }
        
        if let _ = try? context.save() {
            return true
        }
        
        return false
    }
}
