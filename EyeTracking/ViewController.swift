//
//  ViewController.swift
//  EyeTracking
//
//  Created by Vuk Radosavljevic on 12/18/18.
//  Copyright © 2018 Vuk Radosavljevic. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController {

    
    
    // MARK: - Properties
    var session: ARSession {
        return sceneView.session
    }
    
    //Will hold the ARFaceAnchor - which has information about the pose, topology, and expression of a face detected in a face-tracking AR session.
    var faceNode: SCNNode?
    
    //The virtual phone
    var virtualPhoneNode: SCNNode?
    
    //iPhone xs max point size
    let phoneScreenPointSize = CGSize(width: 414, height: 896)
    // MARK: - Outlets
    @IBOutlet var sceneView: ARSCNView!
    
    @IBOutlet weak var eyeTracker: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    
    // MARK: - Methods
    
    
    // MARK: - Actions
    
    
    
    // MARK: - View Management
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScence()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        UIApplication.shared.isIdleTimerDisabled = false
        sceneView.session.pause()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //Prevents the device from going to sleep
        UIApplication.shared.isIdleTimerDisabled = true
        resetTracking()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}



// MARK: - ARSCNViewDelegate
extension ViewController: ARSCNViewDelegate {
    // Tag: SceneKit Renderer
    
    // Tag: ARNodeTracking
    
    //Called every time an anchor is added to the scene
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        faceNode = node
    }
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard let device = sceneView.device else {
            return nil
        }
        
        let faceGeometry = ARSCNFaceGeometry(device: device)
        
        let node = SCNNode(geometry: faceGeometry)
        
        node.geometry?.firstMaterial?.fillMode = .lines
        
        return node
    }
    // Tag: ARFaceGeometryUpdate
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let faceAnchor = anchor as? ARFaceAnchor,
            let faceGeometry = node.geometry as? ARSCNFaceGeometry else {
                return
        }
        DispatchQueue.main.async {
            let yTransform = (-(faceAnchor.lookAtPoint.y / 0.2) * 896)
//            let xTransform = ((faceAnchor.lookAtPoint.x / 0.2) * 414)
//            CGFloat(xTransform)
            if yTransform > -438 && yTransform < 390 {
                self.eyeTracker.transform = CGAffineTransform(translationX: 0, y: CGFloat(yTransform))
            }
            
            self.updateMessage(text: "X: \(faceAnchor.lookAtPoint.x) d Y: \(faceAnchor.lookAtPoint.y)")
        }
        
        faceGeometry.update(from: faceAnchor.geometry)
    }
    // Tag: ARSession Handling
    func session(_ session: ARSession, didFailWithError error: Error) {
        print("** didFailWithError")
        updateMessage(text: "Session failed.")
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        print("** sessionWasInterrupted")
        updateMessage(text: "Session interrupted.")
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        print("** sessionInterruptionEnded")
        updateMessage(text: "Session interruption ended.")
    }
    
}


// MARK: - Private Methods

private extension ViewController {
    
    // Tag: SceneKit Setup
    func setupScence() {
        //Sets the views delegate to self
        sceneView.delegate = self
        //Shows statistics such as fps and timing information
        sceneView.showsStatistics = true
        
    }
    // Tag: ARFaceTrackingConfiguration
    func resetTracking() {
        guard ARFaceTrackingConfiguration.isSupported else {
            updateMessage(text: "Face Tracking Not Supported")
            return
        }
        updateMessage(text: "Looking for a face")
        let configuration = ARFaceTrackingConfiguration()
        
        //Default Settings
        configuration.isLightEstimationEnabled = true
        configuration.providesAudioData = false
        
        //Resets the tracking and removes any exisiting anchors anytime the session is started
        session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    // Tag: CreateARSCNFaceGeometry
    
    // Tag: Setup Face Content Nodes
    
    // Tag: Update UI
    func updateMessage(text: String) {
        DispatchQueue.main.async {
            self.messageLabel.text = text
        }
    }
    
}
