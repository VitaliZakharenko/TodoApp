//
//  SelectDateController.swift
//  TodoApp
//
//  Created by vitali on 8/11/18.
//  Copyright © 2018 vitcopr. All rights reserved.
//

import UIKit

class SelectDateController: UIViewController {
    
    
    //MARK: - Properties
    
    weak var selectDateDelegate: SelectDateDelegate!
    
    @IBOutlet weak var selectedDateLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    private var selectedDate: Date?
    
    
    
    //MARK:- Lifecycle
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavBar()
        let minDate = selectDateDelegate.minimumDate()
        selectedDate = minDate
        let formatter = selectDateDelegate.dateFormatter()
        selectedDateLabel.text = formatter.string(from: minDate)
        datePicker.minimumDate = minDate
        
    }
    
    //MARK: - Private Methods
    
    private func setupNavBar(){
        navigationItem.title = Const.navbarTitle
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: Consts.Text.back, style: .plain, target: self, action: #selector(backButtonClicked(_:)))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: Consts.Text.done, style: .plain, target: self, action: #selector(doneButtonClicked(_:)))
    }
    
    @objc private func backButtonClicked(_ sender: UIBarButtonItem){
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func doneButtonClicked(_ sender: UIBarButtonItem){
        guard let date = selectedDate else {
            fatalError("Selected date is nil")
        }
        selectDateDelegate.dateSelected(date: date)
        navigationController?.popViewController(animated: true)
    }
    
    
    //MARK: - Actions
    
    @IBAction func dateSelected(_ sender: UIDatePicker) {
        selectedDate = sender.date
        let fm = selectDateDelegate.dateFormatter()
        selectedDateLabel.text = fm.string(from: sender.date)
    }
    
}

fileprivate struct Const {
    static let navbarTitle = "Choose Date"
}
