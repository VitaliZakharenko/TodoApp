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
        
        let nib = UINib(nibName: "TaskCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: Consts.Identifiers.TASK_CELL)
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
        if segue.identifier == Consts.Identifiers.SHOW_ADD_TASK_SEGUE {
            if let destination = segue.destination as? AddTaskController {
                destination.addTaskSaveDelegate = self
            }
        }
    }
    
    
    //MARK: - Private Methods
    
    private func getTaskFor(indexPath: IndexPath) -> Task {
        
        let tasks: [Task] = {
            switch indexPath.section {
            case 0:
                return TaskService.shared.getPendingTasks()
            case 1:
                return TaskService.shared.getCompletedTasks()
            default:
                fatalError("Unknown section \(indexPath.section)")
            }
        }()
        
        
        return tasks[indexPath.row]
    }
    
    private func taskDone(_ rowAction: UITableViewRowAction, indexPath: IndexPath) {
        let task = getTaskFor(indexPath: indexPath)
        task.completed = Date()
        TaskService.shared.update(old: task, new: task)
        tableView.reloadData()
    }
    
    private func taskUndone(_ rowAction: UITableViewRowAction, indexPath: IndexPath){
        let task = getTaskFor(indexPath: indexPath)
        task.completed = nil
        TaskService.shared.update(old: task, new: task)
        tableView.reloadData()
    }
    
    private func deleteTask(_ rowAction: UITableViewRowAction, indexPath: IndexPath){
        let alertController = UIAlertController(title: "Delete", message: "Do you want to delete task?", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let delete = UIAlertAction(title: "Delete", style: .destructive, handler: { (alertAction) -> Void in
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
            return TaskService.shared.pendingCategory.name
        case 1:
            return TaskService.shared.completedCategory.name
        default:
            fatalError("Unknown section \(section)")
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let task: Task = {
                switch indexPath.section {
                case 0:
                    return TaskService.shared.pendingCategory.getTasks()[indexPath.row]
                case 1:
                    return TaskService.shared.completedCategory.getTasks()[indexPath.row]
                default:
                    fatalError("Unknown section \(indexPath.section)")
                }
            }()
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
            let task = getTaskFor(indexPath: indexPath)
            
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let editTaskController = storyboard.instantiateViewController(withIdentifier: "AddTaskControllerId") as! AddTaskController
            editTaskController.addTaskSaveDelegate = self
            editTaskController.editedTask = task
            navigationController?.pushViewController(editTaskController, animated: true)
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete", handler: self.deleteTask)
        
        let doneOrUndoneAction: UITableViewRowAction = {
            switch indexPath.section {
            case 0:
                return UITableViewRowAction(style: .normal, title: "Done", handler: self.taskDone)
            case 1:
                return UITableViewRowAction(style: .normal, title: "Undone", handler: self.taskUndone)
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
            return TaskService.shared.getPendingTasks().count
        case 1:
            return TaskService.shared.getCompletedTasks().count
        default:
            fatalError("Unknown section \(section)")
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: Consts.Identifiers.TASK_CELL, for: indexPath) as! TaskCell
        
        let task = getTaskFor(indexPath: indexPath)
        
        cell.taskNameLabel.text = task.name
        cell.taskDescriptionLabel.text = task.description ?? "No description"
        cell.taskDateLabel.text = task.remindDate != nil ? task.remindDate!.formattedString() : "No reminder"
        return cell
    }
}


//MARK: - AddTaskSaveDelegate

extension TodayTaskController: AddTaskSaveDelegate {
    
    func save(task: Task) {
        TaskService.shared.save(task: task)
        tableView.reloadData()
    }
    
    func update(old: Task, new: Task) {
        TaskService.shared.update(old: old, new: new)
        tableView.reloadData()
    }
    
    
    
}
