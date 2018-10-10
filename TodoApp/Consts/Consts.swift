//
//  Consts.swift
//  TodoApp
//
//  Created by vitali on 8/1/18.
//  Copyright © 2018 vitcopr. All rights reserved.
//

import Foundation

struct Consts {
    struct Identifiers {
        static let taskCell = "TaskCell"
        static let categoryCell = "CategoryCell"
        static let addCategoryCell = "AddCategoryCell"
        static let showAddTaskSegue = "ShowAddTaskSegue"
        static let showAddCategorySegue = "ShowAddCategorySegue"
        static let addTaskController = "AddTaskControllerId"
        static let addCategoryController = "AddCategoryControllerId"
        static let allTasksOfCategoryController = "AllTasksOfCategoryId"
    }
    
    
    struct Text {
        static let done = "Done"
        static let undone = "Undone"
        static let cancel = "Cancel"
        static let delete = "Delete"
        static let back = "Back"
        static let edit = "Edit"
        
        static let noDescriptionText = "No description"
        static let noReminderText = "No reminder"
        
        static let deleteTaskAlertMessage = "Do you want to delete task?"
    }
    
    struct Nibs {
        static let taskCell = "TaskCell"
        static let categoryCell = "CategoryCell"
        static let addCategoryCell = "AddCategoryCell"
    }
    
    struct Storyboards {
        static let main = "Main"
    }
    
    struct Categories {
        static let inboxName = "Inbox"
    }
}
