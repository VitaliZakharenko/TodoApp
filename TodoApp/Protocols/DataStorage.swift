//
//  DataStorage.swift
//  TodoApp
//
//  Created by vitali on 8/15/18.
//  Copyright © 2018 vitcopr. All rights reserved.
//

import Foundation

protocol DataStorage {
    
    func save(tasks: [Task])
    func getAllTasks() -> [Task]
    
    func delete(tasks: [Task])
    func update(old: Task, new: Task)
}
