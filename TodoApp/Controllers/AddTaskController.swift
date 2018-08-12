//
//  AddTaskViewController.swift
//  TodoApp
//
//  Created by vitali on 8/7/18.
//  Copyright © 2018 vitcopr. All rights reserved.
//

import UIKit

class AddTaskController: UITableViewController {
    
    // MARK: - Properties
    
    weak var addTaskSaveDelegate: AddTaskSaveDelegate?
    
    @IBOutlet weak var taskNameTextField: UITextField!
    @IBOutlet weak var taskDescriptionTextView: UITextView!
    @IBOutlet weak var remindMeSwitch: UISwitch!
    @IBOutlet weak var remindDateLabel: UILabel!
    @IBOutlet weak var selectedPriorityLabel: UILabel!
    
    
    private var remindDate: Date?
    private var taskPriority = Priority.none
    
    
    let remindDateFormatter: DateFormatter = {
        let fm = DateFormatter()
        fm.dateFormat = "EEEE, d MMMM yyyy, HH:mm"
        return fm
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        taskNameTextField.delegate = self
        tableView.tableFooterView = UIView()
        updateRemindDateLabel()
        updatePriorityLabel()
    }
    
    
    //MARK: - UITableViewDelegate and UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        switch indexPath.section {
        case 1 where indexPath.row == 0:
            return nil
        case 1 where indexPath.row == 1:
            if !remindMeSwitch.isOn{
                return nil
            }
        default:
            return indexPath
        }
        
        return indexPath
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.section {
        case 1 where indexPath.row == 1:
            selectRemindDateRowClicked()
        case 2 where indexPath.row == 0:
            selectPriorityRowClicked()
        
        default:
            ()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    //MARK: - Private Methods
    
    private func selectPriorityRowClicked(){
        showSelectPriorityController()
    }
    
    private func selectRemindDateRowClicked(){
        let selectDateController = SelectDateController(nibName: "SelectDate", bundle: nil)
        selectDateController.selectDateDelegate = self
        navigationController?.pushViewController(selectDateController, animated: true)
    }
    
    private func showSelectPriorityController(){
        let alertController = UIAlertController(title: "Select Priority", message: nil, preferredStyle: .actionSheet)
        
        let priorities: [Priority] = [.none, .low, .medium, .high]
        for priority in priorities {
            let action = UIAlertAction(title: priority.rawValue, style: .default, handler: selectTaskPriority)
            alertController.addAction(action)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: selectTaskPriority)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
        
    }
    
    private func selectTaskPriority(alert: UIAlertAction){
        guard let priorityString = alert.title,
              priorityString != "Cancel" else {
            return
        }
        
        if let priority = Priority(rawValue: priorityString) {
            taskPriority = priority
            updatePriorityLabel()
        }
    }
    
    
    private func updatePriorityLabel(){
        selectedPriorityLabel.text = taskPriority.rawValue
    }
    
    private func updateRemindDateLabel(){
        remindDateLabel.text = remindDateFormatter.string(from: remindDate ?? Date())
    }
    
    
    // MARK: - Actions
    
    @IBAction func backToTaskList(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    

    @IBAction func saveTask(_ sender: UIBarButtonItem) {
        
        guard let name = taskNameTextField.text,
            let descriptionString = taskDescriptionTextView.text else {
                fatalError("Wrong task parameters")
        }
        let description = descriptionString.isEmpty ? nil : descriptionString
        let remindDate = remindMeSwitch.isOn ? self.remindDate : nil
        
        let task = Task(id: "", name: name, description: description, remindDate: remindDate, priority: taskPriority)
        
        guard let addDelegate = addTaskSaveDelegate else {
            fatalError("Add delegate is nil")
        }
        addDelegate.save(task: task)
        navigationController?.popViewController(animated: true)
        
    }
    
}

//MARK: - UITextFieldDelegate

extension AddTaskController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        taskNameTextField.resignFirstResponder()
        return true
    }
}

//MARK: - SelectDateDelegate

extension AddTaskController: SelectDateDelegate {
    
    func minimumDate() -> Date {
        return Date()
    }
    
    func dateFormatter() -> DateFormatter {
        return remindDateFormatter
    }
    
    
    func dateSelected(date: Date){
        remindDate = date
        updateRemindDateLabel()
    }
    
}
