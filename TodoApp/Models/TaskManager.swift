//
//  TaskService.swift
//  TodoApp
//
//  Created by vitali on 7/31/18.
//  Copyright © 2018 vitcopr. All rights reserved.
//

import Foundation
import CoreData


fileprivate struct Const {
    
    static let persistentStoreFileName = Consts.CoreData.ModelName + ".sqlite"
    
}

class TaskManager {
    
    
    static var shared: TaskManager!
    
    
    //MARK: CoreData Stack
    
    
    private lazy var managedObjectModel: NSManagedObjectModel = {
        guard let modelURL = Bundle.main.url(forResource: Consts.CoreData.ModelName, withExtension: "momd") else {
            fatalError("Compiled model file not found")
        }
        
        guard let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Unable to read managed object model from specified url: \(modelURL)")
        }
        
        return managedObjectModel
    } ()
    
    
    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        
        let documentDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let persistenStoreUrl = documentDirectoryUrl.appendingPathComponent(Const.persistentStoreFileName)
        
        do {
            try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType,
                                                          configurationName: nil, at: persistenStoreUrl,
                                                          options: nil)
        } catch {
            fatalError(error.localizedDescription)
        }
        return persistentStoreCoordinator
    } ()
    
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        
        managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        
        return managedObjectContext
    } ()
    
    
    
    //MARK: - Properties
    
    private var categories = [TaskCategory]()
    private var inboxCategory: TaskCategory!
    
    
    
    //MARK: - Initialization
    
    init(){
        
        let categoryfetchRequest: NSFetchRequest<TaskCategory> = TaskCategory.fetchRequest()
        managedObjectContext.performAndWait {
            do {
                let categoriesSet = try categoryfetchRequest.execute()

                if categoriesSet.count == 0 {
                    addFirstRunData()
                    try managedObjectContext.save()
                } else {
                    self.categories = categoriesSet
                }
            } catch {
                fatalError("Unable to execute fetch request or save data: \(error.localizedDescription)")
            }
        }
    }
    
    private func addFirstRunData(){
        
        let inboxCategory = createCategory(name: Consts.Categories.inboxName)
        
        let predefinedTasks = predefinedTestTasks()
        inboxCategory.addToTasks(NSSet(array: predefinedTasks))
        managedObjectContext.insert(inboxCategory)
        categories.append(inboxCategory)
        self.inboxCategory = inboxCategory
    }
    
    
    //MARK: - Creation Methods
    
    func createTask(name: String, description: String?, remindDate: Date?, priority: Priority = .none) -> Task {
        let task = Task(context: managedObjectContext)
        task.name = name
        task.taskDescription = description
        task.remindDate = remindDate
        task.priority = priority.rawValue
        return task
    }
    
    
    func createCategory(name: String) -> TaskCategory {
        let category = TaskCategory(context: managedObjectContext)
        category.name = name
        return category
    }
    
    //MARK: - Service Main Methods
    
    func allCategories() -> [TaskCategory]{
        return categories
    }
    
    func completedTasks(category: TaskCategory? = nil) -> [Task] {
        
        let tasks: [Task] = {
            if let category = category {
                return category.tasks!.allObjects as! [Task]
            } else {
                return allTasks()
            }
        } ()
        
        return tasks.filter({ $0.completed != nil })
        
    }
    
    func pendingTasks(category: TaskCategory? = nil) -> [Task] {
        
        let tasks: [Task] = {
            if let category = category {
                return category.tasks!.allObjects as! [Task]
            } else {
                return allTasks()
            }
        } ()
        return tasks.filter({ $0.completed == nil })
    }
    
    
    func tasksBy(predicate: ((Task) -> Bool)) -> [Task] {
        return allTasks().filter(predicate)
    }
    
    func allTasks() -> [Task] {
        var tasks = [Task]()
        for category in categories {
            tasks.append(contentsOf: category.tasks!.allObjects as! [Task])
        }
        return tasks
    }
    
    //MARK: - Tasks
    
    
    func add(task: Task, category: TaskCategory? = nil) {
        if let category = category {
            if let index = categories.index(where: { $0 == category }){
                categories[index].addToTasks(task)
                saveCoreDataChanges()
            } else {
                fatalError("Category not exists")
            }
        } else {
            inboxCategory.addToTasks(task)
            saveCoreDataChanges()
        }
    }
    
    
    func remove(task: Task, from category: TaskCategory? = nil) {
        if let category = category {
            remove(task: task, fromCategory: category)
        }
        else {
            for category in categories {
                remove(task: task, fromCategory: category)
        }
        managedObjectContext.delete(task)
        saveCoreDataChanges()
        }
    }
    
    private func remove(task: Task, fromCategory category: TaskCategory){
        let tasks = category.tasks!.allObjects as! [Task]
        if let index = tasks.index(where: { $0.objectID == task.objectID }){
            category.removeFromTasks(tasks[index])
        }
    }
    
    
    func update(task: Task){
        saveCoreDataChanges()
    }
    
    
    //MARK: - Categories
    
    func add(category: TaskCategory){
        
        if let _ = categories.index(where: { $0 == category }){
            return
        }
        managedObjectContext.insert(category)
        categories.append(category)
        saveCoreDataChanges()
    }
    
    func update(category: TaskCategory){
        saveCoreDataChanges()
    }
    
    func remove(category: TaskCategory){
        if let index = categories.index(where: { $0 == category }){
            categories.remove(at: index)
            managedObjectContext.delete(category)
            saveCoreDataChanges()
        }
    }
    
    //MARK: - Core Data related
    
    private func saveCoreDataChanges(){
        do {
            try managedObjectContext.save()
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    //MARK: - Grouping
    
    
    //MARK: - Methods to create test data
    
    private func predefinedTestTasks() -> [Task] {
        let t1 = createTask(name: "First", description: nil, remindDate: Date())
        let t2 = createTask(name: "Second", description: nil, remindDate: nil)
        let t3 = createTask(name: "TestTask", description: nil, remindDate: Date(timeIntervalSinceNow: 86400))
        let t4 = createTask(name: "TestTask", description: nil, remindDate: Date(timeIntervalSinceNow: 86400 * 2))
        let t5 = createTask(name: "TestTask", description: nil, remindDate: Date())
        t5.completed = Date()
        let t6 = createTask(name: "TestTask6", description: nil, remindDate: Date())
        let t7 = createTask(name: "TestTask7", description: nil, remindDate: Date())
        
        return [t1, t2, t3, t4, t5, t6, t7]
    }
    
    private func predefinedCategories() -> [TaskCategory] {
        let category1 = createCategory(name: "Work")
        let task1 = createTask(name: "WorkCategoryTask1", description: "Work", remindDate: Date())
        let task2 = createTask(name: "WorkCategoryTask2", description: "WorkTask2", remindDate: nil)
        category1.addToTasks([task1, task2])
        let category2 = createCategory(name: "Blablabla")
        let blabla1 = createTask(name: "Blabla1", description: nil, remindDate: Date())
        let blabla2 = createTask(name: "Blabla2", description: "Blablabla", remindDate: Date())
        category2.addToTasks([blabla1, blabla2])
        return [category1, category2]
    }
}


//MARK: - Grouping Tasks
extension TaskManager {
    
    
    func groupedTasks(by sortOrder: InboxSorting) -> ([(String, [Task])], [Task]?) {
        switch sortOrder {
        case .byDate(ascend: _):
            let withReminder = allTasks().filter({ $0.remindDate != nil })
            let withoutReminder = allTasks().filter({ $0.remindDate == nil })
            let withoutGroup = withoutReminder
            let groupedItems = groupByRemindDate(tasksWithReminder: withReminder)
            return (groupedItems, withoutGroup)
        case .byGroup(ascend: _):
            let groupedItems = groupByCategory(categories: allCategories())
            return (groupedItems, nil)
        }
    }
    
    private func group<T, K: Hashable>(items: [(K, T)], by comparator: ((K, K) -> Bool)) -> [K: [T]] {
        var groupedItems: [K: [T]] = [K: [T]]()
        
        for (keyToGroup, item) in items {
            if let index = groupedItems.keys.index(where: { comparator($0, keyToGroup) }) {
                let key = groupedItems.keys[index]
                groupedItems[key]!.append(item)
            } else {
                groupedItems[keyToGroup] = [item]
            }
        }
        return groupedItems
    }
    
    
    private func groupByCategory(categories: [TaskCategory]) -> [(String, [Task])]{
        var items = [(String, Task)]()
        for category in categories {
            let tasks = category.tasks!.allObjects as! [Task]
            for task in tasks {
                let item = (category.name!, task)
                items.append(item)
            }
        }
        return group(items: items, by: { $0 == $1 }).map({ (key, value) in (key, value) })
    }
    
    
    private func groupByRemindDate(tasksWithReminder: [Task]) -> [(String, [Task])] {
        var items = [(Date, Task)]()
        for task in tasksWithReminder {
            let item = (task.remindDate!, task)
            items.append(item)
        }
        
        let grouped = group(items: items, by: { $0.compareByDayGranularity(other: $1)})
        var result = [String: [Task]]()
        for (key, value) in grouped {
            result[key.formattedString()] = value
        }
        return grouped.map({ (key, value) in (key.formattedString(), value)})
    }
    
    
}

