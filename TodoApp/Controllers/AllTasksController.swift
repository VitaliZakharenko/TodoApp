//
//  AllTasksController.swift
//  TodoApp
//
//  Created by vitali on 8/27/18.
//  Copyright © 2018 vitcopr. All rights reserved.
//

import UIKit

class AllTasksController: UIViewController {
    
    //MARK: - Properties
    
    @IBOutlet weak var tableView: UITableView!
    
    private var inboxCategory: TaskCategory!
    private var otherCategories: [TaskCategory]!
    
    
    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        configureTableView()
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: true)
        tableView.setEditing(editing, animated: true)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Consts.Identifiers.showAddCategorySegue {
            if let destination = segue.destination as? AddCategoryController {
                destination.addCategoryDelegate = self
            }
        }
    }
    
    //MARK: - Private Methods
    
    private func taskCategory(for indexPath: IndexPath) -> TaskCategory {
        if indexPath.section == 0 {
            return inboxCategory
        } else {
            return otherCategories[indexPath.row - 1]
        }
    }


    private func loadData(){
        let allCategories = TaskService.shared.allCategories()
        otherCategories = allCategories.filter({ $0.name != Consts.Categories.inboxName })
        inboxCategory = allCategories.first(where: { $0.name == Consts.Categories.inboxName})!
    }

    private func configureTableView(){
        let nibCategory = UINib(nibName: Consts.Nibs.categoryCell, bundle: nil)
        tableView.register(nibCategory, forCellReuseIdentifier: Consts.Identifiers.categoryCell)
        let nibAddCategory = UINib(nibName: Consts.Nibs.addCategoryCell, bundle: nil)
        tableView.register(nibAddCategory, forCellReuseIdentifier: Consts.Identifiers.addCategoryCell)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        navigationItem.leftBarButtonItem = editButtonItem
    }
}


//MARK: - UITableViewDelegate

extension AllTasksController: UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return " "
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

extension AllTasksController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return otherCategories.count + 1
        default:
            fatalError("Unknown section \(section)")
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 1 && indexPath.row == 0 {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: Consts.Identifiers.addCategoryCell, for: indexPath) as! AddCategoryCell
            return cell
        } else {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: Consts.Identifiers.categoryCell, for: indexPath) as! CategoryCell
            
            let currCategory = taskCategory(for: indexPath)
            
            cell.categoryNameLabel.text = currCategory.name
            cell.numberOfTasksLabel.text = "(\(currCategory.allTasks().count))"
            
            return cell
        }
        
    }
}


//MARK: - AddCategoryDelegate

extension AllTasksController: AddCategoryDelegate {
    
    func add(category: TaskCategory) {
        TaskService.shared.add(category: category)
        loadData()
        tableView.reloadData()
    }
    
    
}
