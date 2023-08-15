import XCTest
import CoreData
@testable import Iolas_Novum

class ActivityViewModel_Tests: XCTestCase {
    
    var viewModel: ActivityViewModel!
    var context: NSManagedObjectContext!
    
    override func setUp() {
        super.setUp()
        context = TestCoreDataStack().persistentContainer.newBackgroundContext()
        viewModel = ActivityViewModel()
    }
    
    override func tearDown() {
        super.tearDown()
        viewModel = nil
        context = nil
    }
    
    func test_createActivity_shouldReturnTrue() {
        // Given
        viewModel.name = "Test Activity"
        viewModel.description = "Test Description"
        viewModel.influence = .neutral
        viewModel.color = "PresetColor-1"
        viewModel.isArchived = false
        viewModel.factor = 1.0
        viewModel.selectedTags = []
        
        // When
        let result = viewModel.createActivity(context: context)
        
        // Then
        XCTAssertTrue(result)
    }
    
    func test_updateActivity_shouldReturnTrue() {
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
        
        viewModel.editActivity = activity
        viewModel.name = "Updated Activity"
        viewModel.description = "Updated Description"
        viewModel.influence = .positive
        viewModel.color = "PresetColor-2"
        viewModel.isArchived = true
        viewModel.factor = 2.0
        viewModel.selectedTags = []
        
        // When
        let result = viewModel.updateActivity(context: context)
        
        // Then
        XCTAssertTrue(result)
        XCTAssertEqual(viewModel.editActivity?.name, "Updated Activity")
        XCTAssertEqual(viewModel.editActivity?.describe, "Updated Description")
        XCTAssertEqual(viewModel.editActivity?.influence, Influence.positive.rawValue)
        XCTAssertEqual(viewModel.editActivity?.color, "PresetColor-2")
        XCTAssertEqual(viewModel.editActivity?.isArchived, true)
        XCTAssertEqual(viewModel.editActivity?.factor, 2.0)
    }
    
    func test_deleteActivity_shouldReturnTrue() {
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
        viewModel.editActivity = activity
        
        // When
        let result = viewModel.deleteActivity(context: context)
        
        // Then
        XCTAssertTrue(result)
    }
    
    func test_resetData_shouldResetData() {
        // Given
        viewModel.name = "Test Activity"
        viewModel.description = "Test Description"
        viewModel.influence = .neutral
        viewModel.color = "PresetColor-1"
        viewModel.isArchived = false
        viewModel.factor = 1.0
        viewModel.selectedTags = []
        
        let activity = ActivityEntity(context: context)
        activity.id = UUID()
        activity.name = "Test Activity"
        activity.describe = "Test Description"
        activity.influence = Influence.neutral.rawValue
        activity.color = "PresetColor-1"
        activity.isArchived = false
        activity.factor = 1.0
        activity.tags = NSSet()
        viewModel.editActivity = activity
        
        // When
        viewModel.resetData()
        
        // Then
        XCTAssertEqual(viewModel.name, "")
        XCTAssertEqual(viewModel.description, "")
        XCTAssertEqual(viewModel.influence, .neutral)
        XCTAssertEqual(viewModel.color, "PresetColor-1")
        XCTAssertEqual(viewModel.isArchived, false)
        XCTAssertEqual(viewModel.factor, 1.0)
        XCTAssertTrue(viewModel.selectedTags.isEmpty)
        XCTAssertNil(viewModel.editActivity)
    }
}
