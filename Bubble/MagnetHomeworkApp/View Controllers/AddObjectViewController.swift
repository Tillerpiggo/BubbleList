//
//  AddObjectTableViewController.swift
//  MagnetHomeworkApp
//
//  Created by Tyler Gee on 11/25/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//

import UIKit
import Reachability
import CloudKit

class AddObjectViewController: ConnectionViewController, AddObjectViewDelegate, UITextFieldDelegate, UITextDragDelegate, UIScrollViewDelegate {
    
    // MARK: - Variables
    
    @IBOutlet weak var addObjectView: AddObjectView!
    
    var doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(AddObjectViewController.donePressed(sender:)))
    
    // MARK: - ViewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureAddObjectView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if cloudController.reachability.connection == .none {
            addObjectView.layer.zPosition = 1
            connectionView.layer.zPosition = 2
        } else {
            addObjectView.layer.zPosition = 2
            connectionView.layer.zPosition = 1
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)),
                                               name: UIResponder.keyboardDidShowNotification, object: nil)
        
    }
    
    
    func configureAddObjectView() {
        //addObjectView.commonInit()
        addObjectView.configure()
        addObjectView.delegate = self
        addObjectView.textLabel.text = "Add Assignment"
        
        if cloudController.reachability.connection == .none {
            addObjectView.layer.zPosition = 1
            connectionView.layer.zPosition = 2
        } else {
            addObjectView.layer.zPosition = 2
            connectionView.layer.zPosition = 1
        }

        //self.view.addSubview(addObjectView)

        // Add Object View

        addObjectView.translatesAutoresizingMaskIntoConstraints = false

        let views: [String: Any] = ["addObjectView": addObjectView, "contentView": addObjectView.contentView, "view": addObjectView.view, "label": addObjectView.textLabel]

        let horizontalAddObjectViewConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[addObjectView]-0-|", metrics: nil, views: views)
        //let verticalAddObjectViewConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[addObjectView]-40-|", metrics: nil, views: views)

        let horizontalLabelConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-32-[label]-32-|", metrics: nil, views: views)
        let verticalLabelConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[label]-0-|", metrics: nil, views: views)

        let horizontalContentViewConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[contentView]-0-|", metrics: nil, views: views)
        let verticalContentViewConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[contentView]-0-|", metrics: nil, views: views)

        let horizontalViewConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[view]-16-|", metrics: nil, views: views)
        let verticalViewConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-16-[view]-16-|", metrics: nil, views: views)
        
        view.addConstraints(horizontalAddObjectViewConstraints)
        //view.addConstraints(verticalAddObjectViewConstraints)

        addObjectView.addConstraints(horizontalLabelConstraints)
        addObjectView.addConstraints(verticalLabelConstraints)

        addObjectView.addConstraints(horizontalContentViewConstraints)
        addObjectView.addConstraints(verticalContentViewConstraints)

        addObjectView.addConstraints(horizontalViewConstraints)
        addObjectView.addConstraints(verticalViewConstraints)
    
        // Text Field

        addObjectView.textField.delegate = self
        addObjectView.textField.textDragDelegate = self
    }
    
    func doneButtonVisible() -> Bool {
        return self.navigationItem.rightBarButtonItems?.count ?? 0 > 1
    }
    
    func removeDoneButton() {
        self.navigationItem.rightBarButtonItem = nil // subclass should implement
    }
    
    func addDoneButton() {
        
        self.navigationItem.setRightBarButtonItems([doneButton], animated: true) // subclass should implement
    }
    
    @objc func donePressed(sender: UIBarButtonItem) {
        addObjectView.textField.resignFirstResponder()
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if let text = textField.text, text != "" {
            saveObject(text: text)
        }
        
        addObjectView.setToNormal(withDuration: 0.2)
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            self.addObjectView.keyboardHeight = keyboardHeight
            
            //addObjectView.frame.origin.y -= keyboardHeight
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        addObjectView.textField.resignFirstResponder()
    }
    
    func saveObject(text: String) {
        // Must be implemented by subclass
    }
    
    // MARK: - ConnectionDelegate
    
    override func showConnectionView(animated: Bool, completion: ((Bool) -> Void)?) {
        super.showConnectionView(animated: animated, completion: completion)
        
        // Move connectionView above addObjectView
        connectionView.layer.zPosition = 2
        addObjectView.layer.zPosition = 1
    }
    
    override func dismissConnectionView(animated: Bool, completion: ((Bool) -> Void)?) {
        super.dismissConnectionView(animated: animated, completion: completion)
        
        // Move addObjectView above connectionView
        connectionView.layer.zPosition = 1
        addObjectView.layer.zPosition = 2
    }
    
    override func dismissed() {
        super.dismissed()
        
        // Move addObjectView above connectionView
        connectionView.layer.zPosition = 1
        addObjectView.layer.zPosition = 2
    }
    
    // MARK: - AddObjectViewDelegate
    
    func viewSetToNormal() {
        let text = addObjectView.textField.text ?? ""
        if !text.isEmpty {
            saveObject(text: text)
        }
        
        removeDoneButton()
    }
    
    func viewSetToSelected() {
        addDoneButton()
    }
    
    deinit {
        print("DEINIT")
    }
}
