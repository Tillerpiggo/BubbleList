//
//  ConnectionView.swift
//  MagnetHomeworkApp
//
//  Created by Tyler Gee on 2/4/19.
//  Copyright © 2019 Beaglepig. All rights reserved.
//

import UIKit

protocol ConnectionViewDelegate {
    func dismissed()
}

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
    
    //var isDismissed: Bool = false
    var delegate: ConnectionViewDelegate?
    
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
        dismiss(completion: nil)
        delegate?.dismissed()
    }
    
    func dismiss(animated: Bool = true, completion: ((Bool) -> Void)?) {
        // do any necessary visual changes to dismiss the view
        
        let durationFactor: TimeInterval = animated ? 1 : 0
        
        let transform = CGAffineTransform(translationX: 0, y: 36)
        
        let animateDismiss: (Bool) -> Void = { (bool) in
            UIView.animate(withDuration: 0.3 * durationFactor, delay: 0.4 * durationFactor, animations: {
                self.setTransform(to: transform)
            }, completion: completion)
        }
        
        animateDismiss(true)
        
        //self.isDismissed = true
    }
    
    func show(animated: Bool = true, completion: ((Bool) -> Void)?) {
        //self.textLabel.text = "You're offline."
        
        let durationFactor: TimeInterval = animated ? 1 : 0
        
        UIView.animate(withDuration: 0.3 * durationFactor, animations: {
            self.setTransform(to: CGAffineTransform.identity)
        }, completion: completion)}
    
    func setConnected(animated: Bool = true, completion: ((Bool) -> Void)?) {
        let durationFactor: TimeInterval = animated ? 1 : 0
        
        UIView.transition(with: textLabel, duration: 0.2 * durationFactor, options: [.transitionCrossDissolve], animations: {
            self.textLabel.text = "Connected!"
        }, completion: completion)
    }
    
    func setOffline(animated: Bool = true, completion: ((Bool) -> Void)?) {
        let durationFactor: TimeInterval = animated ? 1 : 0
        
        UIView.transition(with: textLabel, duration: 0.2 * durationFactor, options: [.transitionCrossDissolve], animations: {
            self.textLabel.text = "You're offline."
        }, completion: completion)
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
        
        // TEMPORARY:
        self.learnMoreButton.isHidden = true
        /////////
        
        //setConstraints()
        dismiss(animated: false, completion: nil)
    }
    
    func setConstraints() {
        let views: [String: Any] = ["textLabel": self.textLabel, "learnMoreButton": self.learnMoreButton, "cancelImage": self.cancelImage, "background": self.backgroundView, "cancelButton": self.cancelButton]
        
        //let horizontalTextLabelConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[textLabel]-16-[learnMoreButton]", metrics: nil, views: views)
        let centerHorizontalLabelConstraint = NSLayoutConstraint(item: self.textLabel, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0)
        let verticalTextLabelConstraint = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[textLabel]-0-|", metrics: nil, views: views)
        
        let cancelImageWidthConstraint = NSLayoutConstraint(item: self.cancelImage, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1.0, constant: 18)
        let cancelImageHeightConstraint = NSLayoutConstraint(item: self.cancelImage, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 18)
        let cancelImageCenterVerticalConstraint = NSLayoutConstraint(item: self.cancelImage, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0)
        let cancelImageHorizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:[cancelImage]-16-|", metrics: nil, views: views)
        
        let horizontalLearnMoreButtonConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:[learnMoreButton]-16-[cancelImage]", metrics: nil, views: views)
        let verticalLearnMoreButtonConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[learnMoreButton]-0-|", metrics: nil, views: views)
        
        let cancelButtonVerticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "|-0-[cancelButton]-0-|", metrics: nil, views: views)
        //let cancelButtonWidthConstraint = NSLayoutConstraint(item: self.cancelButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1.0, constant: 18)
        let cancelButtonCenterHorizontalConstraint = NSLayoutConstraint(item: self.cancelButton, attribute: .centerX, relatedBy: .equal, toItem: self.cancelImage, attribute: .centerX, multiplier: 1.0, constant: 0)
        
        let backgroundViewHorizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[background]-0-|", metrics: nil, views: views)
        let backgroundViewVerticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[background]-0-|", metrics: nil, views: views)
        
        
        self.addConstraint(centerHorizontalLabelConstraint)
        self.addConstraints(verticalTextLabelConstraint)
        
        self.addConstraints([cancelImageWidthConstraint, cancelImageHeightConstraint, cancelImageCenterVerticalConstraint])
        self.addConstraints(cancelImageHorizontalConstraints)
        
        self.addConstraints(horizontalLearnMoreButtonConstraints)
        self.addConstraints(verticalLearnMoreButtonConstraints)
        
        self.addConstraints(backgroundViewHorizontalConstraints)
        self.addConstraints(backgroundViewVerticalConstraints)
        
        //self.addConstraints(cancelButtonVerticalConstraints)
        self.addConstraints([cancelImageWidthConstraint])
        self.addConstraints(cancelButtonVerticalConstraints)
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
