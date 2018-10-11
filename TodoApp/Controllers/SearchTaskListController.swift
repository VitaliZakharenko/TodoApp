//
//  TaskListController.swift
//  TodoApp
//
//  Created by vitali on 8/29/18.
//  Copyright © 2018 vitcopr. All rights reserved.
//

import UIKit


fileprivate struct Const {
    
    static let searchBarPlaceholder = "Search Tasks"
    static let attributedTextBackgroundColor = UIColor.fromHexString("#FFFF00", alpha: 0.8)
    static let attributedTextForegrondColor = UIColor.black
    static let attributesForTextHighlighting = [
        NSAttributedStringKey.backgroundColor: Const.attributedTextBackgroundColor,
        NSAttributedStringKey.foregroundColor: Const.attributedTextForegrondColor
    ]
}

class SearchTaskListController: UIViewController {
    
    //MARK: - Properties
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noResultView: UIView!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    private var showActiveTasks = true
    private var allTasksOfType: [Task]!
    private var taskNameToSearch: String?
    private var tasksToShow: [Task]!
    
    private var noResult: Bool! {
        didSet{
            noResultView.isHidden = !noResult
        }
    }
    
    
    
    
    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        configureTableView()
        configureSearchController()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
        tableView.reloadData()
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

//MARK: - Private helper methods

fileprivate extension SearchTaskListController {
    
    
    private func loadData(){
        if showActiveTasks {
            allTasksOfType = TaskManager.shared.pendingTasks()
        } else {
            allTasksOfType = TaskManager.shared.completedTasks()
        }
        
        if let filter = taskNameToSearch {
            tasksToShow = allTasksOfType.filter({ $0.name!.lowercased().contains(filter.lowercased())})
        } else {
            tasksToShow = allTasksOfType
        }
        
        noResult = tasksToShow.count == 0
        
    }
    
    private func configureTableView(){
        let nibCell = UINib(nibName: Consts.Nibs.taskCell, bundle: Bundle.main)
        tableView.register(nibCell, forCellReuseIdentifier: Consts.Identifiers.taskCell)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
    }
    
    private func configureSearchController(){
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = Const.searchBarPlaceholder
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    
    private func filterTasksFor(searchString: String?){
        taskNameToSearch = searchString
        loadData()
        tableView.reloadData()
    }
    
    private func configure(cell: TaskCell, task: Task) -> TaskCell {
        cell.taskNameLabel.attributedText = task.name!.highlight(substring: taskNameToSearch, attributes: Const.attributesForTextHighlighting, caseSensitive: false)
        cell.taskNameLabel.text = task.name
        cell.taskDescriptionLabel.text = task.taskDescription ?? Consts.Text.noDescriptionText
        cell.taskDateLabel.text = task.remindDate != nil ? task.remindDate!.formattedString() : Consts.Text.noReminderText
        return cell
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
        return configure(cell: cell, task: task)
        
    }
    
}

//MARK: - UISearchControllerDelegate

extension SearchTaskListController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        if searchController.searchBar.text!.isEmpty{
            filterTasksFor(searchString: nil)
        } else {
            filterTasksFor(searchString: searchController.searchBar.text)
        }
        
        
    }
}


//MARK: - AddTaskSaveDelegate

extension SearchTaskListController: AddTaskSaveDelegate {
    
    
    func save(task: Task) {
        fatalError("Not used in this screen")
    }
    
    func update(task: Task) {
        TaskManager.shared.update(task: task)
        loadData()
        tableView.reloadData()
    }
}

