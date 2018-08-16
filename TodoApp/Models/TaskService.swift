//
//  TaskService.swift
//  TodoApp
//
//  Created by vitali on 7/31/18.
//  Copyright © 2018 vitcopr. All rights reserved.
//

import Foundation

class TaskService {
    
    static let shared = TaskService()
    
    private var dataStorage = UserDefaultsDataStorage()
    
    var pendingCategory: TaskCategory
    var completedCategory: TaskCategory
    
    
    init(){
        
        let allTasks = dataStorage.getAllTasks()
        
        let pendingTasks = allTasks.filter({!$0.isCompleted})
        pendingCategory = TaskCategory(id: "", name: " ")
        pendingCategory.add(tasks: pendingTasks)
        let completedTasks = allTasks.filter({$0.isCompleted})
        completedCategory = TaskCategory(id: "", name: "Completed")
        completedCategory.add(tasks: completedTasks)
        
        
    }
    
    func getCategoriesCount() -> Int {
        return 2
    }
    
    func getCompletedTasks() -> [Task] {
        return completedCategory.getTasks()
    }
    
    func getPendingTasks() -> [Task] {
        return pendingCategory.getTasks()
    }
    
    func update(old: Task, new: Task){
        updateInCategory(category: pendingCategory, old: old, new: new)
        updateInCategory(category: completedCategory, old: old, new: new)
        dataStorage.update(old: old, new: new)
    }
    
    func save(task: Task){
        if task.isCompleted {
            completedCategory.add(task: task)
        } else {
            pendingCategory.add(task: task)
        }
        dataStorage.save(tasks: [task])
    }
    
    func remove(task: Task){
        if task.isCompleted {
            completedCategory.remove(task: task)
        } else {
            pendingCategory.remove(task: task)
        }
        dataStorage.delete(tasks: [task])
    }
    
    private func updateInCategory(category: TaskCategory, old: Task, new: Task){
        for task in category.getTasks(){
            if task.name == old.name {
                category.remove(task: old)
                category.add(task: new)
            }
        }
    }
    
}
