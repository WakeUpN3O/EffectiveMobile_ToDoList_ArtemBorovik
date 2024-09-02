import UIKit
import CoreData

class ToDoListViewController: UITableViewController {
    var todoItems: [ToDoItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "ToDo List"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTodoItem))

        todoItems = CoreDataManager.shared.fetchTodoItems()
        if todoItems.isEmpty {
            DataManager().loadInitialData { [weak self] in
                DispatchQueue.main.async {
                    self?.todoItems = CoreDataManager.shared.fetchTodoItems()
                    self?.tableView.reloadData()
                }
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        todoItems = CoreDataManager.shared.fetchTodoItems()
        tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "TodoCell")
        let todoItem = todoItems[indexPath.row]
        cell.textLabel?.text = todoItem.title
        cell.detailTextLabel?.text = todoItem.details
        cell.accessoryType = todoItem.isCompleted ? .checkmark : .none
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let todoItem = todoItems[indexPath.row]
        presentEditAlert(for: todoItem)
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let todoItem = todoItems[indexPath.row]
            CoreDataManager.shared.deleteTodoItem(item: todoItem)
            todoItems.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    @objc func addTodoItem() {
        presentAddAlert()
    }

    func presentAddAlert() {
        let alert = UIAlertController(title: "New Task", message: "Enter task title", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Title"
        }
        alert.addTextField { textField in
            textField.placeholder = "Details"
        }
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let title = alert.textFields?[0].text, !title.isEmpty else { return }
            let details = alert.textFields?[1].text ?? ""
            CoreDataManager.shared.addTodoItem(title: title, details: details, isCompleted: false)
            self.todoItems = CoreDataManager.shared.fetchTodoItems()
            self.tableView.reloadData()
        }
        alert.addAction(saveAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true)
    }

    func presentEditAlert(for todoItem: ToDoItem) {
        let alert = UIAlertController(title: "Edit Task", message: "Update task details", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.text = todoItem.title
        }
        alert.addTextField { textField in
            textField.text = todoItem.details
        }
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let title = alert.textFields?[0].text, !title.isEmpty else { return }
            todoItem.title = title
            todoItem.details = alert.textFields?[1].text ?? ""
            CoreDataManager.shared.saveContext()
            self.todoItems = CoreDataManager.shared.fetchTodoItems()
            self.tableView.reloadData()
        }
        alert.addAction(saveAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
}
