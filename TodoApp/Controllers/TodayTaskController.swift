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
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: Const.nibName, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: Consts.Identifiers.todayTasksCell)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    //MARK: - Actions
    
    @IBAction func editTaskList(_ sender: UIBarButtonItem) {
        
        if tableView.isEditing == true {
            tableView.setEditing(false, animated: true)
            sender.title = Const.titleEdit
        }
        else {
            tableView.setEditing(true, animated: true)
            sender.title = Const.titleDone
        }
    }
    
    //MARK: - Private Methods
    
    func taskFor(indexPath: IndexPath) -> Task {
        let task: Task = {
            switch indexPath.section {
            case 0:
                return TaskService.shared.pendingTasks()[indexPath.row]
            case 1:
                return TaskService.shared.completedTasks()[indexPath.row]
            default:
                fatalError("Unknown section \(indexPath.section)")
            }
        }()
        return task
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
        cell.taskDescriptionLabel.text = Const.noDescriptionText
        cell.taskDateLabel.text = task.planned.formattedString()
        
        return cell
    }
}


fileprivate struct Const {
    static let nibName = "TaskCell"
    static let titleEdit = "Edit"
    static let titleDone = "Done"
    static let noDescriptionText = "No description"
    static let sectionTitlePendingTasks = " "
    static let sectionTitleCompletedTasks = "Completed"
}
