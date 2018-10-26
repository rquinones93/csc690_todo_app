import UIKit

class ToDoController: UITableViewController {
    
    // Initialize new Task Store for the controller
    var taskStore = TaskStore() {
        didSet {
            // Get Unfinished and Finished arrays from UserDefaults if existing
            taskStore.tasks = TaskUtility.fetch() ?? [[Task](), [Task]()]
            
            // Reload table view
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: ADD NEW TASK
    @IBAction func addTask(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Add A Task", message: nil, preferredStyle: .alert)

        // Add UIAlertAction
        let addTask = UIAlertAction(title: "Add", style: .default) { _ in
            // Define addTask functionalities
            // Grab Text Field Text
            guard let name = alertController.textFields?.first?.text else {
                return
            }

            // Create a new, Unfinished Task
            let newTask = Task(name: name)

            // Add Task to TaskStore - Tasks prepended
            self.taskStore.addTask(newTask, at: 0)

            // Reload Data & Table View
            let indexPath = IndexPath(row: 0, section: 0)
            self.tableView.insertRows(at: [indexPath], with: .automatic)

            // Save Task to UserDefaults
            TaskUtility.save(self.taskStore.tasks)
        }

        // Grey Out Add Bar initially
        addTask.isEnabled = false

        // Cancel UIAlertAction
        let cancelTask = UIAlertAction(title: "Cancel", style: .cancel)

        // Alert Controller Placeholder Text
        alertController.addTextField{ textField in
            textField.placeholder = "Enter Task"
            textField.addTarget(self, action: #selector(self.handleTextChanged), for: .editingChanged)
        }

        // Add the addTask and cancelTask actions to UIAlertController
        alertController.addAction(addTask)
        alertController.addAction(cancelTask)

        // Show Alert Controller to View
        present(alertController, animated: true)
    }
 
    // Enable / Disable Add Button based on if there's text in the field
    @objc private func handleTextChanged(_ sender: UITextField) {
        // Add action to alert controller
        guard let alertController = presentedViewController as? UIAlertController,
            let addTask = alertController.actions.first,
            let text = sender.text
            else { return }
        
        // Enable / Disable
        addTask.isEnabled = !text.trimmingCharacters(in: .whitespaces).isEmpty
    }
}

// MARK: Data Source
// UITableDataSource -
extension ToDoController {
    
    // Adds Unfinished and Finished Tasks headers to define sections in app
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return (section == 0 ) ? "Unfinished Tasks" : "Finished Tasks"
    }
    
    // Helps Display Unfinished and Finished Sections
    override func numberOfSections(in tableView: UITableView) -> Int {
        return taskStore.tasks.count
    }
    
    // Display # Rows equal to # Tasks in each section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskStore.tasks[ section ].count
    }
    
    // Called every time TableView reloads data
    // Reuse cells, updates content
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        // Get Task's Descript to display in cell
        cell.textLabel?.text = taskStore.tasks[indexPath.section][indexPath.row].name
        return cell
    }
}

// MARK: Edit A Task
extension ToDoController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alertController = UIAlertController(title: "Edit Your Task", message: nil, preferredStyle: .alert)
        
        // Get Current Task to Edit used outside to pass into placeholder text.
        let currentTask = self.taskStore.tasks[indexPath.section][indexPath.row]
        
        // Add UIAlertAction
        let editTask = UIAlertAction(title: "Edit", style: .default) { _ in
            // Define addTask functionalities
            // Grab Text Field Text
            guard let newName = alertController.textFields?.first?.text else {
                return
            }
            
            // Get Current Row to update in TaskStore array
            let currentRow = indexPath.row
            
            // Add Task to TaskStore - Tasks prepended
            self.taskStore.updateTask(currentTask, at: currentRow, with: newName)
            
            // Reload Data & Table View
            let indexPath = IndexPath(row: 0, section: 0)
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
            
            // Save Task to UserDefaults
            TaskUtility.save(self.taskStore.tasks)
        }
        // Grey Out Add Bar initially
        editTask.isEnabled = false
        
        // Cancel UIAlertAction
        let cancelTask = UIAlertAction(title: "Cancel", style: .cancel)
        
        // Alert Controller Placeholder Text is the currentTask's data
        alertController.addTextField{ textField in
            textField.text = currentTask.name
            textField.addTarget(self, action: #selector(self.handleTextChanged), for: .editingChanged)
        }
        
        // Add the addTask and cancelTask actions to UIAlertController
        alertController.addAction(editTask)
        alertController.addAction(cancelTask)
        
        // Show Alert Controller to View
        present(alertController, animated: true)
    }
}

// MARK: - Delegate
extension ToDoController {
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    // MARK: DELETE TASK
    // Right to Left Swipe for Deletion
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // Create Contextual Action
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { (action, sourceView, completionHandler) in
            
            // Determine if task is completed
            guard let isCompleted = self.taskStore.tasks[indexPath.section][indexPath.row].isCompleted else { return }
            
            // Remove the task from the array
            self.taskStore.removeTask(at: indexPath.row, isCompleted: isCompleted)
            
            // Reload table view
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            // Save Task to UserDefaults
            TaskUtility.save(self.taskStore.tasks)
            
            // Show Action was performed
            completionHandler(true)
        }
        
        deleteAction.image = UIImage(named: "delete.png")
        deleteAction.backgroundColor = .red
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    // MARK: COMPLETE TASK
    // Left to Right Swipe for Completion
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // Create Contextual Action
        let completedAction = UIContextualAction(style: .normal, title: nil) { (action, sourceView, completionHandler) in
            
            // Toggle Task's isCompleted value - Finished Tasks cannot go back to unfinished
            self.taskStore.tasks[0][indexPath.row].isCompleted = true
            
            // Remove the task from Unfinished Array
            let completedTask = self.taskStore.removeTask(at: indexPath.row)
            
            // Reload table view for deletion
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            // Add to Finished Tasks
            self.taskStore.addTask(completedTask, at: 0, isCompleted: true)
            
            // Reload table view for adding to Finished section
            tableView.insertRows(at: [IndexPath(row: 0, section: 1)], with: .automatic)
            
            // Save Task to UserDefaults
            TaskUtility.save(self.taskStore.tasks)
            
            // Show Action was performed
            completionHandler(true)
        }
        
        completedAction.image = UIImage(named: "done.png")
        completedAction.backgroundColor = .green
        
        // Return Nil if trying to swipe right on Finished Tasks
        return indexPath.section == 0 ? UISwipeActionsConfiguration(actions: [completedAction]) : nil
    }
}
