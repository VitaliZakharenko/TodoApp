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
    private var inboxCategory: TaskCategory!
    
    private var dataStorage: DataStorage
    
    
    init(){
        
        dataStorage = FileDataStorage(filename: "AllTasks")
        
        var allCategories = dataStorage.allCategories()
        if allCategories.isEmpty {
            inboxCategory = createCategory(name: Consts.Categories.inboxName)
            categories = predefinedCategories()
            
            dataStorage.add(category: inboxCategory)
            for item in categories {
                dataStorage.add(category: item)
            }
        } else {
            guard let index = allCategories.index(where: {$0.name == Consts.Categories.inboxName }) else {
                fatalError("Inbox category does not exist")
            }
            inboxCategory = allCategories[index]
            allCategories.remove(at: index)
            categories = allCategories
        }
        
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
    
    //MARK: - Tasks
    
    func createTask(name: String, description: String?, remindDate: Date?, priority: Priority = .none) -> Task {
        return Task(id: UUID().uuidString, name: name, description: description, remindDate: remindDate, priority: priority)
    }
    
    func createTask(oldTask: Task, name: String, description: String?, remindDate: Date?, priority: Priority = .none) -> Task {
        return Task(id: oldTask.id, name: name, description: description, remindDate: remindDate, priority: priority)
    }
    
    @discardableResult
    func add(task: Task, category: TaskCategory? = nil) -> TaskCategory? {
        if let category = category {
            for (idx, serviceCategory) in categories.enumerated() {
                if serviceCategory.id == category.id {
                    categories[idx].add(task: task)
                    dataStorage.update(category: categories[idx])
                    return categories[idx]
                }
            }
            return nil
        } else {
            inboxCategory.add(task: task)
            dataStorage.update(category: inboxCategory)
            return inboxCategory
        }
    }
    
    @discardableResult
    func remove(task: Task) -> TaskCategory? {
        inboxCategory.remove(task: task)
        for (idx, _) in categories.enumerated() {
            if(categories[idx].remove(task: task)){
                dataStorage.update(category: categories[idx])
                return categories[idx]
            }
        }
        return nil
    }
    
    
    @discardableResult
    func update(task: Task) -> TaskCategory? {
        inboxCategory.update(task: task)
        for (idx, _) in categories.enumerated(){
            if(categories[idx].update(task: task)){
                dataStorage.update(category: categories[idx])
                return categories[idx]
            }
        }
        return nil
    }
    
    
    //MARK: - Categories
    
    
    func createCategory(name: String) -> TaskCategory {
        return TaskCategory(id: UUID().uuidString, name: name)
    }
    
    
    func add(category: TaskCategory){
        if categories.index(where: { $0.id == category.id }) != nil {
            return
        } else {
            categories.append(category)
            dataStorage.add(category: category)
        }
    }
    
    func update(category: TaskCategory){
        if let index = categories.index(where: { $0.id == category.id }) {
            categories[index] = category
            dataStorage.update(category: category)
        }
    }
    
    func remove(category: TaskCategory){
        if let index = categories.index(where: { $0.id == category.id }) {
            categories.remove(at: index)
            dataStorage.remove(category: category)
        }
    }
    
    
    private func predefinedTestTasks() -> [Task] {
        let t1 = createTask(name: "First", description: nil, remindDate: Date())
        let t2 = createTask(name: "Second", description: nil, remindDate: nil)
        let t3 = createTask(name: "TestTask", description: nil, remindDate: Date(timeIntervalSinceNow: 86400))
        let t4 = createTask(name: "TestTask", description: nil, remindDate: Date(timeIntervalSinceNow: 86400 * 2))
        var t5 = createTask(name: "TestTask", description: nil, remindDate: Date())
        t5.completed = Date()
        let t6 = createTask(name: "TestTask6", description: nil, remindDate: Date())
        let t7 = createTask(name: "TestTask7", description: nil, remindDate: Date())
        
        return [t1, t2, t3, t4, t5, t6, t7]
    }
    
    private func predefinedCategories() -> [TaskCategory] {
        var category1 = createCategory(name: "Work")
        let task1 = createTask(name: "WorkCategoryTask1", description: "Work", remindDate: Date())
        let task2 = createTask(name: "WorkCategoryTask2", description: "WorkTask2", remindDate: nil)
        category1.add(tasks: [task1, task2])
        var category2 = createCategory(name: "Blablabla")
        let blabla1 = createTask(name: "Blabla1", description: nil, remindDate: Date())
        let blabla2 = createTask(name: "Blabla2", description: "Blablabla", remindDate: Date())
        category2.add(tasks: [blabla1, blabla2])
        return [category1, category2]
    }
}
