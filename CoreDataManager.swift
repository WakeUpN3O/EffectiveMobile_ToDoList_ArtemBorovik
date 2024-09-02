import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    let persistentContainer: NSPersistentContainer

    private init() {
        persistentContainer = NSPersistentContainer(name: "ToDoListModel")
        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Unresolved error \(error)")
            }
        }
    }

    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    func addTodoItem(title: String, details: String, isCompleted: Bool) {
        let context = persistentContainer.viewContext
        let todoItem = ToDoItem(context: context)
        todoItem.title = title
        todoItem.details = details
        todoItem.createdAt = Date()
        todoItem.isCompleted = isCompleted
        saveContext()
    }

    func fetchTodoItems() -> [ToDoItem] {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<ToDoItem> = ToDoItem.fetchRequest()
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Fetch failed")
            return []
        }
    }

    func deleteTodoItem(item: ToDoItem) {
        let context = persistentContainer.viewContext
        context.delete(item)
        saveContext()
    }
}
