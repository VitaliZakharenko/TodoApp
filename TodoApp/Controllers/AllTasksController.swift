//
//  AllTasksController.swift
//  TodoApp
//
//  Created by vitali on 8/27/18.
//  Copyright © 2018 vitcopr. All rights reserved.
//

import UIKit

fileprivate struct Const {
    
    static let deleteCategoryAlertMessage = "Are you sure you want to remove this item?"
    static let editProjectAlertTitle = "Edit Project"
}

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
        navigationItem.leftBarButtonItem = editButtonItem
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
        tableView.reloadData()
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
    }
    
    
    private func showAddCategoryController(){
        let storyboard = UIStoryboard(name: Consts.Storyboards.main, bundle: Bundle.main)
        let addCategoryController = storyboard.instantiateViewController(withIdentifier: Consts.Identifiers.addCategoryController) as! AddCategoryController
        addCategoryController.addCategoryDelegate = self
        navigationController?.pushViewController(addCategoryController, animated: true)
    }
    
    private func showAllTasks(of category: TaskCategory){
        let storyboard = UIStoryboard(name: Consts.Storyboards.main, bundle: Bundle.main)
        let tasksController = storyboard.instantiateViewController(withIdentifier: Consts.Identifiers.allTasksOfCategoryController) as! TodayTaskController
        tasksController.category = category
        navigationController?.pushViewController(tasksController, animated: true)
    }
    
    
    private func deleteCategory(_ rowAction: UITableViewRowAction, indexPath: IndexPath){
        let alertController = UIAlertController(title: Consts.Text.delete, message: Const.deleteCategoryAlertMessage, preferredStyle: .alert)
        let cancel = UIAlertAction(title: Consts.Text.cancel, style: .cancel, handler: nil)
        let delete = UIAlertAction(title: Consts.Text.delete, style: .destructive, handler: { (alertAction) -> Void in
            self.tableView(self.tableView, commit: .delete, forRowAt: indexPath)
        })
        
        alertController.addAction(cancel)
        alertController.addAction(delete)
        present(alertController, animated: true, completion: nil)
    }
    
    private func changeCategoryName(_ rowAction: UITableViewRowAction, indexPath: IndexPath){
        let alertController = UIAlertController(title: Const.editProjectAlertTitle, message: " ", preferredStyle: .alert)
        let cancel = UIAlertAction(title: Consts.Text.cancel, style: .cancel, handler: nil)
        alertController.addAction(cancel)
        alertController.addTextField(configurationHandler: nil)
        let done = UIAlertAction(title: Consts.Text.done, style: .default, handler: { (alertAction) in
            guard let textField = alertController.textFields?.first else { return }
            self.newCategoryNameEntered(newName: textField.text!, for: indexPath)
            })
        alertController.addAction(done)
        present(alertController, animated: true, completion: nil)
        
    }
    
    private func newCategoryNameEntered(newName: String, for indexPath: IndexPath){
        let category = taskCategory(for: indexPath)
        category.name = newName
        TaskService.shared.update(category: category)
        loadData()
        tableView.reloadData()
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
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if (indexPath.section == 1 && indexPath.row == 0) || (indexPath.section == 0) {
            return false
        } else {
            return true
        }
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let category = taskCategory(for: indexPath)
            TaskService.shared.remove(category: category)
            loadData()
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 1 && indexPath.row == 0 {
            showAddCategoryController()
            return
        }
        
        let category = taskCategory(for: indexPath)
        showAllTasks(of: category)
        
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteAction = UITableViewRowAction(style: .destructive, title: Consts.Text.delete, handler: self.deleteCategory)
        let editAction = UITableViewRowAction(style: .normal, title: Consts.Text.edit, handler: self.changeCategoryName)
        return [deleteAction, editAction]
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
            cell.numberOfTasksLabel.text = "(\(currCategory.tasks!.count))"
            
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
