//
//  InboxTaskController.swift
//  TodoApp
//
//  Created by vitali on 8/16/18.
//  Copyright © 2018 vitcopr. All rights reserved.
//

import UIKit

fileprivate struct Const {
    static let sectionDateFormat = "dd.MM.yyyy"
    static let noReminderSectionTitle = "No reminder"
}

class InboxTaskController: UIViewController {
    
    //MARK: - Properties
    
    @IBOutlet weak var sortTypeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    
    
    private var sortOrder: InboxSorting = .byDate(ascend: true)
    
    private var groupedTasksWithReminder: [[Task]]!
    private var tasksWithoutReminder: [Task] = [Task]()
    private var sectionDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Const.sectionDateFormat
        return dateFormatter
    }()
    
    
    //MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = editButtonItem
        loadData()
        configureTableView()
        sortTasks(by: sortOrder)
        tableView.reloadData()
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
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
    
    
    private func configureTableView(){
        let nib = UINib(nibName: Consts.Nibs.taskCell, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: Consts.Identifiers.taskCell)
        tableView.tableFooterView = UIView()
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func loadData(){
        let withReminder = TaskService.shared.tasksBy(predicate: { $0.isReminded })
        tasksWithoutReminder = TaskService.shared.tasksBy(predicate: { !$0.isReminded })
        groupedTasksWithReminder = groupByRemindDay(tasks: withReminder)
    }
    
    private func reloadData(){
        loadData()
        sortTasks(by: sortOrder)
        tableView.reloadData()
    }
    
    private func groupByRemindDay(tasks: [Task]) -> [[Task]] {
        var groupedByDateWithDayGranularity = [Date: [Task]]()
        
        for task in tasks {
            if let index = groupedByDateWithDayGranularity.keys.index(where: { $0.compareByDayGranularity(other: task.remindDate!) }){
                let key = groupedByDateWithDayGranularity.keys[index]
                groupedByDateWithDayGranularity[key]!.append(task)
            } else {
                groupedByDateWithDayGranularity[task.remindDate!] = [task]
            }
        }
        return Array(groupedByDateWithDayGranularity.values)
    }
    
    private func taskFor(indexPath: IndexPath) -> Task {
        if indexPath.section == (numberOfSections(in: tableView) - 1) {
            return tasksWithoutReminder[indexPath.row]
        } else {
            return groupedTasksWithReminder[indexPath.section][indexPath.row]
        }
    }
    
    private func sortTasks(by sortOrder: InboxSorting) {
        switch sortOrder {
        case .byDate(let ascend) where ascend == true:
            groupedTasksWithReminder.sort(by: { $0[0].remindDate! < $1[0].remindDate! })
            for var group in groupedTasksWithReminder {
                group.sort(by: { $0.remindDate! < $1.remindDate! })
            }
        case .byDate(let ascend) where ascend == false:
            groupedTasksWithReminder.sort(by: { $0[0].remindDate! >= $1[0].remindDate! })
            for var group in groupedTasksWithReminder {
                group.sort(by: { $0.remindDate! >= $1.remindDate! })
            }
        default:
            fatalError("Unknown sorting \(sortOrder)")
        }
        
    }
    
    private func changeSortOrder(){
        switch sortOrder {
        case .byDate(let ascend): sortOrder = .byDate(ascend: !ascend)
        default:
            fatalError("Unknown sorting \(sortOrder)")
        }
    }
    
    private func taskDone(_ rowAction: UITableViewRowAction, indexPath: IndexPath) {
        let task = taskFor(indexPath: indexPath)
        var newTask = Task(id: task.id, name: task.name, description: task.description, remindDate: task.remindDate, priority: task.priority)
        newTask.completed = Date()
        TaskService.shared.update(task: newTask)
        reloadData()
    }
    
    private func taskUndone(_ rowAction: UITableViewRowAction, indexPath: IndexPath){
        let task = taskFor(indexPath: indexPath)
        var newTask = Task(id: task.id, name: task.name, description: task.description, remindDate: task.remindDate, priority: task.priority)
        newTask.completed = nil
        TaskService.shared.update(task: newTask)
        reloadData()
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
    
    
    //MARK: - Actions
    
    
    @IBAction func sortOrderChanged(_ sender: UIBarButtonItem) {
        changeSortOrder()
        sortTasks(by: sortOrder)
        tableView.reloadData()
    }
    

}

//MARK: - UITableViewDelegate

extension InboxTaskController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let task = taskFor(indexPath: indexPath)
            TaskService.shared.remove(task: task)
            reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let task = taskFor(indexPath: indexPath)
            
        let storyboard = UIStoryboard(name: Consts.Storyboards.main, bundle: Bundle.main)
        let editTaskController = storyboard.instantiateViewController(withIdentifier: Consts.Identifiers.addTaskController) as! AddTaskController
        editTaskController.addTaskSaveDelegate = self
        editTaskController.editedTask = task
        navigationController?.pushViewController(editTaskController, animated: true)
        
    }
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteAction = UITableViewRowAction(style: .destructive, title: Consts.Text.delete, handler: self.deleteTask)
        
        let task = taskFor(indexPath: indexPath)
        let doneOrUndoneAction: UITableViewRowAction = {
            switch task.isCompleted {
            case false:
                return UITableViewRowAction(style: .normal, title: Consts.Text.done, handler: self.taskDone)
            case true:
                return UITableViewRowAction(style: .normal, title: Consts.Text.undone, handler: self.taskUndone)
            }
        }()
        return [deleteAction, doneOrUndoneAction]
    }

    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == (numberOfSections(in: tableView) - 1) {
            return Const.noReminderSectionTitle
        } else {
            let sectionDate = groupedTasksWithReminder[section][0].remindDate!
            return sectionDateFormatter.string(from: sectionDate)
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
    
    
    
}

//MARK: - UITableViewDataSource

extension InboxTaskController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return groupedTasksWithReminder.count + 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == (numberOfSections(in: tableView) - 1){
            return tasksWithoutReminder.count
        } else {
            return groupedTasksWithReminder[section].count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: Consts.Identifiers.taskCell, for: indexPath) as! TaskCell
        
        let task = taskFor(indexPath: indexPath)
        
        cell.taskNameLabel.text = task.name
        cell.taskDescriptionLabel.text = task.description ?? Consts.Text.noDescriptionText
        cell.taskDateLabel.text = task.remindDate != nil ? task.remindDate!.formattedString() : Consts.Text.noReminderText
        return cell
    }
}

//MARK: - AddTaskSaveDelegate

extension InboxTaskController: AddTaskSaveDelegate {
    func save(task: Task) {
        TaskService.shared.add(task: task)
        reloadData()
    }
    
    func update(task: Task) {
        TaskService.shared.update(task: task)
        reloadData()
    }
    
    
}
