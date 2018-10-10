//
//  AddTaskViewController.swift
//  TodoApp
//
//  Created by vitali on 8/7/18.
//  Copyright © 2018 vitcopr. All rights reserved.
//

import UIKit


fileprivate struct Const {
    static let navbarTitileAdd = "Add Item"
    static let navbarTitleEdit = "Edit Item"
    static let selectPriorityTitle = "Select Priority"
    static let nibSelectDate = "SelectDate"
    static let dateFormatString = "EEEE, d MMM yyyy, HH:mm"
}


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
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Const.dateFormatString
        return dateFormatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        taskNameTextField.delegate = self
        taskDescriptionTextView.delegate = self
        tableView.tableFooterView = UIView()
        configureTitle()
        if let task = editedTask {
            fillFieldsFrom(task)
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
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 3 && indexPath.row == 0 {
            return UITableViewAutomaticDimension
        }
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
    
    
    
    //MARK: - Callbacks
    
    @objc private func dismissTextViewKeyboard(_ sender: UITapGestureRecognizer) {
        taskDescriptionTextView.endEditing(true)
        let _ = textFieldShouldReturn(taskNameTextField)
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
        
        
        guard let addDelegate = addTaskSaveDelegate else {
            fatalError("Add delegate is nil")
        }
        if let oldTask = editedTask {
            let updatedTask = TaskService.shared.createTask(oldTask: oldTask, name: name, description: description, remindDate: remindDate, priority: taskPriority)
            addDelegate.update(task: updatedTask)
        } else {
            let newTask = TaskService.shared.createTask(name: name, description: description, remindDate: remindDate, priority: taskPriority)
            addDelegate.save(task: newTask)
        }
        
        navigationController?.popViewController(animated: true)
        
    }
}

//MARK: Private helper methods
fileprivate extension AddTaskController {
    
    private func selectPriorityRowClicked(){
        showSelectPriorityController()
    }
    
    private func selectRemindDateRowClicked(){
        let selectDateController = SelectDateController(nibName: Const.nibSelectDate, bundle: nil)
        selectDateController.selectDateDelegate = self
        navigationController?.pushViewController(selectDateController, animated: true)
    }
    
    private func showSelectPriorityController(){
        let alertController = UIAlertController(title: Const.selectPriorityTitle, message: nil, preferredStyle: .actionSheet)
        
        let priorities: [Priority] = [.none, .low, .medium, .high]
        for priority in priorities {
            let action = UIAlertAction(title: priority.rawValue, style: .default, handler: selectTaskPriority)
            alertController.addAction(action)
        }
        
        let cancelAction = UIAlertAction(title: Consts.Text.cancel, style: .cancel, handler: selectTaskPriority)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
        
    }
    
    private func selectTaskPriority(alert: UIAlertAction){
        guard let priorityString = alert.title,
            priorityString != Consts.Text.cancel else {
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
    
    
    private func configureTitle(){
        if editedTask == nil {
            navigationItem.title = Const.navbarTitileAdd
        } else {
            navigationItem.title = Const.navbarTitleEdit
        }
    }
    
    private func fillFieldsFrom(_ editedTask: Task){
        taskNameTextField.text = editedTask.name
        if editedTask.isReminded {
            remindDate = editedTask.remindDate!
            updateRemindDateLabel()
        } else {
            remindMeSwitch.isOn = false
        }
        taskPriority = editedTask.priority
        updatePriorityLabel()
        taskDescriptionTextView.text = editedTask.description
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

//MARK: - UITextViewDelegate

extension AddTaskController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        
        let size = textView.bounds.size
        let newSize = textView.sizeThatFits(CGSize(width: size.width, height: CGFloat.greatestFiniteMagnitude))
        
        if size.height != newSize.height {
            UIView.setAnimationsEnabled(false)
            tableView.beginUpdates()
            tableView.endUpdates()
            UIView.setAnimationsEnabled(true)
        }
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

