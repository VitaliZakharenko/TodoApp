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
        
        let nib = UINib(nibName: "TaskCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: Consts.Identifiers.TASK_CELL)
        tableView.delegate = self
        tableView.dataSource = self
    }

}

//MARK: - UITableViewDelegate

extension TodayTaskController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return " "
        case 1:
            return "Completed"
        default:
            fatalError("Unknown section \(section)")
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
        cell.taskDescriptionLabel.text = "No description"
        cell.taskDateLabel.text = task.planned.formattedString()
        
        return cell
    }
}
