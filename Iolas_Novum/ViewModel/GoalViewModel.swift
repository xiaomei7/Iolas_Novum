import Foundation
import CoreData

enum GoalCycle: String, CaseIterable {
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
    case yearly = "Yearly"
    case single = "Single"
}

enum GoalError: Error {
    case failedToUpdatePoints
}

final class GoalViewModel: ObservableObject {
    // MARK: Goal's Properties
    @Published var name: String = ""
    @Published var description: String = ""
    @Published var color: String = "PresetColor-1"
    @Published var cycle: GoalCycle = .daily
    @Published var dueDate: Date? = nil
    @Published var aim: Double = 0.0 {
        didSet {
            let newAimInMinutes = aim / 60.0
            if aimInMinutes != newAimInMinutes {
                aimInMinutes = newAimInMinutes
            }
        }
    }
    @Published var exceedAim: Bool = true
    @Published var reward: Double = 0.0
    @Published var punishment: Double = 0.0
    @Published var linkedActivities: Set<ActivityEntity> = []
    @Published var linkedTags: Set<TagEntity> = []
    @Published var currentValue: Double = 0.0
    
    // MARK: Functional Variables
    @Published var editGoal: GoalEntity?
    private var dailyStatsViewModel = DailyStatsViewModel()
    
    @Published var aimInMinutes: Double = 0.0 {
        didSet {
            let newAim = aimInMinutes * 60.0
            if aim != newAim {
                aim = newAim
            }
        }
    }
    
    // MARK: CRUD
    func createGoal(context: NSManagedObjectContext) -> Bool {
        let goal = GoalEntity(context: context)
        goal.id = UUID()
        goal.name = name
        goal.aim = aim
        goal.color = color
        goal.cycle = cycle.rawValue
        goal.describe = description
        goal.dueDate = dueDate?.endOfDay
        goal.exceedAim = exceedAim
        goal.reward = reward
        goal.punishment = punishment
        goal.activities = NSSet(set: linkedActivities)
        goal.tags = NSSet(set: linkedTags)
        goal.currentValue = currentValue
        goal.created = Date()
        goal.isRewardGiven = false
        goal.lastResetDate = Date()
        
        if let _ = try? context.save() {
            return true
        }
        return false
    }
    
    func updateGoal(context: NSManagedObjectContext) -> Bool {
        if let goal = editGoal {
            goal.name = name
            goal.aim = aim
            goal.color = color
            goal.cycle = cycle.rawValue
            goal.describe = description
            goal.dueDate = dueDate?.endOfDay
            goal.exceedAim = exceedAim
            goal.reward = reward
            goal.punishment = punishment
            goal.activities = NSSet(set: linkedActivities)
            goal.tags = NSSet(set: linkedTags)
            goal.currentValue = currentValue
            
            if let _ = try? context.save() {
                return true
            }
        }
        return false
    }
    
    func deleteGoal(context: NSManagedObjectContext) -> Bool {
        if let goal = editGoal {
            context.delete(goal)
            if let _ = try? context.save() {
                return true
            }
        }
        return false
    }
    
    // MARK: Detail Functions
    func updateCurrentValue(for date: Date, context: NSManagedObjectContext, userModel: UserViewModel) {
        let fetchRequest: NSFetchRequest<GoalEntity> = GoalEntity.fetchRequest()
        
        do {
            let goals = try context.fetch(fetchRequest)
            
            for goal in goals {
                let linkedActivities = goal.activities as? Set<ActivityEntity> ?? []
                let cycle = GoalCycle(rawValue: goal.cycle ?? "") ?? .daily
                
                var statsData: [(String, TimeInterval, String)] = []
                
                switch cycle {
                case .daily:
                    if Calendar.current.isDateInToday(goal.lastResetDate ?? Date()) {
                        goal.lastResetDate = Date()
                        goal.isRewardGiven = false
                    }
                    statsData = dailyStatsViewModel.fetchDailyStatsData(for: date, context: context)
                case .weekly:
                    if Calendar.current.component(.weekOfYear, from: goal.lastResetDate ?? Date()) != Calendar.current.component(.weekOfYear, from: Date()) {
                        goal.lastResetDate = Date()
                        goal.isRewardGiven = false
                    }
                    statsData = dailyStatsViewModel.fetchWeeklyStatsData(for: date, context: context)
                case .monthly:
                    if Calendar.current.component(.month, from: goal.lastResetDate ?? Date()) != Calendar.current.component(.month, from: Date()) {
                        goal.lastResetDate = Date()
                        goal.isRewardGiven = false
                    }
                    let startOfMonth = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: date))!
                    let endOfMonth = Calendar.current.date(byAdding: .month, value: 1, to: startOfMonth)!
                    statsData = dailyStatsViewModel.fetchMonthlyStatsData(from: startOfMonth, to: endOfMonth, context: context)
                case .yearly:
                    if Calendar.current.component(.year, from: goal.lastResetDate ?? Date()) != Calendar.current.component(.year, from: Date()) {
                        goal.lastResetDate = Date()
                        goal.isRewardGiven = false
                    }
                    let startOfYear = Calendar.current.date(from: Calendar.current.dateComponents([.year], from: date))!
                    let endOfYear = Calendar.current.date(byAdding: .year, value: 1, to: startOfYear)!
                    statsData = dailyStatsViewModel.fetchMonthlyStatsData(from: startOfYear, to: endOfYear, context: context)
                case .single:
                    if let dueDate = goal.dueDate, dueDate > date {
                        let creationDate = goal.created ?? Date()
                        statsData = dailyStatsViewModel.fetchMonthlyStatsData(from: creationDate, to: date, context: context)
                    }
                }
                
                let relatedActivitiesStats = statsData.filter { activityName, _, _ in
                    linkedActivities.contains { $0.name == activityName }
                }
                
                goal.currentValue = relatedActivitiesStats.reduce(0.0) { total, activityStat in
                    total + activityStat.1 // Add the accumulateTime of each activity
                }
                
                if goal.currentValue >= goal.aim && !goal.isRewardGiven {
                    userModel.points += goal.reward
                    goal.isRewardGiven = true
                    if !userModel.updatePoints(context: context) {
                        throw GoalError.failedToUpdatePoints
                    }
                }
            }
            
            try context.save()
        } catch {
            print("⛔️ Failed to fetch goals: \(error)")
        }
    }
    
    func resetData() {
        name = ""
        aim = 0.0
        color = "PresetColor-1"
        cycle = .daily
        description = ""
        dueDate = nil
        exceedAim = false
        reward = 0.0
        punishment = 0.0
        linkedActivities = []
        linkedTags = []
        currentValue = 0.0
        
        editGoal = nil
    }
    
    func doneStatus() -> Bool {
        if name == "" {
            return false
        }
        return true
    }
}
