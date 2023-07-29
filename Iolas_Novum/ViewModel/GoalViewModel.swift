//
//  GoalViewModel.swift
//  Iolas_Novum
//
//  Created by Iolas on 25/07/2023.
//

import Foundation
import CoreData

enum GoalCycle: String, CaseIterable {
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
    case yearly = "Yearly"
    case single = "Single"
}

final class GoalViewModel: ObservableObject {
    // MARK: Goal's Properties
    @Published var name: String = ""
    @Published var description: String = ""
    @Published var color: String = "PresetColor-1"
    @Published var cycle: GoalCycle = .daily
    @Published var dueDate: Date? = nil
    @Published var aim: Double = 0.0
    @Published var exceedAim: Bool = true
    @Published var reward: Double = 0.0
    @Published var punishment: Double = 0.0
    @Published var linkedActivities: Set<ActivityEntity> = []
    @Published var linkedTags: Set<TagEntity> = []
    @Published var currentValue: Double = 0.0
    
    // MARK: Functional Variables
    @Published var editGoal: GoalEntity?
    
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
