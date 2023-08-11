import XCTest
import CoreData
@testable import Iolas_Novum

final class TagViewModel_Tests: XCTestCase {
    
    var viewModel: TagViewModel!
    var context: NSManagedObjectContext!
    
    override func setUp() {
        super.setUp()
        context = TestCoreDataStack().persistentContainer.newBackgroundContext()
        viewModel = TagViewModel()
    }
    
    
    override func tearDown() {
        super.tearDown()
        viewModel = nil
        context = nil
    }
    
    func test_createTag_shouldReturnTrue() {
        // Given
        viewModel.name = "Test Tag"
        viewModel.color = "PresetColor-2"
        
        // When
        let result = viewModel.createTag(context: context)
        
        // Then
        XCTAssertTrue(result)
    }
    
    func test_updateTag_shouldReturnTrue() {
        // Given
        let tag = TagEntity(context: context)
        tag.id = UUID()
        tag.name = "Test Tag"
        tag.color = "PresetColor-2"
        viewModel.editTag = tag
        viewModel.name = "Updated Tag"
        viewModel.color = "PresetColor-3"
        
        // When
        let result = viewModel.updateTag(context: context)
        
        // Then
        XCTAssertTrue(result)
        XCTAssertEqual(viewModel.editTag?.name, "Updated Tag")
        XCTAssertEqual(viewModel.editTag?.color, "PresetColor-3")
    }
    
    func test_deleteTag_shouldReturnTrue() {
        // Given
        let tag = TagEntity(context: context)
        tag.id = UUID()
        tag.name = "Test Tag"
        tag.color = "PresetColor-2"
        viewModel.editTag = tag
        
        // When
        let result = viewModel.deleteTag(context: context)
        
        // Then
        XCTAssertTrue(result)
    }
    
    func test_resetData_shouldResetData() {
        // Given
        viewModel.name = "Test Tag"
        viewModel.color = "PresetColor-2"
        viewModel.editTag = TagEntity(context: context)
        
        // When
        viewModel.resetData()
        
        // Then
        XCTAssertEqual(viewModel.name, "")
        XCTAssertEqual(viewModel.color, "PresetColor-1")
        XCTAssertNil(viewModel.editTag)
    }
    
    func test_doneStatus_shouldReturnCorrectStatus() {
        // Given
        viewModel.name = ""
        
        // When
        let status = viewModel.doneStatus()
        
        // Then
        XCTAssertFalse(status)
        
        // Given
        viewModel.name = "Test Tag"
        
        // When
        let status2 = viewModel.doneStatus()
        
        // Then
        XCTAssertTrue(status2)
    }
}

