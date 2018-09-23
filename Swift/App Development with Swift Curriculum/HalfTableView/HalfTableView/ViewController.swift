//
//  ViewController.swift
//  HalfTableView
//
//  Created by Tyler Gee on 8/11/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var items: [String] = ["This can scroll", "Without the top view scrolling", "Isn't that cool?"]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.text = items[indexPath.row]
        
        return cell
    }
}
