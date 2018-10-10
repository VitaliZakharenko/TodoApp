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
    
    
    
    private var sortOrder: InboxSorting = .byDate(ascend: true) {
        didSet {
            reloadData()
            sortTasks(by: sortOrder)
            tableView.reloadData()
        }
    }
    
    
    private var groupedItems: [(String, [Task])]!
    private var withoutGroup: [Task]?
    
    
    
    private var sectionDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Const.sectionDateFormat
        return dateFormatter
    }()
    
    
    //MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = editButtonItem
        loadGroupedData()
        sortOrder = .byDate(ascend: true)
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
    
    
    //MARK: - Private Methods
    
    
    private func configureTableView(){
        let nib = UINib(nibName: Consts.Nibs.taskCell, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: Consts.Identifiers.taskCell)
        tableView.tableFooterView = UIView()
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func loadGroupedData(){
        let (grouped, noGroup) = TaskManager.shared.groupedTasks(by: sortOrder)
        groupedItems = grouped
        withoutGroup = noGroup
    }
    
    
    private func reloadData(){
        loadGroupedData()
        sortTasks(by: sortOrder)
        tableView.reloadData()
    }
    
    
    private func taskFor(indexPath: IndexPath) -> Task {
        
        if let withoutGroup = withoutGroup, indexPath.section == (numberOfSections(in: tableView) - 1) {
            return withoutGroup[indexPath.row]
        } else {
            return groupedItems[indexPath.section].1[indexPath.row]
        }
    }
    
    private func sortTasks(by sortOrder: InboxSorting) {
        switch sortOrder {
        case .byDate(let ascend):
            if ascend {
                groupedItems.sort(by: {(group, otherGroup) in group.0.toDate() < otherGroup.0.toDate() })
            } else {
                groupedItems.sort(by: {(group, otherGroup) in group.0.toDate() >= otherGroup.0.toDate() })
            }
            
            for (idx, group) in groupedItems.enumerated() {
                let (dateString, tasks) = group
                let sortedTasks: [Task] = {
                    if ascend {
                        return tasks.sorted(by: {$0.remindDate! < $1.remindDate!})
                    } else {
                        return tasks.sorted(by: {$0.remindDate! >= $1.remindDate!})
                    }
                }()
                
                groupedItems[idx] = (dateString, sortedTasks)
            }
            
        case .byGroup(let ascend):
            
            if ascend {
                groupedItems.sort(by: { (group, otherGroup) in group.0 < otherGroup.0 })
            } else {
                groupedItems.sort(by: { (group, otherGroup) in group.0 >= otherGroup.0 })
            }
        }
        
    }
    
    private func changeSortOrder(){
        switch sortOrder {
        case .byDate(let ascend): sortOrder = .byDate(ascend: !ascend)
        case .byGroup(let ascend): sortOrder = .byGroup(ascend: !ascend)
        }
    }
    
    private func taskDone(_ rowAction: UITableViewRowAction, indexPath: IndexPath) {
        let task = taskFor(indexPath: indexPath)
        task.completed = Date()
        TaskManager.shared.update(task: task)
        reloadData()
    }
    
    private func taskUndone(_ rowAction: UITableViewRowAction, indexPath: IndexPath){
        let task = taskFor(indexPath: indexPath)
        task.completed = nil
        TaskManager.shared.update(task: task)
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
    }
    
    
}

//MARK: - UITableViewDelegate
extension InboxTaskController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let task = taskFor(indexPath: indexPath)
            TaskManager.shared.remove(task: task)
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
            switch task.completed {
            case nil:
                return UITableViewRowAction(style: .normal, title: Consts.Text.done, handler: self.taskDone)
            case _:
                return UITableViewRowAction(style: .normal, title: Consts.Text.undone, handler: self.taskUndone)
            }
        }()
        return [deleteAction, doneOrUndoneAction]
    }
    
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch sortOrder {
        case .byDate(_):
            if withoutGroup == nil && section == (numberOfSections(in: tableView) - 1) {
                return Const.noReminderSectionTitle
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
        
        if withoutGroup != nil {
            return groupedItems.count + 1
        } else {
            return groupedItems.count
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let withoutGroup = withoutGroup, section == (numberOfSections(in: tableView) - 1) {
            return withoutGroup.count
        } else {
            return groupedItems[section].1.count
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
extension InboxTaskController: AddTaskSaveDelegate {
    func save(task: Task) {
        TaskManager.shared.add(task: task)
        reloadData()
    }
    
    func update(task: Task) {
        TaskManager.shared.update(task: task)
        reloadData()
    }
    
    
}

