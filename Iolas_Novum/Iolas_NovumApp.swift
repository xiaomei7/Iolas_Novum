//
//  Iolas_NovumApp.swift
//  Iolas_Novum
//
//  Created by Iolas on 10/07/2023.
//

import SwiftUI
import CoreData

@main
struct Iolas_NovumApp: App {
    let persistenceController = PersistenceController.shared
    
    init() {
        let context = persistenceController.container.viewContext
        let fetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        
        do {
            let users = try context.fetch(fetchRequest)
            
            if let user = users.first {
                print("🖊️ User's name: \(user.name ?? "❗️ Fail to fetch the user")")
            } else {
                // No User entity exists, so create a new User entity and save it to the Core Data store.
                let newUser = UserEntity(context: context)
                newUser.id = UUID()
                newUser.name = "Default Name"
                newUser.income = 3000.0
                newUser.points = 0.0
                newUser.motto = "Life is short."
                
                try context.save()
            }
        } catch {
            print("⛔️ Failed to fetch User: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
