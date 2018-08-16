//
//  Date+Comparison.swift
//  TodoApp
//
//  Created by vitali on 8/16/18.
//  Copyright © 2018 vitcopr. All rights reserved.
//

import Foundation

extension Date {
    
    func compareByDayGranularity(other: Date) -> Bool {
        let order = Calendar.current.compare(self, to: other, toGranularity: .day)
        switch order {
        case .orderedSame:
            return true
        default:
            return false
        }
    }
}
