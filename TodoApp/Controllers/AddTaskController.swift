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
    
    
    var editedTask: Task?
    
    private var remindDate: Date = Date()
    private var taskPriority = Priority.none
    
    
    let remindDateFormatter: DateFormatter = {
        let fm = DateFormatter()
        fm.dateFormat = "EEEE, d MMM yyyy, HH:mm"
        return fm
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        taskNameTextField.delegate = self
        tableView.tableFooterView = UIView()
        configureTitle()
        if let task = editedTask {
            fillFieldsFromEdited(task: task)
        }
        setupGestureRecognizerForKeyboardDissmiss()
        setupSaveButton()
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
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
    
    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44.0
    }
    
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionView = Section(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 44.0))
        let title = self.tableView(self.tableView, titleForHeaderInSection: section)
        sectionView.titleLabel.text = title?.uppercased()
        return sectionView
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
        remindDateLabel.text = remindDateFormatter.string(from: remindDate)
    }
    
    private func setupSaveButton(){
        let taskName = taskNameTextField.text ?? ""
        navigationItem.rightBarButtonItem?.isEnabled = !taskName.isEmpty
    }
    
    private func setupGestureRecognizerForKeyboardDissmiss(){
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissTextViewKeyboard(_:)))
        gestureRecognizer.cancelsTouchesInView = false
        tableView.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc private func dismissTextViewKeyboard(_ sender: UITapGestureRecognizer) {
        taskDescriptionTextView.endEditing(true)
    }
    
    private func configureTitle(){
        if editedTask == nil {
            navigationItem.title = "Add Item"
        } else {
            navigationItem.title = "Edit Item"
        }
    }
    
    private func fillFieldsFromEdited(task: Task){
        taskNameTextField.text = task.name
        if task.isReminded {
            remindDate = task.remindDate!
            updateRemindDateLabel()
        } else {
            remindMeSwitch.isOn = false
        }
        taskPriority = task.priority
        updatePriorityLabel()
        taskDescriptionTextView.text = task.description
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
        
        let newTask = Task(id: "", name: name, description: description, remindDate: remindDate, priority: taskPriority)
        
        guard let addDelegate = addTaskSaveDelegate else {
            fatalError("Add delegate is nil")
        }
        if let oldTask = editedTask {
            addDelegate.update(old: oldTask, new: newTask)
        } else {
            addDelegate.save(task: newTask)
        }
        
        navigationController?.popViewController(animated: true)
        
    }
    
    
}

//MARK: - UITextFieldDelegate

extension AddTaskController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        taskNameTextField.resignFirstResponder()
        setupSaveButton()
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

