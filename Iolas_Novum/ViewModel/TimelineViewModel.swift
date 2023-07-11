//
//  TimelineViewModel.swift
//  Iolas_Novum
//
//  Created by Iolas on 11/07/2023.
//

import Foundation
import CoreData

final class TimelineEntryViewModel: ObservableObject {
    // MARK: Timeline Entry Properties
    @Published var activity: ActivityEntity?
    @Published var start: Date = Date().addingTimeInterval(-3600)
    @Published var end: Date = Date()
    @Published var description: String = ""
    @Published var points: Double = 0.0

    // MARK: Functional Variables
    @Published var addorEditTimeline: Bool = false
    @Published var editTimeline: TimelineEntry?

    func createTimelineEntry(context: NSManagedObjectContext) -> Bool {
        let timelineEntry = TimelineEntry(context: context)
        timelineEntry.id = UUID()
        timelineEntry.activity = activity
        timelineEntry.start = start
        timelineEntry.end = end
        timelineEntry.describe = description
        timelineEntry.points = points

        if let _ = try? context.save(){
            return true
        }
        
        return false
    }


    func updateTimelineEntry(context: NSManagedObjectContext) -> Bool {
        if let timelineEntry = editTimeline {
            timelineEntry.activity = activity
            timelineEntry.start = start
            timelineEntry.end = end
            timelineEntry.describe = description
            timelineEntry.points = points
            
            if let _ = try? context.save(){
                return true
            }
        }
        
        return false
    }

    // Delete
    func deleteTimelineEntry(context: NSManagedObjectContext) -> Bool {
        if let timelineEntry = editTimeline {
            context.delete(timelineEntry)
            
            if let _ = try? context.save() {
                return true
            }
        }
        return false
    }
    
    func resetData() {
        activity = nil
        start = Date().addingTimeInterval(-3600)
        end = Date()
        description = ""
        points = 0.0
        
        editTimeline = nil
    }
    
    func fetchTimelineEntries(on date: Date, context: NSManagedObjectContext) -> [TimelineEntry] {
        let fetchRequest: NSFetchRequest<TimelineEntry> = TimelineEntry.fetchRequest()
        
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let predicate = NSPredicate(format: "(start >= %@) AND (start < %@) OR (end >= %@) AND (end < %@)", argumentArray: [startOfDay, endOfDay, startOfDay, endOfDay])
        
        fetchRequest.predicate = predicate
        
        do {
            let timelineEntries = try context.fetch(fetchRequest)
            return timelineEntries
        } catch {
            print("⛔️ Failed to fetch timeline entries: \(error)")
            return []
        }
    }

}
