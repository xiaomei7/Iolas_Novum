import Foundation
import CoreData

final class UserViewModel: ObservableObject {
    @Published var user: UserEntity?
    @Published var name: String = ""
    @Published var motto: String = ""
    @Published var income: Double = 0.0
    @Published var points: Double = 0.0
    
    var context: NSManagedObjectContext?
    
    func updateUser(context: NSManagedObjectContext) -> Bool {
        guard let user = user else { return false }
        
        user.name = name
        user.motto = motto
        user.income = income
        
        if let _ = try? context.save() {
            return true
        }
        return false
    }
    
    func updatePoints(context: NSManagedObjectContext) -> Bool {
        guard let user = user else { return false }
        
        user.points = points
        
        if let _ = try? context.save() {
            return true
        }
        return false
    }
    
    func fetchUser() {
        let fetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        
        do {
            if let context = context {
                let users = try context.fetch(fetchRequest)
                
                if let fetchedUser = users.first {
                    self.user = fetchedUser
                    self.name = fetchedUser.name ?? ""
                    self.motto = fetchedUser.motto ?? ""
                    self.income = fetchedUser.income
                    self.points = fetchedUser.points
                } else {
                    let newUser = UserEntity(context: context)
                    newUser.name = "Default Name"
                    newUser.motto = "Default Motto"
                    newUser.income = 0.0
                    newUser.points = 0.0
                    
                    try context.save()
                    
                    self.user = newUser
                    self.name = newUser.name ?? ""
                    self.motto = newUser.motto ?? ""
                    self.income = newUser.income
                    self.points = newUser.points
                }
            }
        } catch {
            print("⛔️ Failed to fetch User: \(error)")
        }
    }
}

