//
//  ViewController.swift
//  cameraTutorial
//
//  Created by Tyler Gee on 6/5/18.
//  Copyright © 2018 Tyler Gee. All rights reserved.
//

import UIKit
import AVFoundation
import Foundation

class ViewController: UIViewController {

    @IBOutlet weak var previewView: UIView!
    
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    var capturePhotoOutput: AVCapturePhotoOutput?
    @IBOutlet weak var genderLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // set up pictures taken label
        
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice!)
            captureSession = AVCaptureSession()
            captureSession?.addInput(input)
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            previewView.layer.addSublayer(videoPreviewLayer!)
            captureSession?.startRunning()
        } catch {
            print(error)
        }
        
        // Get an instance of ACCapturePhotoOutput class
        capturePhotoOutput = AVCapturePhotoOutput()
        capturePhotoOutput?.isHighResolutionCaptureEnabled = true // may want to change to false
        
        // Set the output on the capture session
        captureSession?.addOutput(capturePhotoOutput!)
    }

    @IBAction func takePhotoOnTap(_ sender: Any) {
        // Make sure capturePhotoOutput is valid
        guard let capturePhotoOutput = self.capturePhotoOutput else {
            return
        }
        
        //Get an instance of AVCapturePhotoSettings class
        let photoSettings = AVCapturePhotoSettings()
        
        // Set photo settings for our needs
        photoSettings.isAutoStillImageStabilizationEnabled = true
        photoSettings.isHighResolutionPhotoEnabled = true
        photoSettings.flashMode = .auto
        
        // Call capturePhoto method by passing our photo settings and a
        // delegate implementing AVCapturePhotoCaptureDelegate
        capturePhotoOutput.capturePhoto(with: photoSettings, delegate: self as AVCapturePhotoCaptureDelegate)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


extension ViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?) {
        // Let the user know that you are calculating
        genderLabel.text = "Gender: Calculating..."
        
        // Get captured image
        let imageData = photo.fileDataRepresentation()
        
        let capturedImage = UIImage.init(data: imageData!, scale: 1.0)
        
        // use capturedImage to determine a characteristic
        let converter = ImageToArray()
        
        let imageArray = converter.imageToArray(capturedImage!, width: 60, height: 60)
        
        // feed into machine learning
        // . . .
        // based on that, set label
        let randomNumber = arc4random_uniform(2) // 50/50 chance eithe way
        var gender = ""
        if randomNumber == 0 {
            gender = "Male"
        } else {
            gender = "Female"
        }
        
        genderLabel.text = "Gender: \(gender)"
    }
}


