//
//  ShopItemViewModel_Tests.swift
//  Novum_Tests
//
//  Created by Iolas on 21/07/2023.
//

import XCTest
import CoreData
@testable import Iolas_Novum

final class ShopItemViewModel_Tests: XCTestCase {
    
    var viewModel: ShopItemViewModel!
    var context: NSManagedObjectContext!
    
    override func setUp() {
        super.setUp()
        context = TestCoreDataStack().persistentContainer.newBackgroundContext()
        viewModel = ShopItemViewModel()
    }
    
    override func tearDown() {
        super.tearDown()
        viewModel = nil
        context = nil
    }
    
    func test_createShopItem_shouldReturnTrue() {
        // Given
        viewModel.name = "Test Item"
        viewModel.description = "Test Description"
        viewModel.price = 100.0
        
        // When
        let result = viewModel.createShopItem(context: context)
        
        // Then
        XCTAssertTrue(result)
    }
    
    func test_updateShopItem_shouldReturnTrue() {
        // Given
        let item = ShopItem(context: context)
        item.id = UUID()
        item.name = "Test Item"
        item.describe = "Test Description"
        item.price = 100.0
        viewModel.editShopItem = item
        viewModel.name = "Updated Item"
        viewModel.description = "Updated Description"
        viewModel.price = 200.0
        
        // When
        let result = viewModel.updateShopItem(context: context)
        
        // Then
        XCTAssertTrue(result)
        XCTAssertEqual(viewModel.editShopItem?.name, "Updated Item")
        XCTAssertEqual(viewModel.editShopItem?.describe, "Updated Description")
        XCTAssertEqual(viewModel.editShopItem?.price, 200.0)
    }
    
    func test_deleteShopItem_shouldReturnTrue() {
        // Given
        let item = ShopItem(context: context)
        item.id = UUID()
        item.name = "Test Item"
        item.describe = "Test Description"
        item.price = 100.0
        viewModel.editShopItem = item
        
        // When
        let result = viewModel.deleteShopItem(context: context)
        
        // Then
        XCTAssertTrue(result)
    }
    
    func test_resetData_shouldResetData() {
        // Given
        viewModel.name = "Test Item"
        viewModel.description = "Test Description"
        viewModel.price = 100.0
        let item = ShopItem(context: context)
        item.id = UUID()
        item.name = "Test Item"
        item.describe = "Test Description"
        item.price = 100.0
        viewModel.editShopItem = item
        
        // When
        viewModel.resetData()
        
        // Then
        XCTAssertEqual(viewModel.name, "")
        XCTAssertEqual(viewModel.description, "")
        XCTAssertEqual(viewModel.price, 0.0)
        XCTAssertNil(viewModel.editShopItem)
    }
}

