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
    
    var tasks = [Task]()
    
    
    func add(task: Task){
        if !tasks.contains(where: {$0.id == task.id}){
            tasks.append(task)
        }
    }
    
    func remove(task: Task){
        if let index = tasks.index(where: {$0.id == task.id}){
            tasks.remove(at: index)
        }
    }
    
    func getTasks() -> [Task] {
        // return tasks
        return predefinedTestTasks()
    }
    
    func getCompletedTasks() -> [Task] {
        let tasks = getTasks()
        return tasks.filter({$0.isCompleted})
    }
    
    func getPendingTasks() -> [Task] {
        let tasks = getTasks()
        return tasks.filter({!$0.isCompleted})
    }
    
    
    private func predefinedTestTasks() -> [Task] {
        let t1 = Task(id: "", name: "First", planned: Date())
        let t2 = Task(id: "", name: "Second", planned: Date())
        let t3 = Task(id: "", name: "TestTask", planned: Date())
        
        return [t1, t2, t3]
    }
}
