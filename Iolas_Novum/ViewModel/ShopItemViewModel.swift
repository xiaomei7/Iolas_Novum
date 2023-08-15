import Foundation
import CoreData

final class ShopItemViewModel: ObservableObject {
    // MARK: Item Properties
    @Published var name: String = ""
    @Published var description: String = ""
    @Published var price: Double = 0.0
    
    // MARK: Functional Variables
    @Published var addorEditShopItem: Bool = false {
        didSet {
            if !addorEditShopItem {
                resetData()
            }
        }
    }
    @Published var editShopItem: ShopItem?
    
    // MARK: CRUD
    func createShopItem(context: NSManagedObjectContext) -> Bool {
        let item = ShopItem(context: context)
        item.id = UUID()
        item.name = name
        item.describe = description
        item.price = price
        
        if let _ = try? context.save(){
            return true
        }
        return false
    }
    
    func updateShopItem(context: NSManagedObjectContext) -> Bool {
        if let item = editShopItem {
            item.name = name
            item.describe = description
            item.price = price
            
            if let _ = try? context.save() {
                return true
            }
        }
        return false
    }
    
    func deleteShopItem(context: NSManagedObjectContext) -> Bool {
        if let item = editShopItem {
            context.delete(item)
            if let _ = try? context.save() {
                return true
            }
        }
        return false
    }
    
    // MARK: Detail Functions
    
    func restoreEditData(){
        if let item = editShopItem {
            name = item.name ?? ""
            description = item.describe ?? ""
            price = item.price
        }
    }
    
    func resetData() {
        name = ""
        description = ""
        price = 0.0
        
        editShopItem = nil
    }
}
