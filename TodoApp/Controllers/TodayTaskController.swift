//
//  ViewController.swift
//  TodoApp
//
//  Created by vitali on 7/31/18.
//  Copyright © 2018 vitcopr. All rights reserved.
//

import UIKit

class TodayTaskController: UIViewController {
    
    //MARK: - Properties
    
    @IBOutlet weak var tableView: UITableView!
    
    
    //MARK: - Lifecycle
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: Const.nibTaskCell, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: Consts.Identifiers.todayTasksCell)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        navigationItem.leftBarButtonItem = editButtonItem
        
    }
    
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: true)
        tableView.setEditing(editing, animated: true)
    }
    
    
    //MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Consts.Identifiers.showAddTaskSegue {
            if let destination = segue.destination as? AddTaskController {
                destination.addTaskSaveDelegate = self
            }
        }
    }
    
    
    //MARK: - Private Methods
    
    private func taskFor(indexPath: IndexPath) -> Task {
        
        let tasks: [Task] = {
            switch indexPath.section {
            case 0:
                return TaskService.shared.pendingTasks()
            case 1:
                return TaskService.shared.completedTasks()
            default:
                fatalError("Unknown section \(indexPath.section)")
            }
        }()
        
        
        return tasks[indexPath.row]
    }
    
    private func taskDone(_ rowAction: UITableViewRowAction, indexPath: IndexPath) {
        let task = taskFor(indexPath: indexPath)
        var newTask = Task(id: task.id, name: task.name, description: task.description, remindDate: task.remindDate, priority: task.priority)
        newTask.completed = Date()
        TaskService.shared.update(task: newTask)
        tableView.reloadData()
    }
    
    private func taskUndone(_ rowAction: UITableViewRowAction, indexPath: IndexPath){
        let task = taskFor(indexPath: indexPath)
        var newTask = Task(id: task.id, name: task.name, description: task.description, remindDate: task.remindDate, priority: task.priority)
        newTask.completed = nil
        TaskService.shared.update(task: newTask)
        tableView.reloadData()
    }
    
    private func deleteTask(_ rowAction: UITableViewRowAction, indexPath: IndexPath){
        let alertController = UIAlertController(title: Consts.Text.delete, message: Const.deleteTaskAlertMessage, preferredStyle: .alert)
        let cancel = UIAlertAction(title: Consts.Text.cancel, style: .cancel, handler: nil)
        let delete = UIAlertAction(title: Consts.Text.delete, style: .destructive, handler: { (alertAction) -> Void in
            self.tableView(self.tableView, commit: .delete, forRowAt: indexPath)
        })
        
        alertController.addAction(cancel)
        alertController.addAction(delete)
        present(alertController, animated: true, completion: nil)
    }
    

}

//MARK: - UITableViewDelegate

extension TodayTaskController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return Const.sectionTitlePendingTasks
        case 1:
            return Const.sectionTitleCompletedTasks
        default:
            fatalError("Unknown section \(section)")
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let task = taskFor(indexPath: indexPath)
            TaskService.shared.remove(task: task)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44.0
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionView = Section(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 44.0))
        let title = self.tableView(self.tableView, titleForHeaderInSection: section)
        sectionView.titleLabel.text = title?.uppercased()
        return sectionView
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // edit only undone tasks
        if indexPath.section == 0 {
            let task = taskFor(indexPath: indexPath)
            
            let storyboard = UIStoryboard(name: Consts.Storyboards.main, bundle: Bundle.main)
            let editTaskController = storyboard.instantiateViewController(withIdentifier: Consts.Identifiers.addTaskController) as! AddTaskController
            editTaskController.addTaskSaveDelegate = self
            editTaskController.editedTask = task
            navigationController?.pushViewController(editTaskController, animated: true)
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteAction = UITableViewRowAction(style: .destructive, title: Consts.Text.delete, handler: self.deleteTask)
        
        let doneOrUndoneAction: UITableViewRowAction = {
            switch indexPath.section {
            case 0:
                return UITableViewRowAction(style: .normal, title: Consts.Text.done, handler: self.taskDone)
            case 1:
                return UITableViewRowAction(style: .normal, title: Consts.Text.undone, handler: self.taskUndone)
            default:
                fatalError("Unknown section \(indexPath.section)")
            }
        }()
        return [deleteAction, doneOrUndoneAction]
    }
    
    
    
}


//MARK: - UITableViewDataSource

extension TodayTaskController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return TaskService.shared.pendingTasks().count
        case 1:
            return TaskService.shared.completedTasks().count
        default:
            fatalError("Unknown section \(section)")
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: Consts.Identifiers.todayTasksCell, for: indexPath) as! TaskCell
        
        let task = taskFor(indexPath: indexPath)
        
        cell.taskNameLabel.text = task.name
        cell.taskDescriptionLabel.text = task.description ?? Const.noDescriptionText
        cell.taskDateLabel.text = task.remindDate != nil ? task.remindDate!.formattedString() : Const.noReminderText
        return cell
    }
}


//MARK: - AddTaskSaveDelegate

extension TodayTaskController: AddTaskSaveDelegate {
    
    
    func save(task: Task) {
        TaskService.shared.add(task: task)
        tableView.reloadData()
    }
    
    func update(task: Task) {
        TaskService.shared.update(task: task)
        tableView.reloadData()
    }
}


fileprivate struct Const {
    static let nibTaskCell = "TaskCell"
    static let noDescriptionText = "No description"
    static let noReminderText = "No reminder"
    static let sectionTitlePendingTasks = " "
    static let sectionTitleCompletedTasks = "Completed"
    static let deleteTaskAlertMessage = "Do you want to delete task?"
    
}
