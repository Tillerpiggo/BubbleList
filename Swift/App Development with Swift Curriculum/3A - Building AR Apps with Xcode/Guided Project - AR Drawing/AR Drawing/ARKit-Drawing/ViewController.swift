import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    var selectedNode: SCNNode?
    
    var placedNodes = [SCNNode]()
    var planeNodes = [SCNNode]()

    @IBOutlet var sceneView: ARSCNView!
    let configuration = ARWorldTrackingConfiguration()
    
    enum ObjectPlacementMode {
        case freeform, plane, image
    }
    
    var objectMode: ObjectPlacementMode = .freeform {
        didSet {
            reloadConfiguration(removeAnchors: false)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        sceneView.autoenablesDefaultLighting = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sceneView.session.run(configuration)
        reloadConfiguration()
    }
    
    func reloadConfiguration(removeAnchors: Bool = true) {
        configuration.planeDetection = .horizontal
        configuration.detectionImages = (objectMode == .image) ? ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) : nil
        
        if objectMode == .plane {
            showPlaneOverlay = true
        } else {
            showPlaneOverlay = false
        }
        
        let options: ARSession.RunOptions
        
        if removeAnchors {
            options = [.removeExistingAnchors]
            for node in planeNodes {
                node.removeFromParentNode()
            }
            planeNodes.removeAll()
            for node in placedNodes {
                node.removeFromParentNode()
            }
            placedNodes.removeAll()
        } else {
            options = []
        }
        
        sceneView.session.run(configuration, options: options)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }

    @IBAction func changeObjectMode(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            objectMode = .freeform
        case 1:
            objectMode = .plane
        case 2:
            objectMode = .image
        default:
            break
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        guard let node = selectedNode, let touch = touches.first else { return }
        
        switch objectMode {
        case .freeform:
            addNodeInFront(node)
        case .plane:
            let touchPoint = touch.location(in: sceneView)
            addNode(node, toPlaneUsingPoint: touchPoint)
        case .image:
            break
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        guard objectMode == .plane, let node = selectedNode, let touch = touches.first,
            let lastTouchPoint = lastObjectPlacedPoint else { return }
        
        let newTouchPoint = touch.location(in: sceneView)
        let distance = distanceFromPoint(newTouchPoint, to: lastTouchPoint)
        
        if distance > touchDistanceThreshold {
            addNode(node, toPlaneUsingPoint: newTouchPoint)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        lastObjectPlacedPoint = nil
    }
    
    func distanceFromPoint(_ touchPoint1: CGPoint, to touchPoint2: CGPoint) -> CGFloat {
        // Use the Pythagorean Formula:
        let distance: CGFloat = sqrt(pow((touchPoint1.x - touchPoint2.x), 2.0) + pow((touchPoint1.y - touchPoint2.y), 2.0))
        
        return distance
    }
    
    func addNodeInFront(_ node: SCNNode) {
        guard let currentFrame = sceneView.session.currentFrame else { return }
        
        // Set the transform of the node to be 20cm in front of the camera
        var translation = matrix_identity_float4x4
        translation.columns.3.z = -0.2
        node.simdTransform = matrix_multiply(currentFrame.camera.transform, translation)
        
        let cloneNode = node.clone()
        sceneView.scene.rootNode.addChildNode(cloneNode)
    }
    
    func addNodeToSceneRoot(_ node: SCNNode) {
        let cloneNode = node.clone()
        sceneView.scene.rootNode.addChildNode(cloneNode)
        placedNodes.append(cloneNode)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if let imageAnchor = anchor as? ARImageAnchor {
            nodeAdded(node, for: imageAnchor)
        } else if let planeAnchor = anchor as? ARPlaneAnchor {
            nodeAdded(node, for: planeAnchor)
        }
    }
    
    var showPlaneOverlay = false {
        didSet {
            for node in planeNodes {
                node.isHidden = !showPlaneOverlay
            }
        }
    }
    
    func nodeAdded(_ node: SCNNode, for anchor: ARPlaneAnchor) {
        let floor = createFloor(planeAnchor: anchor)
        floor.isHidden = !showPlaneOverlay
        
        node.addChildNode(floor)
        planeNodes.append(floor)
    }
    
    func togglePlaneVisualization() {
        dismiss(animated: true, completion: nil)
        showPlaneOverlay = !showPlaneOverlay
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor,
            let planeNode = node.childNodes.first,
            let plane = planeNode.geometry as? SCNPlane
            else { return }
        
        planeNode.position = SCNVector3(planeAnchor.center.x, 0, planeAnchor.center.z)
        plane.width = CGFloat(planeAnchor.extent.x)
        plane.height = CGFloat(planeAnchor.extent.z)
    }
    
    func createFloor(planeAnchor: ARPlaneAnchor) -> SCNNode {
        let node = SCNNode()
        
        let geometry = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        node.geometry = geometry
        
        node.eulerAngles.x = -Float.pi / 2
        node.opacity = 0.25
        
        return node
    }
    
    func nodeAdded(_ node: SCNNode, for anchor: ARImageAnchor) {
        if let selectedNode = selectedNode {
            addNode(selectedNode, toImageUsingParentNode: node)
        }
    }
    
    func addNode(_ node: SCNNode, toImageUsingParentNode parentNode: SCNNode) {
        let cloneNode = node.clone()
        parentNode.addChildNode(cloneNode)
        placedNodes.append(cloneNode)
    }
    
    var lastObjectPlacedPoint: CGPoint?
    let touchDistanceThreshold: CGFloat = 40.0
    
    func addNode(_ node: SCNNode, toPlaneUsingPoint point: CGPoint) {
        let results = sceneView.hitTest(point, types: [.existingPlaneUsingExtent])
        
        if let match = results.first {
            let t = match.worldTransform
            node.position = SCNVector3(x: t.columns.3.x, y: t.columns.3.y, z: t.columns.3.z)
            
            addNodeToSceneRoot(node)
            lastObjectPlacedPoint = point
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showOptions" {
            let optionsViewController = segue.destination as! OptionsContainerViewController
            optionsViewController.delegate = self
        }
    }
}

extension ViewController: OptionsViewControllerDelegate {
    func objectSelected(node: SCNNode) {
        dismiss(animated: true, completion: nil)
        selectedNode = node
    }
    
    func undoLastObject() {
        // Remove the last node places
        if let lastNode = placedNodes.last {
            lastNode.removeFromParentNode()
            placedNodes.removeLast()
        }
    }
    
    func resetScene() {
        dismiss(animated: true, completion: nil)
        reloadConfiguration() // Removes all anchors and nodes
    }
}
