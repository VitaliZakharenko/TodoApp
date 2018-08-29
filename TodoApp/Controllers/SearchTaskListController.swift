//
//  TaskListController.swift
//  TodoApp
//
//  Created by vitali on 8/29/18.
//  Copyright © 2018 vitcopr. All rights reserved.
//

import UIKit

class SearchTaskListController: UIViewController {
    
    //MARK: - Properties
    
    @IBOutlet weak var tableView: UITableView!
    
    private var showActiveTasks = true
    private var tasksToShow: [Task]!
    
    
    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        configureTableView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
        tableView.reloadData()
    }
    
    
    //MARK: - Private Methods
    
    private func loadData(){
        if showActiveTasks {
            tasksToShow = TaskService.shared.pendingTasks()
        } else {
            tasksToShow = TaskService.shared.completedTasks()
        }
    }
    
    private func configureTableView(){
        let nibCell = UINib(nibName: Consts.Nibs.taskCell, bundle: Bundle.main)
        tableView.register(nibCell, forCellReuseIdentifier: Consts.Identifiers.taskCell)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
    }
    
    //MARK: - Actions
    
    
    @IBAction func segmentedControlItemChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            showActiveTasks = true
        } else {
            showActiveTasks = false
        }
        loadData()
        tableView.reloadData()
    }
    

}

//MARK: - UITableViewDelegate

extension SearchTaskListController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let task = tasksToShow[indexPath.row]
        
        let storyboard = UIStoryboard(name: Consts.Storyboards.main, bundle: Bundle.main)
        let editTaskController = storyboard.instantiateViewController(withIdentifier: Consts.Identifiers.addTaskController) as! AddTaskController
        editTaskController.addTaskSaveDelegate = self
        editTaskController.editedTask = task
        navigationController?.pushViewController(editTaskController, animated: true)
        
    }
    
    
    
}

//MARK: - UITableViewDataSource

extension SearchTaskListController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasksToShow.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: Consts.Identifiers.taskCell, for: indexPath) as! TaskCell
        
        
        let task = tasksToShow[indexPath.row]
        
        cell.taskNameLabel.text = task.name
        cell.taskDescriptionLabel.text = task.description ?? Consts.Text.noDescriptionText
        cell.taskDateLabel.text = task.remindDate != nil ? task.remindDate!.formattedString() : Consts.Text.noReminderText
            
        return cell
        
    }
    
}


//MARK: - AddTaskSaveDelegate

extension SearchTaskListController: AddTaskSaveDelegate {
    
    
    func save(task: Task) {
        fatalError("Not used in this screen")
    }
    
    func update(task: Task) {
        TaskService.shared.update(task: task)
        loadData()
        tableView.reloadData()
    }
}

