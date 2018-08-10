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
    }
    
    //MARK: - Actions
    
    @IBAction func editTaskList(_ sender: UIBarButtonItem) {
        
        tableView.isEditing = !tableView.isEditing
        sender.title = tableView.isEditing ? "Done" : "Edit"
        
    }
    
    
    //MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Consts.Identifiers.SHOW_ADD_TASK_SEGUE {
            if let destination = segue.destination as? AddTaskController {
                destination.addTaskSaveDelegate = self
            }
        }
    }
    

}

//MARK: - UITableViewDelegate

extension TodayTaskController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return TaskService.shared.getCategories()[section].name
        case 1:
            return TaskService.shared.getCategories()[section].name
        default:
            fatalError("Unknown section \(section)")
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let (task, category): (Task, TaskCategory) = {
                switch indexPath.section {
                case 0:
                    return (TaskService.shared.getPendingTasks()[indexPath.row],
                            TaskService.shared.getCategories()[indexPath.section])
                case 1:
                    return (TaskService.shared.getCompletedTasks()[indexPath.row],
                            TaskService.shared.getCategories()[indexPath.section])
                default:
                    fatalError("Unknown section \(indexPath.section)")
                }
            }()
            category.remove(task: task)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
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
        
        
        let task = tasks[indexPath.row]
        
        cell.taskNameLabel.text = task.name
        cell.taskDescriptionLabel.text = task.description ?? "No description"
        cell.taskDateLabel.text = task.remindDate != nil ? task.remindDate!.formattedString() : "No reminder"
        
        return cell
    }
}


//MARK: - AddTaskSaveDelegate

extension TodayTaskController: AddTaskSaveDelegate {
    
    func save(task: Task) {
        TaskService.shared.getCategories()[0].add(task: task)
        tableView.reloadData()
    }
    
    
    
}
