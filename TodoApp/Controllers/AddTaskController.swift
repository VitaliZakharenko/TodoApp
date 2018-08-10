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
    
    private var remindDate: Date = Date()
    
    
    let remindDateFormatter: DateFormatter = {
        let fm = DateFormatter()
        fm.dateFormat = "EEEE, d MMMM yyyy, HH:mm"
        return fm
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        taskNameTextField.delegate = self
        remindDateLabel.text = remindDateFormatter.string(from: remindDate)
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
        
        let task = Task(id: "", name: name, description: description, remindDate: remindDate)
        
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
