//
//  Influence.swift
//  Iolas_Novum
//
//  Created by Iolas on 10/07/2023.
//

import SwiftUI

enum Influence: String, CaseIterable {
    case positive = "Positive"
    case neutral = "Neutral"
    case offset = "Offset"
    
    var color: Color {
        switch self {
        case .positive:
            return Color("CreamGreen")
        case .neutral:
            return Color("Gray")
        case .offset:
            return Color("DarkOrange")
        }
    }
}
