//
//  Date.swift
//  Iolas_Novum
//
//  Created by Iolas on 10/07/2023.
//

import Foundation

extension Date {
    func formatToString(format: String) -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = format
        
        return formatter.string(from: self)
    }
}
