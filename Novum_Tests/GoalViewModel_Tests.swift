//
//  GoalViewModel_Tests.swift
//  Novum_Tests
//
//  Created by Iolas on 31/07/2023.
//

import XCTest
import CoreData
@testable import Iolas_Novum

final class GoalViewModel_Tests: XCTestCase {
    
    var viewModel: GoalViewModel!
    var context: NSManagedObjectContext!
    
    override func setUp() {
        super.setUp()
        context = TestCoreDataStack().persistentContainer.newBackgroundContext()
        viewModel = GoalViewModel()
    }
    
    
    override func tearDown() {
        super.tearDown()
        viewModel = nil
        context = nil
    }
    
    func test_createGoal_shouldReturnTrue() {
        // Given
        viewModel.name = "Test Goal"
        viewModel.description = "Test Description"
        viewModel.color = "PresetColor-1"
        viewModel.cycle = .daily
        viewModel.dueDate = Date().addingTimeInterval(3600)
        viewModel.aim = 100.0
        viewModel.exceedAim = true
        viewModel.reward = 10.0
        viewModel.punishment = 5.0
        viewModel.linkedActivities = []
        viewModel.linkedTags = []
        viewModel.currentValue = 0.0
        
        // When
        let result = viewModel.createGoal(context: context)
        
        // Then
        XCTAssertTrue(result)
    }
    
    func test_updateGoal_shouldReturnTrue() {
        // Given
        let goal = GoalEntity(context: context)
        goal.id = UUID()
        goal.name = "Test Goal"
        goal.aim = 100.0
        goal.color = "PresetColor-1"
        goal.cycle = GoalCycle.daily.rawValue
        goal.describe = "Test Description"
        goal.dueDate = Date().addingTimeInterval(3600)
        goal.exceedAim = true
        goal.reward = 10.0
        goal.punishment = 5.0
        goal.activities = NSSet()
        goal.tags = NSSet()
        goal.currentValue = 0.0
        goal.created = Date()
        
        viewModel.editGoal = goal
        viewModel.name = "Updated Goal"
        viewModel.description = "Updated Description"
        viewModel.color = "PresetColor-2"
        viewModel.cycle = .weekly
        viewModel.dueDate = Date().addingTimeInterval(7200)
        viewModel.aim = 200.0
        viewModel.exceedAim = false
        viewModel.reward = 20.0
        viewModel.punishment = 10.0
        viewModel.linkedActivities = []
        viewModel.linkedTags = []
        viewModel.currentValue = 50.0
        
        // When
        let result = viewModel.updateGoal(context: context)
        
        // Then
        XCTAssertTrue(result)
    }
    
    func test_deleteGoal_shouldReturnTrue() {
        // Given
        let goal = GoalEntity(context: context)
        goal.id = UUID()
        goal.name = "Test Goal"
        goal.aim = 100.0
        goal.color = "PresetColor-1"
        goal.cycle = GoalCycle.daily.rawValue
        goal.describe = "Test Description"
        goal.dueDate = Date().addingTimeInterval(3600)
        goal.exceedAim = true
        goal.reward = 10.0
        goal.punishment = 5.0
        goal.activities = NSSet()
        goal.tags = NSSet()
        goal.currentValue = 0.0
        goal.created = Date()
        
        viewModel.editGoal = goal
        
        // When
        let result = viewModel.deleteGoal(context: context)
        
        // Then
        XCTAssertTrue(result)
    }
    
    func test_resetData_shouldResetData() {
        // Given
        viewModel.name = "Test Goal"
        viewModel.description = "Test Description"
        viewModel.color = "PresetColor-1"
        viewModel.cycle = .daily
        viewModel.dueDate = Date().addingTimeInterval(3600)
        viewModel.aim = 100.0
        viewModel.exceedAim = true
        viewModel.reward = 10.0
        viewModel.punishment = 5.0
        viewModel.linkedActivities = []
        viewModel.linkedTags = []
        viewModel.currentValue = 0.0
        
        // When
        viewModel.resetData()
        
        // Then
        XCTAssertEqual(viewModel.name, "")
        XCTAssertEqual(viewModel.description, "")
        XCTAssertEqual(viewModel.color, "PresetColor-1")
        XCTAssertEqual(viewModel.cycle, .daily)
        XCTAssertNil(viewModel.dueDate)
        XCTAssertEqual(viewModel.aim, 0.0)
        XCTAssertFalse(viewModel.exceedAim)
        XCTAssertEqual(viewModel.reward, 0.0)
        XCTAssertEqual(viewModel.punishment, 0.0)
        XCTAssertTrue(viewModel.linkedActivities.isEmpty)
        XCTAssertTrue(viewModel.linkedTags.isEmpty)
        XCTAssertEqual(viewModel.currentValue, 0.0)
    }
}

