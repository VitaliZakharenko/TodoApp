//
//  Task.swift
//  TodoApp
//
//  Created by vitali on 7/31/18.
//  Copyright © 2018 vitcopr. All rights reserved.
//

import Foundation

struct Task {
    
    // not used yet, empty string
    let id: String
    var name: String
    var description: String?
    var remindDate: Date?
    var completed: Date?
    
    var priority: Priority
    
    var isCompleted: Bool {
        get {
            return completed != nil
        }
    }
    
    var isReminded: Bool {
        get {
            return remindDate != nil
        }
    }
    
    init(id: String, name: String, description: String?, remindDate: Date?, priority: Priority = .none){
        self.id = id
        self.name = name
        self.description = description
        self.remindDate = remindDate
        self.priority = priority
    }
    

}
