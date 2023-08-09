//
//  Date.swift
//  Iolas_Novum
//
//  Created by Iolas on 10/07/2023.
//

import Foundation

extension Date {
    struct WeekDay: Identifiable {
        var id: UUID = .init()
        var date: Date
    }
    
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }
    
    func formatToString(_ format: String) -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = format
        
        return formatter.string(from: self)
    }
    
    var isToday: Bool {
        return Calendar.current.isDateInToday(self)
    }
    
    func isSameDay(as otherDate: Date) -> Bool {
        return Calendar.current.isDate(self, inSameDayAs: otherDate)
    }
    
    var isSameHour: Bool {
        return Calendar.current.compare(self, to: .init(), toGranularity: .hour) == .orderedSame
    }
    
    var isPast: Bool {
        return Calendar.current.compare(self, to: .init(), toGranularity: .hour) == .orderedAscending
    }
    
    func startOfWeek(using calendar: Calendar = .current) -> Date {
        let weekday = calendar.component(.weekday, from: self)
        let startOfWeek = calendar.date(byAdding: .day, value: 2 - weekday, to: self.startOfDay)!
        return startOfWeek
    }
    
    func fetchWeek(_ date: Date = .init()) -> [WeekDay] {
        let calendar = Calendar.current
        let startOfDate = calendar.startOfDay(for: date)
        
        var week: [WeekDay] = []
        let weekForDate = calendar.dateInterval(of: .weekOfMonth, for: startOfDate)
        guard let starOfWeek = weekForDate?.start else {
            return []
        }
        
        (0..<7).forEach { index in
            if let weekDay = calendar.date(byAdding: .day, value: index, to: starOfWeek) {
                week.append(.init(date: weekDay))
            }
        }
        
        return week
    }
    
    func createNextWeek() -> [WeekDay] {
        let calendar = Calendar.current
        let startOfLastDate = calendar.startOfDay(for: self)
        guard let nextDate = calendar.date(byAdding: .day, value: 1, to: startOfLastDate) else {
            return []
        }
        
        return fetchWeek(nextDate)
    }
    
    func createPreviousWeek() -> [WeekDay] {
        let calendar = Calendar.current
        let startOfFirstDate = calendar.startOfDay(for: self)
        guard let previousDate = calendar.date(byAdding: .day, value: -1, to: startOfFirstDate) else {
            return []
        }
        
        return fetchWeek(previousDate)
    }
    
    func isInWeekday(_ frequency: [Int]) -> Bool {
        let weekday = Calendar.current.component(.weekday, from: self)
        return frequency.contains(weekday)
    }
    
    func startOfMonth() -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components)!
    }
    
    func endOfMonth() -> Date {
        let calendar = Calendar.current
        let components = DateComponents(month: 1, second: -1)
        return calendar.date(byAdding: components, to: self.startOfMonth())!
    }
    
    func formattedHourMinuteDifference(to endDate: Date) -> String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: self, to: endDate)
        
        let hour = components.hour ?? 0
        let minute = components.minute ?? 0
        
        let hourString = hour == 1 ? "hour" : "hours"
        let minuteString = minute == 1 ? "minute" : "minutes"
        
        if hour == 0 {
            return "\(minute) \(minuteString)"
        } else if minute == 0 {
            return "\(hour) \(hourString)"
        } else {
            return "\(hour) \(hourString) \(minute) \(minuteString)"
        }
        
    }
    
    func hourDifference(to endDate: Date) -> Double {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: self, to: endDate)
        
        let hour = Double(components.hour ?? 0)
        let minute = Double(components.minute ?? 0)
        
        let totalHours = hour + (minute / 60.0)
        
        return totalHours
    }
    
    static func createDate(_ day: Int, _ month: Int, _ year: Int) -> Date {
        var components = DateComponents()
        components.day = day
        components.month = month
        components.year = year
        
        let calendar = Calendar.current
        let date = calendar.date(from: components) ?? .init()
        
        return date
    }
    
    static func calculateDurations(date1: Date, date2: Date) -> [Date: TimeInterval] {
        var durations = [Date: TimeInterval]()
        
        let calendar = Calendar.current
        let startOfDay1 = calendar.startOfDay(for: date1)
        let startOfDay2 = calendar.startOfDay(for: date2)
        
        if startOfDay1 == startOfDay2 {
            // The two dates are on the same day.
            let duration = date2.timeIntervalSince(date1)
            durations[startOfDay1] = duration
        } else {
            // The two dates are on different days.
            if let endOfDay1 = calendar.date(byAdding: .day, value: 1, to: startOfDay1) {
                let duration1 = endOfDay1.timeIntervalSince(date1)
                durations[startOfDay1] = duration1
            }
            
            if let startOfNextDay2 = calendar.date(byAdding: .day, value: -1, to: startOfDay2) {
                let duration2 = date2.timeIntervalSince(startOfNextDay2)
                durations[startOfDay2] = duration2
            }
        }
        
        return durations
    }
    
    static func calculateDurationsForMultipleDay(date1: Date, date2: Date) -> [Date: TimeInterval] {
        var durations = [Date: TimeInterval]()
        
        let calendar = Calendar.current
        var currentDate = calendar.startOfDay(for: date1)
        let endDate = calendar.startOfDay(for: date2)
        
        while currentDate <= endDate {
            if let endOfDay = calendar.date(byAdding: .day, value: 1, to: currentDate) {
                if currentDate == calendar.startOfDay(for: date1) {
                    // The first day.
                    let duration = endOfDay.timeIntervalSince(date1)
                    durations[currentDate] = duration
                } else if currentDate == endDate {
                    // The last day.
                    let duration = date2.timeIntervalSince(currentDate)
                    durations[currentDate] = duration
                } else {
                    // Any day in between.
                    let duration = endOfDay.timeIntervalSince(currentDate)
                    durations[currentDate] = duration
                }
                
                currentDate = endOfDay
            }
        }
        
        return durations
    }
    
}
