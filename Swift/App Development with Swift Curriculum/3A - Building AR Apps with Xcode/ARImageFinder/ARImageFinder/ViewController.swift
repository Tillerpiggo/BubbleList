//
//  ViewController.swift
//  ARImageFinder
//
//  Created by Tyler Gee on 7/5/18.
//  Copyright © 2018 Tyler Gee. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        // let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
        // sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Initialize reference images
        let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil)!
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.detectionImages = referenceImages
        configuration.planeDetection = .horizontal

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        switch anchor {
        case let imageAnchor as ARImageAnchor:
            nodeAdded(node, for: imageAnchor)
        case let planeAnchor as ARPlaneAnchor:
            nodeAdded(node, for: planeAnchor)
        default:
            print("An anchor was discovered, but it is not for planes or images.")
        }
    }
    
    func nodeAdded(_ renderer: SCNNode, for imageAnchor: ARImageAnchor) {
        let referenceImage = imageAnchor.referenceImage
        
        if referenceImage.name == "Magic Keyboard" {
            discoverMagicKeyboard()
        } else if referenceImage.name == "iMac" {
            discoverIMAC()
        }
        
        let plane = SCNPlane(width: referenceImage.physicalSize.width, height: referenceImage.physicalSize.height)
        plane.firstMaterial?.diffuse.contents = UIColor.blue
        let planeNode = SCNNode(geometry: plane)
        planeNode.eulerAngles.x = -Float.pi / 2
        planeNode.opacity = 0.25
        
        renderer.addChildNode(planeNode)
        
        // Make it disappear after 5 seconds
        planeNode.runAction(waitRemoveAction)
    }
    
    func discoverIMAC() {
        // Make iMac related nodes
        print("You found an iMac!") // will likely only work when the 8k mountain background is displayed
    }
    
    func discoverMagicKeyboard() {
        // Make magic keyboard related nodes
        print("You found a magic keyboard!") // will probably only work when keyboard is on gray desk
    }
    
    var waitRemoveAction: SCNAction {
        return .sequence([.wait(duration: 5.0), .fadeOut(duration: 2.0), .removeFromParentNode()])
    }
    
    func nodeAdded(_ node: SCNNode, for planeAnchor: ARPlaneAnchor) {
        // Handle plane detection
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
