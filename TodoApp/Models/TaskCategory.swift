//
//  TaskList.swift
//  TodoApp
//
//  Created by vitali on 7/31/18.
//  Copyright © 2018 vitcopr. All rights reserved.
//

import Foundation

struct TaskCategory {
    
    let id: String
    var name: String
    private var tasks = [Task]()
    
    
    init(id: String, name: String){
        self.id = id
        self.name = name
    }
    
    func completedTasks() -> [Task] {
        return tasks.filter({ $0.isCompleted })
    }
    
    func pendingTasks() -> [Task] {
        return tasks.filter({ !$0.isCompleted })
    }
    
    func tasksBy(predicate: ((Task) -> Bool)) -> [Task] {
        return tasks.filter(predicate)
    }
    
    func allTasks() -> [Task] {
        return tasks
    }
    
    mutating func add(task: Task){
        if !tasks.contains(where: {$0.id == task.id}){
            tasks.append(task)
        }
    }
    
    mutating func add(tasks: [Task]){
        for task in tasks {
            add(task: task)
        }
    }
    
    
    mutating func remove(task: Task){
        if let index = tasks.index(where: {$0.id == task.id}){
            tasks.remove(at: index)
        }
    }
    
    mutating func update(task: Task){
        if let index = tasks.index(where: { $0.id == task.id }){
            tasks[index] = task
        }
    }
    
}
