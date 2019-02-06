//
//  ConnectionView.swift
//  MagnetHomeworkApp
//
//  Created by Tyler Gee on 2/4/19.
//  Copyright © 2019 Beaglepig. All rights reserved.
//

import UIKit

class ConnectionView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    @IBOutlet weak var cancelButton: UIImageView!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var learnMoreButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configure()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    @IBAction func learnMoreButtonPressed(_ sender: Any) {
        // Show an alert informing the user of stuff...
    }
    
    @IBAction func dismissed(_ sender: Any) { // "X" button was pressed and the connection view should be dismissed
        
    }
    
    func dismiss() {
        // do any necessary visual changes to dismiss the view
    }
    
    func show() {
        // do any necessary visual changes to present the view (animations?)
    }
    
    func configure() {
        self.cancelButton.tintColor = .secondaryTextColor
        self.backgroundColor = .sectionColor
        self.textLabel.textColor = .textColor
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("ConnectionView", owner: self, options: nil)
        addSubview(cancelButton)
        addSubview(textLabel)
        addSubview(learnMoreButton)
    }
}
