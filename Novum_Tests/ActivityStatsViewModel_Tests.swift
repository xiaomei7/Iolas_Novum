//
//  ActivityStatsViewModel_Tests.swift
//  Novum_Tests
//
//  Created by Iolas on 21/07/2023.
//

import XCTest
import CoreData
@testable import Iolas_Novum

class ActivityStatsViewModel_Tests: XCTestCase {
    
    var viewModel: ActivityStatsViewModel!
    var context: NSManagedObjectContext!
    
    override func setUp() {
        super.setUp()
        context = TestCoreDataStack().persistentContainer.newBackgroundContext()
        viewModel = ActivityStatsViewModel()
    }
    
    
    override func tearDown() {
        super.tearDown()
        viewModel = nil
        context = nil
    }
    
    func test_createOrUpdateActivityStats_shouldReturnTrue() {
        // Given
        let activity = ActivityEntity(context: context)
        activity.id = UUID()
        activity.name = "Test Activity"
        activity.describe = "Test Description"
        activity.influence = Influence.neutral.rawValue
        activity.color = "PresetColor-1"
        activity.isArchived = false
        activity.factor = 1.0
        activity.tags = NSSet()
        activity.created = Date()
        
        viewModel.activity = activity
        
        let oldDurations: [Date: TimeInterval] = [:]
        let newDurations: [Date: TimeInterval] = [Date(): 3600]
        
        // When
        let result = viewModel.createOrUpdateActivityStats(context: context, oldDurations: oldDurations, newDurations: newDurations)
        
        // Then
        XCTAssertTrue(result)
    }
}

