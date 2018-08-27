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
    private var inboxCategory: TaskCategory = TaskCategory(id: UUID().uuidString, name: Consts.Categories.inboxName)
    
    
    init(){
        inboxCategory.add(tasks: predefinedTestTasks())
        categories.append(contentsOf: predefinedCategories())
    }
    
    func allCategories() -> [TaskCategory]{
        var all = categories
        all.append(inboxCategory)
        return all
    }
    
    func completedTasks() -> [Task] {
        var tasks = [Task]()
        tasks.append(contentsOf: inboxCategory.completedTasks())
        for category in categories {
            tasks.append(contentsOf: category.completedTasks())
        }
        return tasks
    }
    
    func pendingTasks() -> [Task] {
        var tasks = [Task]()
        tasks.append(contentsOf: inboxCategory.pendingTasks())
        for category in categories {
            tasks.append(contentsOf: category.pendingTasks())
        }
        return tasks
    }
    
    func tasksBy(predicate: ((Task) -> Bool)) -> [Task] {
        return allTasks().filter(predicate)
    }
    
    func allTasks() -> [Task] {
        var tasks = [Task]()
        tasks.append(contentsOf: inboxCategory.allTasks())
        for category in categories {
            tasks.append(contentsOf: category.allTasks())
        }
        return tasks
    }
    
    func add(task: Task, category: TaskCategory? = nil) {
        if let category = category {
            for (idx, serviceCategory) in categories.enumerated() {
                if serviceCategory.id == category.id {
                    categories[idx].add(task: task)
                }
            }
        } else {
            inboxCategory.add(task: task)
        }
    }
    
    func remove(task: Task){
        inboxCategory.remove(task: task)
        for (idx, _) in categories.enumerated() {
            categories[idx].remove(task: task)
        }
    }
    
    func update(task: Task){
        inboxCategory.update(task: task)
        for (idx, _) in categories.enumerated(){
            categories[idx].update(task: task)
        }
    }
    
    
    func add(category: TaskCategory){
        if categories.index(where: { $0.id == category.id }) != nil {
            return
        } else {
            categories.append(category)
        }
    }
    
    func update(category: TaskCategory){
        if let index = categories.index(where: { $0.id == category.id }) {
            categories[index] = category
        }
    }
    
    func remove(category: TaskCategory){
        if let index = categories.index(where: { $0.id == category.id }) {
            categories.remove(at: index)
        }
    }
    
    
    private func predefinedTestTasks() -> [Task] {
        let t1 = Task(id: UUID().uuidString, name: "First", description: nil, remindDate: Date())
        let t2 = Task(id: UUID().uuidString, name: "Second", description: nil, remindDate: nil)
        let t3 = Task(id: UUID().uuidString, name: "TestTask", description: nil, remindDate: Date(timeIntervalSinceNow: 86400))
        let t4 = Task(id: UUID().uuidString, name: "TestTask", description: nil, remindDate: Date(timeIntervalSinceNow: 86400 * 2))
        var t5 = Task(id: UUID().uuidString, name: "TestTask", description: nil, remindDate: Date())
        t5.completed = Date()
        let t6 = Task(id: UUID().uuidString, name: "TestTask6", description: nil, remindDate: Date())
        let t7 = Task(id: UUID().uuidString, name: "TestTask7", description: nil, remindDate: Date())
        
        return [t1, t2, t3, t4, t5, t6, t7]
    }
    
    private func predefinedCategories() -> [TaskCategory] {
        var category1 = TaskCategory(id: UUID().uuidString, name: "Work")
        let task1 = Task(id: UUID().uuidString, name: "WorkCategoryTask1", description: "Work", remindDate: Date())
        let task2 = Task(id: UUID().uuidString, name: "WorkCategoryTask2", description: "WorkTask2", remindDate: nil)
        category1.add(tasks: [task1, task2])
        var category2 = TaskCategory(id: UUID().uuidString, name: "Blablabla")
        let blabla1 = Task(id: UUID().uuidString, name: "Blabla1", description: nil, remindDate: Date())
        let blabla2 = Task(id: UUID().uuidString, name: "Blabla2", description: "Blablabla", remindDate: Date())
        category2.add(tasks: [blabla1, blabla2])
        return [category1, category2]
    }
}
