//
//  ViewController.swift
//  SpacePhoto
//
//  Created by Tyler Gee on 7/26/18.
//  Copyright © 2018 Tyler Gee. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let photoInfoController = PhotoInfoController()
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var titleLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        descriptionTextView.text = ""
        titleLabel.text = ""
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        photoInfoController.fetchPhotoInfo { (photoInfo) in
            if let photoInfo = photoInfo {
                self.updateUI(with: photoInfo)
            }
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
    
    func updateUI(with photoInfo: PhotoInfo) {
        guard let url = photoInfo.url.withHTTPS() else { return }
        
        let task = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.titleLabel.text = photoInfo.title
                    self.imageView.image = image
                    self.descriptionTextView.text = photoInfo.description
                }
            }
        })
        
        task.resume()
    }
}

