//
//  TodoViewModel_Tests.swift
//  Novum_Tests
//
//  Created by Iolas on 24/07/2023.
//

import XCTest
import CoreData
@testable import Iolas_Novum

final class TodoViewModel_Tests: XCTestCase {
    
    var viewModel: TodoViewModel!
    var context: NSManagedObjectContext!
    
    override func setUp() {
        super.setUp()
        context = TestCoreDataStack().persistentContainer.newBackgroundContext()
        viewModel = TodoViewModel()
    }
    
    override func tearDown() {
        super.tearDown()
        viewModel = nil
        context = nil
    }
    
    func createActivityEntity() -> ActivityEntity {
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
        return activity
    }
    
    func test_createTodo_shouldReturnTrue() {
        // Given
        viewModel.name = "Test Todo"
        viewModel.color = "PresetColor-1"
        viewModel.frequency = ["Monday", "Tuesday"]
        viewModel.reward = 10.0
        viewModel.linkedActivity = createActivityEntity()
        viewModel.completionDates = []
        
        // When
        let result = viewModel.createTodo(context: context)
        
        // Then
        XCTAssertTrue(result)
    }
    
    func test_updateTodo_shouldReturnTrue() {
        // Given
        let todo = TodoEntity(context: context)
        todo.id = UUID()
        todo.name = "Test Todo"
        todo.color = "PresetColor-1"
        todo.reward = 10.0
        todo.frequency = ["Monday", "Tuesday"]
        todo.activity = createActivityEntity()
        todo.created = Date()
        
        viewModel.editTodo = todo
        viewModel.name = "Updated Todo"
        viewModel.color = "PresetColor-2"
        viewModel.frequency = ["Wednesday", "Thursday"]
        viewModel.reward = 20.0
        viewModel.linkedActivity = createActivityEntity()
        viewModel.completionDates = []
        
        // When
        let result = viewModel.updateTodo(context: context)
        
        // Then
        XCTAssertTrue(result)
    }
    
    func test_deleteTodo_shouldReturnTrue() {
        // Given
        let todo = TodoEntity(context: context)
        todo.id = UUID()
        todo.name = "Test Todo"
        todo.color = "PresetColor-1"
        todo.reward = 10.0
        todo.frequency = ["Monday", "Tuesday"]
        todo.activity = nil
        todo.created = Date()
        
        viewModel.editTodo = todo
        
        // When
        let result = viewModel.deleteTodo(context: context)
        
        // Then
        XCTAssertTrue(result)
    }
    
    func test_fetchAndFilterTodos_shouldReturnData() {
        // Given
        let todo = TodoEntity(context: context)
        todo.id = UUID()
        todo.name = "Test Todo"
        todo.color = "PresetColor-1"
        todo.reward = 10.0
        todo.frequency = ["Monday", "Tuesday"]
        todo.activity = createActivityEntity()
        todo.created = Date()
        
        // When
        viewModel.fetchAndFilterTodos(context: context)
        
        // Then
        XCTAssertFalse(viewModel.todos.isEmpty)
    }
    
    func test_updateTodoCompletionStatus_shouldReturnTrue() {
        // Given
        let todo = TodoEntity(context: context)
        todo.id = UUID()
        todo.name = "Test Todo"
        todo.color = "PresetColor-1"
        todo.reward = 10.0
        todo.frequency = ["Monday", "Tuesday"]
        todo.activity = createActivityEntity()
        todo.created = Date()
        
        // When
        let result = viewModel.updateTodoCompletionStatus(todo: todo, isComplete: true, context: context)
        
        // Then
        XCTAssertTrue(result)
    }
}

