//
//  ConnectionViewController.swift
//  MagnetHomeworkApp
//
//  Created by Tyler Gee on 2/4/19.
//  Copyright © 2019 Beaglepig. All rights reserved.
//

import UIKit

class ConnectionViewController: UIViewController {
    
    var isConnectionViewHidden: Bool = true
    
    @IBOutlet weak var connectionView: ConnectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureConnectionView()
    }
    
    func hideConnectionView() {
        // make the connection view go down and hide
    }
    
    func showConnectionView() {
        // make the connection view pop up and become visible
    }
    
    func configureConnectionView() {
        // give connection view constraints, set delegates, and add set necessary text
        // also set color of cancelbutton and other setup
        connectionView.configure()
        
        connectionView.setConstraints()
        
        view.addConstraints(connectionView.constraints)
        

//
//        let horizontalTextLabelConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[textLabel]-16-[learnMoreButton]", metrics: nil, views: views)
//        let verticalTextLabelConstraint = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[textLabel]-0-|", metrics: nil, views: views)
//
//        let cancelButtonWidthConstraint = NSLayoutConstraint(item: connectionView.cancelButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1.0, constant: 18)
//        let cancelButtonHeightConstraint = NSLayoutConstraint(item: connectionView.cancelButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 18)
//        let cancelButtonCenterVerticalConstraint = NSLayoutConstraint(item: connectionView.cancelButton, attribute: .centerY, relatedBy: .equal, toItem: connectionView, attribute: .centerY, multiplier: 1.0, constant: 0)
//        let cancelButtonHorizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:[cancelButton]-16-|", metrics: nil, views: views)
//
//        let horizontalLearnMoreButtonConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:[learnMoreButton]-16-[cancelButton]", metrics: nil, views: views)
//        let verticalLearnMoreButtonConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[learnMoreButton]-0-|", metrics: nil, views: views)
//
//
//        connectionView.addConstraints(horizontalTextLabelConstraints)
//        connectionView.addConstraints(verticalTextLabelConstraint)
//
//        connectionView.addConstraints([cancelButtonWidthConstraint, cancelButtonHeightConstraint, cancelButtonCenterVerticalConstraint])
//        connectionView.addConstraints(cancelButtonHorizontalConstraints)
//
//        connectionView.addConstraints(horizontalLearnMoreButtonConstraints)
//        connectionView.addConstraints(verticalLearnMoreButtonConstraints)
        
        
        
        // TODO: Set delegates?
    }
    
}
