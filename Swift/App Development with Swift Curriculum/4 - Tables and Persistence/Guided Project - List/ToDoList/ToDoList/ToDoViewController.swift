//
//  ToDoViewController.swift
//  ToDoList
//
//  Created by Tyler Gee on 7/25/18.
//  Copyright © 2018 Tyler Gee. All rights reserved.
//

import UIKit

class ToDoViewController: UITableViewController {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var isCompleteButton: UIButton!
    @IBOutlet weak var dueDateLabel: UILabel!
    @IBOutlet weak var dueDatePickerView: UIDatePicker!
    @IBOutlet weak var notesTextView: UITextView!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var todo: ToDo?
    
    var isPickerHidden = true {
        didSet {
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let todo = todo {
            update(with: todo)
        } else {
            dueDatePickerView.date = Date().addingTimeInterval(24 * 60 * 60)
        }
        updateDueDateLabel(with: dueDatePickerView.date)
        updateSaveButtonState()
        
        isCompleteButton.setImage(UIImage(named: "Unchecked"), for: .normal)
        isCompleteButton.setImage(UIImage(named: "Checked"), for: .selected)
    }
    
    @IBAction func textEditingChanged(_ sender: UITextField) {
        updateSaveButtonState()
    }
    
    @IBAction func returnTapped(_ sender: Any) {
        titleTextField.resignFirstResponder()
    }
    
    @IBAction func isCompleteButtonTapped(_ sender: Any) {
        isCompleteButton.isSelected = !isCompleteButton.isSelected
    }
    
    @IBAction func datePickerChanged(_ sender: UIDatePicker) {
        updateDueDateLabel(with: dueDatePickerView.date)
    }
    
    func updateSaveButtonState() {
        let text = titleTextField.text ?? ""
        saveButton.isEnabled = !text.isEmpty
    }
    
    func updateDueDateLabel(with date: Date) {
        dueDateLabel.text = ToDo.dueDateFormatter.string(from: date)
    }
    
    func update(with todo: ToDo) {
        navigationItem.title = "To-Do"
        titleTextField.text = todo.title
        isCompleteButton.isSelected = todo.isComplete
        dueDatePickerView.date = todo.dueDate
        notesTextView.text = todo.notes
    }
    
    // Table view data source
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let normalCellHeight = CGFloat(44)
        let largeCellHeight = CGFloat(200)
        
        switch indexPath {
        case [1, 1]: // Due Date Cell
            return isPickerHidden ? 0 : largeCellHeight
        case [2, 0]: // Notes Cell
            return largeCellHeight
        default:
            return normalCellHeight
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath {
        case [1, 0]:
            isPickerHidden = !isPickerHidden
            
            dueDateLabel.textColor = isPickerHidden ? .black : tableView.tintColor
        default:
            break
        }
    }
    
    // Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard segue.identifier == "saveUnwind" else { return }
        
        let title = titleTextField.text ?? ""
        let isComplete = isCompleteButton.isSelected
        let dueDate = dueDatePickerView.date
        let notes = notesTextView.text
        
        todo = ToDo(title: title, isComplete: isComplete, dueDate: dueDate, notes: notes)
    }
}
