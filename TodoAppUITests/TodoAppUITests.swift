//
//  TodoAppUITests.swift
//  TodoAppUITests
//
//  Created by vitali on 7/31/18.
//  Copyright © 2018 vitcopr. All rights reserved.
//

import XCTest

class TodoAppUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    
        
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    
    func testCreateTaskFromTodayScreenWithDescription(){
        app.launch()
        
        let todayTableView = app.tables[Consts.TodayTaskController.taskListTableView]
        
        let cellCount = todayTableView.cells.count
        
        app.buttons[Consts.TodayTaskController.addTask].tap()
        
        let back = app.buttons[Consts.AddTaskController.back]
        let done = app.buttons[Consts.AddTaskController.done]
        XCTAssertTrue(back.exists)
        XCTAssertTrue(done.exists)
        let taskName = app.textFields[Consts.AddTaskController.taskName]
        let taskDescription = app.textViews[Consts.AddTaskController.taskDescription]
        
        
        taskName.tap()
        taskName.typeText("New Test Task")
        taskName.typeText("\n")
        
        taskDescription.tap()
        taskDescription.typeText("Descr")
        done.tap()
        
        let newCellCount = todayTableView.cells.count
        
        XCTAssertTrue((cellCount + 1) == newCellCount)
        
        app.terminate()
    }
    
    
    func testTapBackWhenAddNewTask(){
        
        app.launch()
        
        let todayTableView = app.tables[Consts.TodayTaskController.taskListTableView]
        let cellCount = todayTableView.cells.count
        app.buttons[Consts.TodayTaskController.addTask].tap()
        XCTAssertTrue(app.tables[Consts.AddTaskController.addTaskTableView].exists)
        app.buttons[Consts.AddTaskController.back].tap()
        XCTAssertTrue(todayTableView.exists)
        let newCellCount = todayTableView.cells.count
        
        XCTAssertTrue(cellCount == newCellCount)
        
        app.terminate()
    }
    
    func testAllScreens() {
        
        app.launch()
        let tapbar = app.tabBars.firstMatch
        let today = tapbar.buttons.element(boundBy: 0)
        let inbox = tapbar.buttons.element(boundBy: 1)
        let todo = tapbar.buttons.element(boundBy: 2)
        let search = tapbar.buttons.element(boundBy: 3)
        
        inbox.tap()
        todo.tap()
        search.tap()
        today.tap()
        app.terminate()
    }
    
}
