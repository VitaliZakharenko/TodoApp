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
    
    //MARK: - Tests with recorded actions
    //may fall due to changes in task names,
    //title string, etc
    
    func testClicksOnAllScreens(){
        
        app.launch()
        let tabBarsQuery = app.tabBars
        tabBarsQuery.buttons["Inbox"].tap()
        
        let groupButton = app/*@START_MENU_TOKEN@*/.buttons["Group"]/*[[".segmentedControls.buttons[\"Group\"]",".buttons[\"Group\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        groupButton.tap()
        app/*@START_MENU_TOKEN@*/.buttons["Date"]/*[[".segmentedControls.buttons[\"Date\"]",".buttons[\"Date\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        let inboxNavigationBar = app.navigationBars["Inbox"]
        let itemButton = inboxNavigationBar.children(matching: .button).matching(identifier: "Item").element(boundBy: 0)
        itemButton.tap()
        itemButton.tap()
        groupButton.tap()
        itemButton.tap()
        inboxNavigationBar.children(matching: .button).matching(identifier: "Item").element(boundBy: 1).tap()
        app.navigationBars["Add Item"]/*@START_MENU_TOKEN@*/.buttons["backId"]/*[[".buttons[\"Back\"]",".buttons[\"backId\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        tabBarsQuery.buttons["ToDo"].tap()
        
        tabBarsQuery.buttons["Search"].tap()
        
        let completedButton = app/*@START_MENU_TOKEN@*/.buttons["Completed"]/*[[".segmentedControls.buttons[\"Completed\"]",".buttons[\"Completed\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        completedButton.tap()
        
        let activeTasksButton = app/*@START_MENU_TOKEN@*/.buttons["Active Tasks"]/*[[".segmentedControls.buttons[\"Active Tasks\"]",".buttons[\"Active Tasks\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        activeTasksButton.tap()
        
        let searchTasksSearchField = app.searchFields["Search Tasks"]
        searchTasksSearchField.tap()
        searchTasksSearchField.typeText("asdf")
        completedButton.tap()
        activeTasksButton.tap()
        app.buttons["Cancel"].tap()
        
        app.terminate()
        
    }
    
}
