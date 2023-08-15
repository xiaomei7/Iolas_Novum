import XCTest
import CoreData
@testable import Iolas_Novum

final class TimelineEntryViewModel_Tests: XCTestCase {
    
    var viewModel: TimelineEntryViewModel!
    var context: NSManagedObjectContext!
    
    override func setUp() {
        super.setUp()
        context = TestCoreDataStack().persistentContainer.newBackgroundContext()
        viewModel = TimelineEntryViewModel()
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
    
    func test_createTimelineEntry_shouldReturnTrue() {
        // Given
        viewModel.activity = createActivityEntity()
        viewModel.start = Date().addingTimeInterval(-3600)
        viewModel.end = Date()
        viewModel.description = "Test Description"
        viewModel.points = 100.0
        
        // When
        let result = viewModel.createTimelineEntry(context: context)
        
        // Then
        XCTAssertTrue(result)
    }
    
    func test_updateTimelineEntry_shouldReturnTrue() {
        // Given
        let timelineEntry = TimelineEntry(context: context)
        timelineEntry.id = UUID()
        timelineEntry.activity = createActivityEntity()
        timelineEntry.start = Date().addingTimeInterval(-3600)
        timelineEntry.end = Date()
        timelineEntry.describe = "Test Description"
        timelineEntry.points = 100.0
        
        viewModel.editTimeline = timelineEntry
        viewModel.activity = createActivityEntity()
        viewModel.start = Date().addingTimeInterval(-7200)
        viewModel.end = Date()
        viewModel.description = "Updated Description"
        viewModel.points = 200.0
        
        // When
        let result = viewModel.updateTimelineEntry(context: context)
        
        // Then
        XCTAssertTrue(result)
    }
    
    func test_deleteTimelineEntry_shouldReturnTrue() {
        // Given
        let timelineEntry = TimelineEntry(context: context)
        timelineEntry.id = UUID()
        timelineEntry.activity = createActivityEntity()
        timelineEntry.start = Date().addingTimeInterval(-3600)
        timelineEntry.end = Date()
        timelineEntry.describe = "Test Description"
        timelineEntry.points = 100.0
        
        viewModel.editTimeline = timelineEntry
        
        // When
        let result = viewModel.deleteTimelineEntry(context: context)
        
        // Then
        XCTAssertTrue(result)
    }
    
    func test_fetchTimelineEntries_shouldReturnData() {
        // Given
        let date = Date()
        
        // When
        let result = viewModel.fetchTimelineEntries(on: date, context: context)
        
        // Then
        XCTAssertNotNil(result)
    }
    
    func test_getMostRecentTimeline_shouldReturnData() {
        // Given
        viewModel.activity = createActivityEntity()
        viewModel.start = Date().addingTimeInterval(-3600)
        viewModel.end = Date()
        viewModel.description = "Test Description"
        viewModel.points = 100.0
        
        let result = viewModel.createTimelineEntry(context: context)
        
        // When
        viewModel.getMostRecentTimeline(context: context)
        
        // Then
        XCTAssertNotNil(viewModel.mostRecentTimeline)
    }
}

