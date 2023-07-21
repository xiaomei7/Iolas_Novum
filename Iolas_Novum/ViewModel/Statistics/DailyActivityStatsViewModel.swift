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
    
    func fetchWeeklyStatsData(for date: Date, context: NSManagedObjectContext) -> [(String, TimeInterval, String)] {
        let calendar = Calendar.current
        let startOfWeek = date.startOfWeek(using: calendar)
        let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek)!
        
        let fetchRequest: NSFetchRequest<DailyStats> = DailyStats.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "(date >= %@) AND (date <= %@)", startOfWeek as NSDate, endOfWeek as NSDate)
        
        do {
            let dailyStatsArray = try context.fetch(fetchRequest)
            var weeklyStatsData: [String: (TimeInterval, String)] = [:]
            
            for dailyStats in dailyStatsArray {
                let activitiesStats = dailyStats.activitiesStats?.allObjects as? [ActivityStats] ?? []
                
                for activityStat in activitiesStats {
                    let activityName = activityStat.activity?.name ?? "Unallocated"
                    let accumulateTime = activityStat.accumulateTime
                    let activityColor = activityStat.activity?.color ?? "Gray"
                    
                    if let (currentAccumulateTime, _) = weeklyStatsData[activityName] {
                        weeklyStatsData[activityName] = (currentAccumulateTime + accumulateTime, activityColor)
                    } else {
                        weeklyStatsData[activityName] = (accumulateTime, activityColor)
                    }
                }
            }
            
            let data = weeklyStatsData.map { (activityName, valueColorPair) -> (String, TimeInterval, String) in
                return (activityName, valueColorPair.0, valueColorPair.1)
            }
            
            return data
        } catch {
            print("Failed to fetch WeeklyStats: \(error)")
            return []
        }
    }
    
    func fetchMonthlyStatsData(from startDate: Date, to endDate: Date, context: NSManagedObjectContext) -> [(String, TimeInterval, String)] {
        let fetchRequest: NSFetchRequest<DailyStats> = DailyStats.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "(date >= %@) AND (date <= %@)", startDate as NSDate, endDate as NSDate)
        
        do {
            let monthlyStats = try context.fetch(fetchRequest)
            
            var aggregatedStats: [String: (TimeInterval, String)] = [:]
            
            for dailyStat in monthlyStats {
                let activitiesStats = dailyStat.activitiesStats?.allObjects as? [ActivityStats] ?? []
                
                for activityStat in activitiesStats {
                    let activityName = activityStat.activity?.name ?? "Unallocated"
                    let activityColor = activityStat.activity?.color ?? "Gray"
                    let accumulateTime = activityStat.accumulateTime
                    
                    if let existingStat = aggregatedStats[activityName] {
                        aggregatedStats[activityName] = (existingStat.0 + accumulateTime, activityColor)
                    } else {
                        aggregatedStats[activityName] = (accumulateTime, activityColor)
                    }
                }
            }
            
            let data = aggregatedStats.map { (activityName, stats) -> (String, TimeInterval, String) in
                return (activityName, stats.0, stats.1)
            }
            
            return data
        } catch {
            print("Failed to fetch MonthlyStats: \(error)")
            return []
        }
    }
    
}
