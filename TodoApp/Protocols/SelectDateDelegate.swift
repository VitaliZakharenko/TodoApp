//
//  SelectDateDelegate.swift
//  TodoApp
//
//  Created by vitali on 8/11/18.
//  Copyright © 2018 vitcopr. All rights reserved.
//

import Foundation

protocol SelectDateDelegate: AnyObject {
    
    // in
    func minimumDate() -> Date
    func dateFormatter() -> DateFormatter
    
    // out
    func dateSelected(date: Date)
}
