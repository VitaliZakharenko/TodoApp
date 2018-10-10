//
//  Task.swift
//  TodoApp
//
//  Created by vitali on 7/31/18.
//  Copyright © 2018 vitcopr. All rights reserved.
//

import Foundation

struct Task {
    
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


extension Task: Codable {
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case remindDate
        case completed
        case priority
    }
    
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(String.self, forKey: .id)
        let name = try container.decode(String.self, forKey: .name)
        let description = try? container.decode(String.self, forKey: .description)
        let remindDate = try? container.decode(Date.self, forKey: .remindDate)
        let completed = try? container.decode(Date.self, forKey: .completed)
        let priority = try container.decode(Priority.self, forKey: .priority)
        self.init(id: id, name: name, description: description, remindDate: remindDate, priority: priority)
        self.completed = completed
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        if let description = self.description {
            try container.encode(description, forKey: .description)
        }
        if let remindDate = self.remindDate {
            try container.encode(remindDate, forKey: .remindDate)
        }
        if let completed = self.completed {
            try container.encode(completed, forKey: .completed)
        }
        try container.encode(priority, forKey: .priority)
    }
    
}

