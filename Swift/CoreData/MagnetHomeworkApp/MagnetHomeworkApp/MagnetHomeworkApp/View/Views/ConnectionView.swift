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
    
    @IBOutlet weak var cancelImage: UIImageView!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var learnMoreButton: UIButton!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    
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
        dismiss()
    }
    
    func dismiss() {
        // do any necessary visual changes to dismiss the view
        
        let transform = CGAffineTransform(translationX: 0, y: 36)
        
        UIView.animate(withDuration: 0.3, animations: {
            self.setTransform(to: transform)
        })
    }
    
    func show() {
        setTransform(to: CGAffineTransform.identity)
    }
    
    func setTransform(to transform: CGAffineTransform) {
        for view in self.subviews {
            view.transform = transform
        }
    }
    
    func configure() {
        self.cancelImage.tintColor = .secondaryTextColor
        self.backgroundColor = .clear
        self.backgroundView.backgroundColor = .sectionColor
        self.textLabel.textColor = .textColor
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        //setConstraints()
    }
    
    func setConstraints() {
        let views: [String: Any] = ["textLabel": self.textLabel, "learnMoreButton": self.learnMoreButton, "cancelImage": self.cancelImage, "background": self.backgroundView, "cancelButton": self.cancelButton]
        
        let horizontalTextLabelConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[textLabel]-16-[learnMoreButton]", metrics: nil, views: views)
        let verticalTextLabelConstraint = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[textLabel]-0-|", metrics: nil, views: views)
        
        let cancelImageWidthConstraint = NSLayoutConstraint(item: self.cancelImage, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1.0, constant: 18)
        let cancelImageHeightConstraint = NSLayoutConstraint(item: self.cancelImage, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 18)
        let cancelImageCenterVerticalConstraint = NSLayoutConstraint(item: self.cancelImage, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0)
        let cancelImageHorizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:[cancelImage]-16-|", metrics: nil, views: views)
        
        let horizontalLearnMoreButtonConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:[learnMoreButton]-16-[cancelImage]", metrics: nil, views: views)
        let verticalLearnMoreButtonConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[learnMoreButton]-0-|", metrics: nil, views: views)
        
        let cancelButtonVerticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "|-0-[cancelButton]-0-|", metrics: nil, views: views)
        let cancelButtonWidthConstraint = NSLayoutConstraint(item: self.cancelButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1.0, constant: 18)
        let cancelButtonCenterHorizontalConstraint = NSLayoutConstraint(item: self.cancelButton, attribute: .centerX, relatedBy: .equal, toItem: self.cancelImage, attribute: .centerX, multiplier: 1.0, constant: 0)
        
        let backgroundViewHorizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[background]-0-|", metrics: nil, views: views)
        let backgroundViewVerticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[background]-0-|", metrics: nil, views: views)
        
        
        self.addConstraints(horizontalTextLabelConstraints)
        self.addConstraints(verticalTextLabelConstraint)
        
        self.addConstraints([cancelImageWidthConstraint, cancelImageHeightConstraint, cancelImageCenterVerticalConstraint])
        self.addConstraints(cancelImageHorizontalConstraints)
        
        self.addConstraints(horizontalLearnMoreButtonConstraints)
        self.addConstraints(verticalLearnMoreButtonConstraints)
        
        self.addConstraints(backgroundViewHorizontalConstraints)
        self.addConstraints(backgroundViewVerticalConstraints)
        
        //self.addConstraints(cancelButtonVerticalConstraints)
        self.addConstraints([cancelButtonWidthConstraint, cancelButtonCenterHorizontalConstraint])
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("ConnectionView", owner: self, options: nil)
        addSubview(backgroundView)
        addSubview(cancelButton)
        addSubview(textLabel)
        addSubview(learnMoreButton)
        addSubview(cancelImage)
    }
}
