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

  
    private var tasks = [Task]()
    
    
    init(){
        tasks.append(contentsOf: predefinedTestTasks())
    }
    
    func completedTasks() -> [Task] {
        return tasks.filter({ $0.isCompleted })
    }
    
    func pendingTasks() -> [Task] {
        return tasks.filter({ !$0.isCompleted })
    }
    
    func add(task: Task) {
        if tasks.index(where: { $0.id == task.id }) != nil {
            return
        } else {
            tasks.append(task)
        }
    }
    
    func remove(task: Task){
        if let index = tasks.index(where: { $0.id == task.id }){

            tasks.remove(at: index)
        }
    }
    
    func update(task: Task){
        if let index = tasks.index(where: { $0.id == task.id }){
            tasks[index] = task
        }
    }
    
    
    private func predefinedTestTasks() -> [Task] {
        let t1 = Task(id: UUID().uuidString, name: "First", description: nil, remindDate: Date())
        let t2 = Task(id: UUID().uuidString, name: "Second", description: nil, remindDate: Date())
        let t3 = Task(id: UUID().uuidString, name: "TestTask", description: nil, remindDate: Date())
        let t4 = Task(id: UUID().uuidString, name: "TestTask", description: nil, remindDate: Date())
        
        return [t1, t2, t3, t4]
    }
}
