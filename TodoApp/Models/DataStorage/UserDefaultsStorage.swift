//
//  UserDefaultsStorage.swift
//  TodoApp
//
//  Created by vitali on 8/15/18.
//  Copyright © 2018 vitcopr. All rights reserved.
//

import Foundation

class UserDefaultsDataStorage: DataStorage {
   
    
    static var shared = UserDefaultsDataStorage()
    
    private var key = "Tasks"
    private var tasks = [Task]()
    
    
    init(){
        loadFromUserDefaults()
    }
    
    func save(tasks: [Task]) {
        
        var tasksToAdd = [Task]()
        
        for task in tasks {
            if !self.tasks.contains(where: {$0.name == task.name}) {
                tasksToAdd.append(task)
            }
        }
        self.tasks.append(contentsOf: tasksToAdd)
        
        saveToUserDefaults()
    }
    
    func getAllTasks() -> [Task] {
        return tasks
    }
    
    func delete(tasks: [Task]) {
        for task in tasks {
            if let index = self.tasks.index(where: {$0.name == task.name}) {
                self.tasks.remove(at: index)
            }
        }
        saveToUserDefaults()
    }
    
    func update(old: Task, new: Task) {
        if let index = tasks.index(where: {$0.name == old.name}) {
            tasks[index] = new
        }
        saveToUserDefaults()
    }
    
    //MARK: - Private methods
    
    private func loadFromUserDefaults(){
        guard let taskArray = UserDefaults.standard.array(forKey: key) as? [[String: Any]] else {
            return
        }
        for item in taskArray {
            let task = convert(dictToTask: item)
            tasks.append(task)
        }
    }
    
    private func saveToUserDefaults(){
        var arrayOfDicts = [[String: Any]]()
        for task in tasks {
            let dict = convertToDict(task: task)
            arrayOfDicts.append(dict)
        }
        
        UserDefaults.standard.set(arrayOfDicts, forKey: key)
    }
    
    private func convertToDict(task: Task) -> [String: Any] {
        var dict = [String: Any]()
        dict["taskName"] = task.name
        dict["taskPriority"] = task.priority.rawValue
        
        if task.isReminded {
            dict["taskRemindDate"] = task.remindDate!
        }
        if let descr = task.description {
            dict["taskDescription"] = descr
        }
        if let completedDate = task.completed {
            dict["taskCompletedDate"] = completedDate
        }
        return dict
    }
    
    private func convert(dictToTask dict: [String: Any]) -> Task {
        
        guard let name = dict["taskName"] as? String,
              let priorityString = dict["taskPriority"] as? String,
              let priority = Priority(rawValue: priorityString) else {
                fatalError("Task name or task priority not defined")
        }
        
        let description: String? = {
            if let descr = dict["taskDescription"] as? String {
                return descr
            } else {
                return nil
            }
        }()
        
        let remindDate: Date? = {
            if let remindDate = dict["taskRemindDate"] as? Date {
                return remindDate
            } else {
                return nil
            }
        }()
        
        let completedDate: Date? = {
            if let completedDate = dict["taskCompletedDate"] as? Date {
                return completedDate
            } else {
                return nil
            }
        }()
        
        let task = Task(id: "", name: name, description: description, remindDate: remindDate, priority: priority)
        task.completed = completedDate
        return task
    }
    
    
}
