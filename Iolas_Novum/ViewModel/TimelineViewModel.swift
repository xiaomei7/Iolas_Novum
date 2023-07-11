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
    @Published var activity: ActivityEntity? = nil {
        didSet {
            calculatePoints()
        }
    }
    @Published var start: Date = Date().addingTimeInterval(-600) {
        didSet {
            calculatePoints()
            calculateHourMinuteDifference()
        }
    }
    @Published var end: Date = Date() {
        didSet {
            calculatePoints()
            calculateHourMinuteDifference()
        }
    }
    @Published var description: String = ""
    @Published var points: Double = 0.0
    
    // MARK: For View Only
    @Published var timeDifferenceString: String = ""

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
    
    func restoreEditData(){
        if let editTimeline = editTimeline {
            activity = editTimeline.activity ?? nil
            start = editTimeline.start ?? Date()
            end = editTimeline.end ?? Date()
            description = editTimeline.describe ?? ""
            points = editTimeline.points
        }
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
        let sortDescriptor = NSSortDescriptor(key: "end", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let timelineEntries = try context.fetch(fetchRequest)
            return timelineEntries
        } catch {
            print("⛔️ Failed to fetch timeline entries: \(error)")
            return []
        }
    }
    
    private func calculatePoints() {
        guard let activity = activity else { return }
        
        let hourlyRate = 3000.0 / (30 * 24)
        let currentpPoints = activity.factor * start.hourDifference(to: end)  * hourlyRate
        
        points = currentpPoints
    }
    
    private func calculateHourMinuteDifference() {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: start, to: end)
        
        let hour = components.hour ?? 0
        let minute = components.minute ?? 0
        
        let hourString = hour == 1 ? "hour" : "hours"
        let minuteString = minute == 1 ? "minute" : "minutes"
        
        if hour == 0 {
            timeDifferenceString = "\(minute) \(minuteString)"
        } else if minute == 0 {
            timeDifferenceString = "\(hour) \(hourString)"
        } else {
            timeDifferenceString = "\(hour) \(hourString) \(minute) \(minuteString)"
        }
    }


}
