import Foundation

struct ToDo: Decodable {
    let id: Int
    let todo: String
    let completed: Bool
}

class APIClient {
    func fetchTodos(completion: @escaping ([ToDo]) -> Void) {
        let url = URL(string: "https://dummyjson.com/todos")!
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data {
                let todos = try? JSONDecoder().decode([ToDo].self, from: data)
                completion(todos ?? [])
            }
        }.resume()
    }
}

class DataManager {
    let apiClient = APIClient()

    func loadInitialData(completion: @escaping () -> Void) {
        DispatchQueue.global(qos: .background).async {
            self.apiClient.fetchTodos { todos in
                todos.forEach { todo in
                    CoreDataManager.shared.addTodoItem(
                        title: todo.todo,
                        details: "",
                        isCompleted: todo.completed
                    )
                }
                completion()
            }
        }
    }
}
