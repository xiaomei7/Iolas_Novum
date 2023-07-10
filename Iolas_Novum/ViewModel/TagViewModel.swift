//
//  TagViewModel.swift
//  Iolas_Novum
//
//  Created by Iolas on 10/07/2023.
//

import Foundation
import CoreData

final class TagViewModel: ObservableObject {
    // MARK: Tag Properties
    @Published var name: String = ""
    @Published var color: String = "PresetColor-1"
    
    // MARK: Functional Variables
    @Published var addorEditTag: Bool = false
    @Published var editTag: TagEntity?
    
    // MARK: CRUD
    func createTag(context: NSManagedObjectContext) -> Bool {
        let tag = TagEntity(context: context)
        tag.id = UUID()
        tag.name = name
        tag.color = color
        
        if let _ = try? context.save(){
            return true
        }
        return false
    }
    
    func updateTag(context: NSManagedObjectContext) -> Bool {
        if let tag = editTag {
            tag.name = name
            tag.color = color
            
            if let _ = try? context.save() {
                return true
            }
        }
        return false
    }
    
    func deleteTag(context: NSManagedObjectContext) -> Bool {
        if let tag = editTag {
            context.delete(tag)
            if let _ = try? context.save() {
                return true
            }
        }
        return false
    }
    
    // MARK: Detail Functions
    
    func resetData() {
        name = ""
        color = "PresetColor-1"
        
        editTag = nil
    }
    
    func doneStatus() -> Bool {
        if name == "" {
            return false
        }
        return true
    }
}
