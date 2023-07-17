//
//  DailyActivityStatsViewModel.swift
//  Iolas_Novum
//
//  Created by Iolas on 15/07/2023.
//

import Foundation
import CoreData

final class DailyActivityStatsViewModel: ObservableObject {
    
    func fetchDailyStatsData(for date: Date, context: NSManagedObjectContext) -> [(String, TimeInterval, String)] {
        let fetchRequest: NSFetchRequest<DailyStats> = DailyStats.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "date == %@", date.startOfDay as NSDate)
        
        do {
            let dailyStats = try context.fetch(fetchRequest).first
            let activitiesStats = dailyStats?.activitiesStats?.allObjects as? [ActivityStats] ?? []
            
            let data = activitiesStats.map { activityStat -> (String, TimeInterval, String) in
                let activityName = activityStat.activity?.name ?? "Unallocated"
                let accumulateTime = activityStat.accumulateTime
                let activityColor = activityStat.activity?.color ?? "Gray"
                return (activityName, accumulateTime, activityColor)
            }
            
            return data
        } catch {
            print("Failed to fetch DailyStats: \(error)")
            return []
        }
    }
    
}
