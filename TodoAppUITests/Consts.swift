//
//  Consts.swift
//  TodoAppUITests
//
//  Created by vitali on 10/11/18.
//  Copyright © 2018 vitcopr. All rights reserved.
//

import Foundation

struct Consts {
    
    
    struct TodayTaskController {
        static let taskListTableView = "taskListId"
        static let addTask = "addTaskId"
    }
    
    struct AddTaskController {
        static let addTaskTableView = "addTaskTableViewId"
        static let taskName = "taskNameTextFieldId"
        static let remindSwitch = "taskRemindDateSwitchId"
        static let taskPriority = "taskPriorityLabelId"
        static let taskDescription = "taskDescriptionTextViewId"
        static let back = "backId"
        static let done = "doneId"
    }
    
    struct SelectDateController {
    
        
    }
    
    struct InboxTaskController {
        
        
    }
    
    struct AllTasksController {
        
        
    }
    
    struct SearchTaskListController {
        
        
    }
    
    
    struct SharedViews {
        
        struct TaskCell {
            
            static let taskName = "taskNameId"
            static let taskDescription = "taskDescriptionId"
            static let taskRemindDate = "taskRemindDateId"
        }
        
        struct CategoryCell {
            static let categoryName = "categoryNameId"
        }
        
    }
    
}
