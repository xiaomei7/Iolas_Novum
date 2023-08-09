import Foundation
import CoreData

final class TodoViewModel: ObservableObject {
    @Published var todos: [TodoEntity] = []
    
    // MARK: Todo Attributes
    @Published var name: String = ""
    @Published var color: String = "PresetColor-1"
    @Published var frequency: [Int] = []
    @Published var reward: Double = 0.0
    @Published var linkedActivity: ActivityEntity? = nil
    @Published var completionDates: [TodoCompletionDates] = []
    
    // MARK: Functional Variables
    @Published var addOrEditTodo: Bool = false {
        didSet {
            if !addOrEditTodo {
                resetData()
            }
        }
    }
    @Published var editTodo: TodoEntity?
    
    @Published var isRepetitive: Bool = false
    
    // MARK: CRUD
    func createTodo(context: NSManagedObjectContext) -> Bool {
        let todo = TodoEntity(context: context)
        todo.id = UUID()
        todo.name = name
        todo.color = color
        todo.reward = reward
        todo.frequency = frequency
        todo.activity = linkedActivity
        todo.created = Date()
        
        let completionDatesSet = NSSet(array: completionDates)
        todo.completionDates = completionDatesSet
        
        if let _ = try? context.save() {
            return true
        }
        print("⛔️ Failed to create todos.")
        return false
    }
    
    func updateTodo(context: NSManagedObjectContext) -> Bool {
        if let todo = editTodo {
            todo.name = name
            todo.color = color
            todo.reward = reward
            todo.frequency = frequency
            todo.activity = linkedActivity
            
            
            let completionDatesSet = NSSet(array: completionDates)
            todo.completionDates = completionDatesSet
            
            if let _ = try? context.save() {
                return true
            }
        }
        print("⛔️ Failed to update todos.")
        return false
    }
    
    func deleteTodo(context: NSManagedObjectContext) -> Bool {
        if let todo = editTodo {
            context.delete(todo)
            if let _ = try? context.save() {
                return true
            }
        }
        return false
    }
    
    // MARK: Detail Functions
    func fetchAndFilterTodos(context: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<TodoEntity> = TodoEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \TodoEntity.name, ascending: false)]
        do {
            let allTodos = try context.fetch(fetchRequest)
            let calendar = Calendar.current
            let today = calendar.component(.weekday, from: Date())
            todos = allTodos.filter { todo in
                if todo.frequency?.isEmpty ?? true {
                    // Include todos that do not have a frequency
                    return true
                }
                if let frequency = todo.frequency, frequency.contains(today) {
                    // Include todos where today is in the frequency
                    return true
                }
                return false
            }
        } catch {
            print("⛔️ Failed to fetch todos: \(error)")
        }
    }
    
    
    @discardableResult
    func updateTodoCompletionStatus(todo: TodoEntity, isComplete: Bool, context: NSManagedObjectContext) -> Bool {
        let completionDatesSet = todo.completionDates as? Set<TodoCompletionDates>
        let today = Date().startOfDay
        
        if let completionDate = completionDatesSet?.first(where: { $0.date?.startOfDay == today }) {
            completionDate.isComplete = isComplete
        } else {
            let newCompletionDate = TodoCompletionDates(context: context)
            newCompletionDate.date = today
            newCompletionDate.isComplete = isComplete
            todo.addToCompletionDates(newCompletionDate)
        }
        
        do {
            try context.save()
            return true
        } catch {
            print("⛔️ Failed to update todo completion status: \(error)")
            return false
        }
    }
    
    
    func resetData() {
        name = ""
        color = "PresetColor-1"
        frequency = []
        
        editTodo = nil
    }
}
