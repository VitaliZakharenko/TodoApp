//
//  AddTaskViewController.swift
//  TodoApp
//
//  Created by vitali on 8/7/18.
//  Copyright © 2018 vitcopr. All rights reserved.
//

import UIKit

class AddTaskViewController: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak var addTaskView: AddTask!
    var addTaskSaveDelegate: AddTaskSaveDelegate?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    
    // MARK: - Actions
    
    @IBAction func backToTaskList(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    

    @IBAction func saveTask(_ sender: UIBarButtonItem) {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        
        guard let name = addTaskView.taskNameTextField.text,
              let descriptionString = addTaskView.taskDescriptionTextView.text,
              let dateString = addTaskView.selectDateButton.titleLabel?.text,
              let date = formatter.date(from: dateString) else {
                fatalError("Wrong task parameters")
        }
        
        let description = descriptionString.isEmpty ? nil : descriptionString
        
        let task = Task(id: "", name: name, description: description, planned: date)
        
        guard let addDelegate = addTaskSaveDelegate else {
            fatalError("Add delegate is nil")
        }
        addDelegate.save(task: task)
        navigationController?.popViewController(animated: true)
        
    }
    

}
