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
    
    private var categories = [TaskCategory]()
    
    
    init(){
        
        let pendingTasks = predefinedTestTasks()
        let pendingCategory = TaskCategory(id: "", name: " ")
        pendingCategory.add(tasks: pendingTasks)
        let completedTasks = [Task]()
        let completedCategory = TaskCategory(id: "", name: "Completed")
        completedCategory.add(tasks: completedTasks)
        
        categories.append(pendingCategory)
        categories.append(completedCategory)
        
    }
    
    func getCategories() -> [TaskCategory] {
        return categories
    }
    
    func getCompletedTasks() -> [Task] {
        return categories[1].getTasks()
    }
    
    func getPendingTasks() -> [Task] {
        return categories[0].getTasks()
    }
    
    
    private func predefinedTestTasks() -> [Task] {
        let t1 = Task(id: "", name: "First", planned: Date())
        let t2 = Task(id: "", name: "Second", planned: Date())
        let t3 = Task(id: "", name: "TestTask", planned: Date())
        
        return [t1, t2, t3]
    }
}
