//
//  TaskService.swift
//  TodoApp
//
//  Created by vitali on 7/31/18.
//  Copyright © 2018 vitcopr. All rights reserved.
//

import Foundation

class TaskService {
    
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
        return tasks
    }
}
