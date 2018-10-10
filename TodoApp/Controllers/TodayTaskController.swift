//
//  ViewController.swift
//  TodoApp
//
//  Created by vitali on 7/31/18.
//  Copyright © 2018 vitcopr. All rights reserved.
//

import UIKit


fileprivate struct Const {
    static let sectionTitlePendingTasks = " "
    static let sectionTitleCompletedTasks = "Completed"
}


class TodayTaskController: UIViewController {
    
    //MARK: - Properties
    
    @IBOutlet weak var tableView: UITableView!
    
    var category: TaskCategory?
    
    private var pendingTasks: [Task]!
    private var completedTasks: [Task]!
    
    
    //MARK: - Lifecycle
    

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavbar()
        loadData()
        configureTableView()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        loadData()
        tableView.reloadData()
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
    
    
    private func configureNavbar(){
        
        if let category = category {
            navigationItem.title = category.name
            let backItem = UIBarButtonItem(title: Consts.Text.back, style: .plain, target: self, action: #selector(backBarItemClicked))
            navigationItem.leftBarButtonItems = [backItem, editButtonItem]
        } else {
            navigationItem.leftBarButtonItem = editButtonItem
        }
    }
    
    
    @objc func backBarItemClicked(){
        navigationController?.popViewController(animated: true)
    }
    
    
    private func configureTableView(){
        let nib = UINib(nibName: Consts.Nibs.taskCell, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: Consts.Identifiers.taskCell)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
    }
    
    private func loadData(){
        
        if let category = category {
            
            pendingTasks = TaskManager.shared.pendingTasks(category: category)
            completedTasks = TaskManager.shared.completedTasks(category: category)
        } else {
            pendingTasks = TaskManager.shared.pendingTasks()
            completedTasks = TaskManager.shared.completedTasks()
        }
    }
    
    private func taskFor(indexPath: IndexPath) -> Task {
        
        let task: Task = {
            switch indexPath.section {
            case 0:
                return pendingTasks[indexPath.row]
            case 1:
                return completedTasks[indexPath.row]
            default:
                fatalError("Unknown section \(indexPath.section)")
            }
        }()
        
        return task
    }
    
    private func taskDone(_ rowAction: UITableViewRowAction, indexPath: IndexPath) {
        let task = taskFor(indexPath: indexPath)
        task.completed = Date()
        TaskManager.shared.update(task: task)
        loadData()
        tableView.reloadData()
    }
    
    private func taskUndone(_ rowAction: UITableViewRowAction, indexPath: IndexPath){
        let task = taskFor(indexPath: indexPath)
        task.completed = nil
        TaskManager.shared.update(task: task)
        loadData()
        tableView.reloadData()
    }
    
    private func deleteTask(_ rowAction: UITableViewRowAction, indexPath: IndexPath){
        let alertController = UIAlertController(title: Consts.Text.delete, message: Consts.Text.deleteTaskAlertMessage, preferredStyle: .alert)
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
            TaskManager.shared.remove(task: task)
            loadData()
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
            return pendingTasks.count
        case 1:
            return completedTasks.count
        default:
            fatalError("Unknown section \(section)")
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: Consts.Identifiers.taskCell, for: indexPath) as! TaskCell
        
        let task = taskFor(indexPath: indexPath)
        
        cell.taskNameLabel.text = task.name
        cell.taskDescriptionLabel.text = task.taskDescription ?? Consts.Text.noDescriptionText
        cell.taskDateLabel.text = task.remindDate != nil ? task.remindDate!.formattedString() : Consts.Text.noReminderText
        return cell
    }
}


//MARK: - AddTaskSaveDelegate

extension TodayTaskController: AddTaskSaveDelegate {
    
    
    func save(task: Task) {
        TaskManager.shared.add(task: task, category: category)
        loadData()
        tableView.reloadData()
    }
    
    func update(task: Task) {
        TaskManager.shared.update(task: task)
        loadData()
        tableView.reloadData()
    }
}

