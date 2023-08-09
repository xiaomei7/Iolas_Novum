import Foundation
import CoreData

class ActivityStatsViewModel: ObservableObject {
    
    @Published var activity: ActivityEntity? = nil
    
    func createOrUpdateActivityStats(context: NSManagedObjectContext, oldDurations: [Date: TimeInterval] = [:], newDurations: [Date: TimeInterval]) -> Bool {        
        do {
            let startDate = min(oldDurations.keys.min() ?? Date(), newDurations.keys.min() ?? Date())
            let endDate = max(oldDurations.keys.max() ?? Date(), newDurations.keys.max() ?? Date())
            
            let fetchRequest: NSFetchRequest<ActivityStats> = ActivityStats.fetchRequest()
            if let activity = activity {
                fetchRequest.predicate = NSPredicate(format: "activity == %@ AND date >= %@ AND date <= %@", activity, startDate as NSDate, endDate as NSDate)
            } else {
                fetchRequest.predicate = NSPredicate(format: "activity == %@ AND date >= %@ AND date <= %@", NSNull(), startDate as NSDate, endDate as NSDate)
            }
            let results = try context.fetch(fetchRequest)
            
            for activityStats in results {
                let oldDuration = oldDurations[activityStats.date!] ?? 0
                let newDuration = newDurations[activityStats.date!] ?? 0
                
                activityStats.accumulateTime += newDuration - oldDuration
            }
            
            for (date, duration) in newDurations {
                if !results.contains(where: { $0.date! == date }) {
                    let activityStats = ActivityStats(context: context)
                    activityStats.id = UUID()
                    activityStats.activity = activity
                    activityStats.date = date
                    activityStats.accumulateTime = duration
                    
                    let dailyStatsFetchRequest: NSFetchRequest<DailyStats> = DailyStats.fetchRequest()
                    dailyStatsFetchRequest.predicate = NSPredicate(format: "date == %@", date.startOfDay as NSDate)
                    let dailyStats = try context.fetch(dailyStatsFetchRequest).first ?? DailyStats(context: context)
                    dailyStats.id = UUID()
                    dailyStats.date = date.startOfDay
                    
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
