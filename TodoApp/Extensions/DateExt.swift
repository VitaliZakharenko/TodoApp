//
//  Date.swift
//  TodoApp
//
//  Created by vitali on 8/1/18.
//  Copyright © 2018 vitcopr. All rights reserved.
//

import Foundation

extension Date {
    func formattedString(_ foramt: String = "dd.MM.yyyy" ) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = foramt
        return formatter.string(from: self)
    }
}
