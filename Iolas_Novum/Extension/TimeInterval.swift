//
//  TimeInterval.swift
//  Iolas_Novum
//
//  Created by Iolas on 16/07/2023.
//

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
