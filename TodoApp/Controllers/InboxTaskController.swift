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
}

class InboxTaskController: UIViewController {
    
    //MARK: - Properties
    
    @IBOutlet weak var sortTypeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    
    private var groupedTasks: [[Task]]!
    private var sectionDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Const.sectionDateFormat
        return dateFormatter
    }()
    
    
    //MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = editButtonItem
        let allTasks = TaskService.shared.allTasks()
        groupedTasks = groupByRemindDay(tasks: allTasks)
        let nib = UINib(nibName: Consts.Nibs.taskCell, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: Consts.Identifiers.taskCell)
        tableView.tableFooterView = UIView()
        tableView.dataSource = self
        tableView.delegate = self
        
        
        
        
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
    }
    
    
    //MARK: - Private Methods
    
    private func groupByRemindDay(tasks: [Task]) -> [[Task]] {
        var groupedByDateWithDayGranularity = [Date: [Task]]()
        
        let withReminder = tasks.filter({ $0.isReminded })
        let noReminder = tasks.filter( { !$0.isReminded })
        
        
        for task in withReminder {
            if let index = groupedByDateWithDayGranularity.keys.index(where: { $0.compareByDayGranularity(other: task.remindDate!) }){
                let key = groupedByDateWithDayGranularity.keys[index]
                groupedByDateWithDayGranularity[key]!.append(task)
            } else {
                groupedByDateWithDayGranularity[task.remindDate!] = [task]
            }
        }
        
        // without reminder not included
        return Array(groupedByDateWithDayGranularity.values)
    }
    
    private func taskFor(indexPath: IndexPath) -> Task {
        return groupedTasks[indexPath.section][indexPath.row]
    }


}

//MARK: - UITableViewDelegate

extension InboxTaskController: UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionDate = groupedTasks[section][0].remindDate!
        return sectionDateFormatter.string(from: sectionDate)
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
        return groupedTasks.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupedTasks[section].count
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
