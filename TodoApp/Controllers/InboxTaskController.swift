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
    
    
    
    private var allTasks: [Task]!
    private var allCategories: [TaskCategory]!
    
    private var groupedItems: [(String, [Task])]!
    private var withoutGroup: (String, [Task])!
    
    
    
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
        groupTasks()
        sortTasks(by: sortOrder)
        configureTableView()
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
    
    
    
    //MARK: - Actions
    
    
    @IBAction func sortOrderChanged(_ sender: UIBarButtonItem) {
        changeSortOrder()
        sortTasks(by: sortOrder)
        tableView.reloadData()
    }
    
    
    @IBAction func sortCateoryInSegmentedControlChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            sortOrder = .byDate(ascend: true)
        case 1:
            sortOrder = .byGroup(ascend: true)
        default:
            fatalError("Unknown index \(sender.selectedSegmentIndex) in segmented control")
        }
        reloadData()
    }
    

}


//MARK: - Private Helper Methods

fileprivate extension InboxTaskController {
    
    
    private func configureTableView(){
        let nib = UINib(nibName: Consts.Nibs.taskCell, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: Consts.Identifiers.taskCell)
        tableView.tableFooterView = UIView()
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func loadData(){
        allTasks = TaskService.shared.allTasks()
        allCategories = TaskService.shared.allCategories()
    }
    
    private func groupTasks(){
        switch sortOrder {
        case .byDate(ascend: _):
            let withReminder = allTasks.filter({ $0.isReminded })
            let withoutReminder = allTasks.filter({ !$0.isReminded })
            withoutGroup = (Const.noReminderSectionTitle, withoutReminder)
            groupedItems = groupByRemindDate(tasksWithReminder: withReminder)
        case .byGroup(ascend: _):
            groupedItems = groupByCategory(categories: allCategories)
        }
    }
    
    private func reloadData(){
        loadData()
        groupTasks()
        sortTasks(by: sortOrder)
        tableView.reloadData()
    }
    
    
    private func group<T, K: Hashable>(items: [(K, T)], by comparator: ((K, K) -> Bool)) -> [K: [T]] {
        var groupedItems: [K: [T]] = [K: [T]]()
        
        for (keyToGroup, item) in items {
            if let index = groupedItems.keys.index(where: { comparator($0, keyToGroup) }) {
                let key = groupedItems.keys[index]
                groupedItems[key]!.append(item)
            } else {
                groupedItems[keyToGroup] = [item]
            }
        }
        return groupedItems
    }
    
    
    private func groupByCategory(categories: [TaskCategory]) -> [(String, [Task])]{
        var items = [(String, Task)]()
        for category in categories {
            for task in category.allTasks() {
                let item = (category.name, task)
                items.append(item)
            }
        }
        return group(items: items, by: { $0 == $1 }).map({ (key, value) in (key, value) })
    }
    
    
    private func groupByRemindDate(tasksWithReminder: [Task]) -> [(String, [Task])] {
        var items = [(Date, Task)]()
        for task in tasksWithReminder {
            let item = (task.remindDate!, task)
            items.append(item)
        }
        
        let grouped = group(items: items, by: { $0.compareByDayGranularity(other: $1)})
        var result = [String: [Task]]()
        for (key, value) in grouped {
            result[key.formattedString()] = value
        }
        return grouped.map({ (key, value) in (key.formattedString(), value)})
    }
    
    
    private func taskFor(indexPath: IndexPath) -> Task {
        switch sortOrder {
        case .byDate(_):
            if indexPath.section == (numberOfSections(in: tableView) - 1) {
                return withoutGroup.1[indexPath.row]
            } else {
                return groupedItems[indexPath.section].1[indexPath.row]
            }
        case .byGroup(_):
            return groupedItems[indexPath.section].1[indexPath.row]
        }
    }
    
    private func sortTasks(by sortOrder: InboxSorting) {
        switch sortOrder {
        case .byDate(let ascend) where ascend == true:
            groupedItems.sort(by: {(group, otherGroup) in group.0.toDate() < otherGroup.0.toDate() })
            for (idx, group) in groupedItems.enumerated() {
                let (dateString, tasks) = group
                let sortedTasks = tasks.sorted(by: {$0.remindDate! < $1.remindDate!})
                groupedItems[idx] = (dateString, sortedTasks)
            }
        case .byDate(let ascend) where ascend == false:
            groupedItems.sort(by: {(group, otherGroup) in group.0.toDate() >= otherGroup.0.toDate() })
            for (idx, group) in groupedItems.enumerated() {
                let (dateString, tasks) = group
                let sortedTasks = tasks.sorted(by: {$0.remindDate! >= $1.remindDate!})
                groupedItems[idx] = (dateString, sortedTasks)
            }
        case .byGroup(let ascend):
            
            if ascend {
                groupedItems.sort(by: { (group, otherGroup) in group.0 < otherGroup.0 })
            } else {
                groupedItems.sort(by: { (group, otherGroup) in group.0 >= otherGroup.0 })
            }
            
        default:
            fatalError("Unknown sorting \(sortOrder)")
        }
        
    }
    
    private func changeSortOrder(){
        switch sortOrder {
        case .byDate(let ascend): sortOrder = .byDate(ascend: !ascend)
        case .byGroup(let ascend): sortOrder = .byGroup(ascend: !ascend)
        }
    }
    
    private func taskDone(_ rowAction: UITableViewRowAction, indexPath: IndexPath) {
        var task = taskFor(indexPath: indexPath)
        task.completed = Date()
        TaskService.shared.update(task: task)
        reloadData()
    }
    
    private func taskUndone(_ rowAction: UITableViewRowAction, indexPath: IndexPath){
        var task = taskFor(indexPath: indexPath)
        task.completed = nil
        TaskService.shared.update(task: task)
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
    
    private func configure(cell: TaskCell, task: Task) -> TaskCell {
        cell.taskNameLabel.text = task.name
        cell.taskDescriptionLabel.text = task.description ?? Consts.Text.noDescriptionText
        cell.taskDateLabel.text = task.remindDate != nil ? task.remindDate!.formattedString() : Consts.Text.noReminderText
        return cell
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
        switch sortOrder {
        case .byDate(_):
            if section == (numberOfSections(in: tableView) - 1) {
                return withoutGroup.0
            } else {
                let sectionDate =  groupedItems[section].0
                return sectionDate
            }
        
        case .byGroup(_):
            return groupedItems[section].0
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
        switch sortOrder {
        case .byDate(_):
            return groupedItems.count + 1
        case .byGroup(_):
            return groupedItems.count
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch sortOrder {
        case .byDate(_):
            if section == (numberOfSections(in: tableView) - 1){
                return withoutGroup.1.count
            } else {
                return groupedItems[section].1.count
            }
        
        case .byGroup(_):
            return groupedItems[section].1.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: Consts.Identifiers.taskCell, for: indexPath) as! TaskCell
        let task = taskFor(indexPath: indexPath)
        return configure(cell: cell, task: task)
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
