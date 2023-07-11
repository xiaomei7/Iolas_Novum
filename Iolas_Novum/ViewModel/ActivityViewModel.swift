//
//  ActivityViewModel.swift
//  Iolas_Novum
//
//  Created by Iolas on 10/07/2023.
//

import Foundation
import CoreData

final class ActivityViewModel: ObservableObject {
    // MARK: Activity's Properties
    @Published var name: String = ""
    @Published var description: String = ""
    @Published var influence: Influence = .neutral
    @Published var color: String = "PresetColor-1"
    @Published var isArchived: Bool = false
    @Published var factor: Double = 1.0
    @Published var selectedTags: Set<TagEntity> = []
    
    // MARK: Functional Variables
    @Published var addorEditActivity: Bool = false
    @Published var editActivity: ActivityEntity?
    
    // MARK: CRUD
    func createActivity(context: NSManagedObjectContext) -> Bool{
        let activity = ActivityEntity(context: context)
        
        activity.id = UUID()
        activity.name = name
        activity.describe = description
        activity.influence = influence.rawValue
        activity.color = color
        activity.isArchived = isArchived
        activity.factor = factor
        activity.accumulateTime = 0.0
        activity.created = Date()
        activity.tags = NSSet(set: selectedTags)

        if let _ = try? context.save(){
            return true
        }
        return false
    }
    
    func updateActivity(context: NSManagedObjectContext) -> Bool{
        if let activity = editActivity {
            activity.name = name
            activity.describe = description
            activity.influence = influence.rawValue
            activity.color = color
            activity.isArchived = isArchived
            activity.factor = factor
            activity.tags = NSSet(set: selectedTags)
            
            if let _ = try? context.save(){
                return true
            }
        }
        
        
        return false
    }
    
    func deleteActivity(context: NSManagedObjectContext) -> Bool{
        if let activity = editActivity {
            context.delete(activity)
            
            if let _ = try? context.save(){
                return true
            }
        }
        return false
    }
    
    // MARK: Restore and Reset
    func restoreEditData(){
        if let editActivity = editActivity {
            name = editActivity.name ?? ""
            description = editActivity.describe ?? ""
            influence = Influence(rawValue: editActivity.influence ?? "Neutral")!
            color = editActivity.color ?? "PresetColor-1"
            factor = editActivity.factor
            selectedTags = editActivity.tags as? Set<TagEntity> ?? []
        }
    }
    
    func resetData(){
        name = ""
        description = ""
        influence = .neutral
        color = "PresetColor-1"
        isArchived = false
        factor = 1.0
        selectedTags = []
        
        editActivity = nil
    }
    
    func doneStatus() -> Bool {
        if name == "" {
            return false
        }
        return true
    }
}
