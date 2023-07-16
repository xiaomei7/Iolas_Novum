//
//  DailyActivityStatsViewModel.swift
//  Iolas_Novum
//
//  Created by Iolas on 15/07/2023.
//

import Foundation
import CoreData

final class DailyActivityStatsViewModel: ObservableObject {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
}
