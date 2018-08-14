//
//  AddTaskSaveDelegate.swift
//  TodoApp
//
//  Created by vitali on 8/9/18.
//  Copyright © 2018 vitcopr. All rights reserved.
//

import Foundation

protocol AddTaskSaveDelegate: AnyObject {
    
    func save(task: Task)
    func update(old: Task, new: Task)
}
