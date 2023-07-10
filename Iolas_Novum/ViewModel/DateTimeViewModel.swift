//
//  DateTimeViewModel.swift
//  Iolas_Novum
//
//  Created by Iolas on 10/07/2023.
//

import Foundation

final class DateTimeViewModel: ObservableObject {
    
    @Published var currentWeek: [Date] = []
    @Published var selectedDay: Date = Date()
    @Published var today: Date = Date()
    
    init() {
        fetchCurrentWeek()
    }
    
    func fetchCurrentWeek() {
        let today = Date()
        let calendar = Calendar.current
        
        let week = calendar.dateInterval(of: .weekOfMonth, for: today)
        
        guard let firstWeekDay = week?.start else {
            return
        }
        
        (1...7).forEach { day in
            if let weekday = calendar.date(byAdding: .day, value: day, to: firstWeekDay) {
                currentWeek.append(weekday)
            }
        }
    }
    
    func isToday(date: Date) -> Bool {
        let calendar = Calendar.current
        
        return calendar.isDate(date, inSameDayAs: today)
    }
    
    func isYesterday(date: Date) -> Bool {
        let calendar = Calendar.current
        
        return calendar.isDateInYesterday(date)
    }

    func isTomorrow(date: Date) -> Bool {
        let calendar = Calendar.current
        
        return calendar.isDateInTomorrow(date)
    }
    
    func isSelectedDay(date: Date) -> Bool {
        let calendar = Calendar.current
        
        return calendar.isDate(date, inSameDayAs: selectedDay)
    }
    
    func isCurrentHour(date: Date) -> Bool {
        let calendar = Calendar.current
        
        let hour = calendar.component(.hour, from: date)
        let currentHour = calendar.component(.hour, from: Date())
        
        return hour == currentHour
    }
    
    func extractDate(date: Date, format: String) -> String {
        let formatter = DateFormatter()
        
        formatter.dateFormat = format
        
        return formatter.string(from: date)
    }
}
