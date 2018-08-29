//
//  Date.swift
//  TodoApp
//
//  Created by vitali on 8/1/18.
//  Copyright © 2018 vitcopr. All rights reserved.
//

import Foundation

extension Date {
    func formattedString(_ format: String = "dd.MM.yyyy" ) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
}


extension String {
    
    func toDate(_ format: String = "dd.MM.yyyy") -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.date(from: self)!
    }
}

