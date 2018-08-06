//
//  TaskList.swift
//  TodoApp
//
//  Created by vitali on 7/31/18.
//  Copyright © 2018 vitcopr. All rights reserved.
//

import Foundation

class TaskCategory {
    
    let id: String
    var name: String
    private var tasks: [Task]
    
    
    init(id: String, name: String){
        self.id = id
        self.name = name
        tasks = [Task]()
    }
    
    func add(task: Task){
        if !tasks.contains(where: {$0.name == task.name}){
            tasks.append(task)
        }
    }
    
    func add(tasks: [Task]){
        for task in tasks {
            add(task: task)
        }
    }
    
    func remove(task: Task){
        if let index = tasks.index(where: {$0.name == task.name}){
            tasks.remove(at: index)
        }
    }
    
    func getTasks() -> [Task] {
        return tasks
    }
    
}
