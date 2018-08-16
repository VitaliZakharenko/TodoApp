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
    var planned: Date
    var completed: Date?
    
    var isCompleted: Bool {
        get {
            return completed != nil
        }
    }
    
    init(id: String, name: String, planned: Date){
        self.id = id
        self.name = name
        self.planned = planned
    }
    
}
