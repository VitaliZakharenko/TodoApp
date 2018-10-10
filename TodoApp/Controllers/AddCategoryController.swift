//
//  AddCategoryController.swift
//  TodoApp
//
//  Created by vitali on 8/27/18.
//  Copyright © 2018 vitcopr. All rights reserved.
//

import UIKit

class AddCategoryController: UITableViewController {

    
    @IBOutlet weak var categoryNameTextField: UITextField!
    
    
    weak var addCategoryDelegate: AddCategoryDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        categoryNameTextField.delegate = self
        tableView.tableFooterView = UIView()
        setupSaveButton()
    }
    
    
    
    
    //MARK: - UITableViewDelegate and UITableViewDataSource
    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44.0
    }
    
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionView = Section(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 44.0))
        let title = self.tableView(self.tableView, titleForHeaderInSection: section)
        sectionView.titleLabel.text = title?.uppercased()
        return sectionView
    }
    
    
    //MARK: - Private Methods
    
    private func setupSaveButton(){
        let taskName = categoryNameTextField.text ?? ""
        navigationItem.rightBarButtonItem?.isEnabled = !taskName.isEmpty
    }
    
    
    //MARK: - Actions
    
    @IBAction func cancelAddCategory(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func doneAddCategory(_ sender: UIBarButtonItem) {
        guard let name = categoryNameTextField.text else {
            fatalError("Category Name is nil")
        }
        let category = TaskService.shared.createCategory(name: name)
        addCategoryDelegate.add(category: category)
        navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func changedTextInTextField(_ sender: UITextField) {
        setupSaveButton()
    }
    
    
}

//MARK: - UITextFieldDelegate

extension AddCategoryController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        categoryNameTextField.resignFirstResponder()
        setupSaveButton()
        return true
    }
    
    
}
