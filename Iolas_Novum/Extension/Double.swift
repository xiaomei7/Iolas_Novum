//
//  Double.swift
//  Iolas_Novum
//
//  Created by Iolas on 11/07/2023.
//

import Foundation

extension Double {
    /// Converts a Double into a String representation
    /// ```
    /// Convert 1.2345 to "1.23"
    /// ```
    func mostTwoDigitsAsNumberString() -> String {
        if self == floor(self) {
            return String(format: "%.0f", self)
        } else {
            return String(format: "%.2f", self)
        }
    }
}
