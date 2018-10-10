//
//  DataSource.swift
//  TodoApp
//
//  Created by vitali on 8/30/18.
//  Copyright © 2018 vitcopr. All rights reserved.
//

import Foundation

protocol DataStorage {
    
    func allCategories() -> [TaskCategory]
    
    func add(category: TaskCategory)
    func remove(category: TaskCategory)
    func update(category: TaskCategory)
}
