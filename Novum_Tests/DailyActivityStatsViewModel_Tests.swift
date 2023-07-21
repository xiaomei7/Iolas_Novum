//
//  DailyActivityStatsViewModel_Tests.swift
//  Novum_Tests
//
//  Created by Iolas on 21/07/2023.
//

import XCTest
import CoreData
@testable import Iolas_Novum

final class DailyActivityStatsViewModel_Tests: XCTestCase {
    
    var viewModel: DailyActivityStatsViewModel!
    var context: NSManagedObjectContext!
    
    override func setUp() {
        super.setUp()
        context = TestCoreDataStack().persistentContainer.newBackgroundContext()
        viewModel = DailyActivityStatsViewModel()
    }
    
    override func tearDown() {
        super.tearDown()
        viewModel = nil
        context = nil
    }
    
    func test_fetchDailyStatsData_shouldReturnData() {
        // Given
        let date = Date()
        
        // When
        let result = viewModel.fetchDailyStatsData(for: date, context: context)
        
        // Then
        XCTAssertNotNil(result)
    }
    
    func test_fetchWeeklyStatsData_shouldReturnData() {
        // Given
        let date = Date()
        
        // When
        let result = viewModel.fetchWeeklyStatsData(for: date, context: context)
        
        // Then
        XCTAssertNotNil(result)
    }
    
    func test_fetchMonthlyStatsData_shouldReturnData() {
        // Given
        let startDate = Date()
        let endDate = Calendar.current.date(byAdding: .month, value: 1, to: startDate)!
        
        // When
        let result = viewModel.fetchMonthlyStatsData(from: startDate, to: endDate, context: context)
        
        // Then
        XCTAssertNotNil(result)
    }
}

