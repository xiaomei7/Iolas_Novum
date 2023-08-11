import XCTest
import CoreData
@testable import Iolas_Novum

final class UserViewModel_Tests: XCTestCase {
    
    var viewModel: UserViewModel!
    var context: NSManagedObjectContext!
    
    override func setUp() {
        super.setUp()
        
        context = TestCoreDataStack().persistentContainer.newBackgroundContext()
        
        viewModel = UserViewModel()
        viewModel.context = context
    }
    
    
    override func tearDown() {
        super.tearDown()
        viewModel = nil
        context = nil
    }
    
    func test_updateUser_shouldBeUpdated() {
        // Given
        let user = UserEntity(context: context)
        user.id = UUID()
        user.name = "Test User"
        user.motto = "Test Motto"
        user.income = 1000.0
        viewModel.user = user
        viewModel.name = "Updated User"
        viewModel.motto = "Updated Motto"
        viewModel.income = 2000.0
        
        // When
        let result = viewModel.updateUser(context: context)
        
        // Then
        XCTAssertTrue(result)
        XCTAssertEqual(viewModel.user?.name, "Updated User")
        XCTAssertEqual(viewModel.user?.motto, "Updated Motto")
        XCTAssertEqual(viewModel.user?.income, 2000.0)
    }
    
    func test_updatePoints_shouldReturnTrue() {
        // Given
        let user = UserEntity(context: context)
        user.id = UUID()
        user.points = 100.0
        viewModel.user = user
        viewModel.points = 200.0
        
        // When
        let result = viewModel.updatePoints(context: context)
        
        // Then
        XCTAssertTrue(result)
        XCTAssertEqual(viewModel.user?.points, 200.0)
    }
    
    func test_fetchUser_shouldReturnUser() {
        // Given
        let user = UserEntity(context: context)
        user.id = UUID()
        user.name = "Test User"
        user.motto = "Test Motto"
        user.income = 1000.0
        user.points = 100.0
        
        do {
            try context.save()
        } catch {
            XCTFail("Failed to save context: \(error)")
        }
        
        // When
        viewModel.fetchUser()
        
        // Then
        XCTAssertNotNil(viewModel.user)
        XCTAssertEqual(viewModel.user?.name, "Test User")
        XCTAssertEqual(viewModel.user?.motto, "Test Motto")
        XCTAssertEqual(viewModel.user?.income, 1000.0)
        XCTAssertEqual(viewModel.user?.points, 100.0)
    }
}

