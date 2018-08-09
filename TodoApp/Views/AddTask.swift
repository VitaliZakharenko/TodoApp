//
//  AddTask.swift
//  TodoApp
//
//  Created by vitali on 8/7/18.
//  Copyright © 2018 vitcopr. All rights reserved.
//

import UIKit

class AddTask: UIView {
    
    //MARK: - Properties
    
    
    @IBOutlet weak var contentView: AddTask!
    @IBOutlet weak var taskNameTextField: UITextField!
    @IBOutlet weak var taskDescriptionTextView: UITextView!
    @IBOutlet weak var selectDateButton: UIButton!
    
    //MARK: - Initializations
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit(){
        Bundle.main.loadNibNamed("AddTask", owner: self, options: nil)
        
        contentView.frame = bounds
        self.addSubview(contentView)
        
        let currentDate = Date()
        selectDateButton.setTitle(currentDate.formattedString(), for: .normal)
    }
    
    
}
