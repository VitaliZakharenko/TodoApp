//
//  Section.swift
//  TodoApp
//
//  Created by vitali on 8/13/18.
//  Copyright © 2018 vitcopr. All rights reserved.
//

import UIKit

class Section: UIView {

    @IBOutlet weak var contentView: Section!
    @IBOutlet weak var titleLabel: UILabel!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    
    private func commonInit(){
        Bundle.main.loadNibNamed("Section", owner: self, options: nil)
        
        contentView.frame = bounds
        self.addSubview(contentView)
    }
    
    

}
