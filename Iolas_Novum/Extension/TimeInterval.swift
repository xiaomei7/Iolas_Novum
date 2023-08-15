import Foundation

extension TimeInterval {
    func asMinutes() -> Double {
        return self / 60
    }
    
    func asHours() -> Double {
        return self / 3600
    }
    
    func asDays() -> Double {
        return self / 86400
    }
}
