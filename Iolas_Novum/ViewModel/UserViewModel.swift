//
//  UserViewModel.swift
//  Iolas_Novum
//
//  Created by Iolas on 11/07/2023.
//

import Foundation
import CoreData

final class UserViewModel: ObservableObject {
    @Published var user: UserEntity?
    @Published var name: String = ""
    @Published var motto: String = ""
    @Published var income: Double = 0.0
    @Published var points: Double = 0.0
    
    var context: NSManagedObjectContext?
    
    func fetchUser() {
        let fetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        
        do {
            if let context = context {
                let users = try context.fetch(fetchRequest)
                
                if let fetchedUser = users.first {
                    // A User entity already exists, so use it to update the published properties.
                    self.user = fetchedUser
                    self.name = fetchedUser.name ?? ""
                    self.motto = fetchedUser.motto ?? ""
                    self.income = fetchedUser.income
                    self.points = fetchedUser.points
                } else {
                    // No User entity exists, so create a new User entity and save it to the Core Data store.
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
            print("Failed to fetch User: \(error)")
        }
    }
}

