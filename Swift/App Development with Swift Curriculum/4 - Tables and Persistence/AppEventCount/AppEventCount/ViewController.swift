//
//  ViewController.swift
//  AppEventCount
//
//  Created by Tyler Gee on 7/6/18.
//  Copyright © 2018 Tyler Gee. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var didFinishLaunchingLabel: UILabel!
    @IBOutlet weak var willResignActiveLabel: UILabel!
    @IBOutlet weak var didEnterBackgroundLabel: UILabel!
    @IBOutlet weak var willEnterForegroundLabel: UILabel!
    @IBOutlet weak var didBecomeActiveLabel: UILabel!
    @IBOutlet weak var willTerminateLabel: UILabel!
    
    var didFinishLaunchingCount = 0
    var willResignActiveCount = 0
    var didEnterBackgroundCount = 0
    var willEnterForegroundCount = 0
    var didBecomeActiveCount = 0
    var willTerminateCount = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        updateView()
    }
    
    func updateView() {
        didFinishLaunchingLabel.text = "The app has launched \(didFinishLaunchingCount) times(s)."
        willResignActiveLabel.text = "The app has resigned active \(willResignActiveCount) times(s)."
        didEnterBackgroundLabel.text = "The app has entered the background \(didEnterBackgroundCount) times(s)."
        willEnterForegroundLabel.text = "The app has entered the foreground \(willEnterForegroundCount) time(s)."
        didBecomeActiveLabel.text = "The app has become active \(didBecomeActiveCount) time(s)."
        willTerminateLabel.text = "The app has terminated \(willTerminateCount) time(s)."
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

