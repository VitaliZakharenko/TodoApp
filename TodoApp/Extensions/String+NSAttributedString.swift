//
//  String+NSAttributedString.swift
//  TodoApp
//
//  Created by vitali on 8/30/18.
//  Copyright © 2018 vitcopr. All rights reserved.
//

import Foundation

extension String {
    
    func highlight(substring: String?, attributes: [NSAttributedStringKey: Any], caseSensitive: Bool = true) -> NSMutableAttributedString {
        
        let text = NSMutableAttributedString(string: self)
        
        guard let substring = substring else {
            return text
        }
        
        if caseSensitive {
            guard self.contains(substring) else {
                return text
            }
            let range = (self as NSString).range(of: substring)
            text.addAttributes(attributes, range: range)
            return text
        } else {
            guard self.lowercased().contains(substring.lowercased()) else {
                return text
            }
            let range = (self.lowercased() as NSString).range(of: substring.lowercased())
            text.addAttributes(attributes, range: range)
            return text
        }
        
    }
}
