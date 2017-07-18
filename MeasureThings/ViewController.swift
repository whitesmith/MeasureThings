//
//  ViewController.swift
//  MeasureThings
//
//  Created by Ricardo Pereira on 18/07/2017.
//  Copyright © 2017 Whitesmith. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!

    private var distanceLabel = UILabel()

    private var startNode: SCNNode?
    private var endNode: SCNNode?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the view's delegate
        sceneView.delegate = self
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.handleTapGesture))
        view.addGestureRecognizer(tapGestureRecognizer)

        distanceLabel.text = "Distance: ?"
        distanceLabel.textColor = .red
        distanceLabel.frame = CGRect(x: 5, y: 5, width: 150, height: 25)
        view.addSubview(distanceLabel)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Create a session configuration
        let configuration = ARWorldTrackingSessionConfiguration()
        configuration.planeDetection = .horizontal
        // Run the view's session
        sceneView.session.run(configuration)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Pause the view's session
        sceneView.session.pause()
    }

    @objc func handleTapGesture(sender: UITapGestureRecognizer) {
        if sender.state != .ended {
            return
        }
        guard let currentFrame = sceneView.session.currentFrame else {
            return
        }

        if let endNode = endNode {
            // Reset
            startNode?.removeFromParentNode()
            self.startNode = nil
            endNode.removeFromParentNode()
            self.endNode = nil
            distanceLabel.text = "Distance: ?"
            return
        }

        // Create a transform with a translation of 0.1 meters (10 cm) in front of the camera
        var translation = matrix_identity_float4x4
        translation.columns.3.z = -0.1
        // Add a node to the session
        let sphere = SCNSphere(radius: 0.005)
        sphere.firstMaterial?.diffuse.contents = UIColor.red
        sphere.firstMaterial?.lightingModel = .constant
        sphere.firstMaterial?.isDoubleSided = true
        let sphereNode = SCNNode(geometry: sphere)
        sphereNode.simdTransform = simd_mul(currentFrame.camera.transform, translation)
        sceneView.scene.rootNode.addChildNode(sphereNode)

        if let startNode = startNode {
            endNode = sphereNode
            self.distanceLabel.text = String(format: "%.2f", distance(startNode: startNode, endNode: sphereNode)) + "m"
        }
        else {
            startNode = sphereNode
        }
    }

    func distance(startNode: SCNNode, endNode: SCNNode) -> Float {
        let vector = SCNVector3Make(startNode.position.x - endNode.position.x, startNode.position.y - endNode.position.y, startNode.position.z - endNode.position.z)
        // Scene units map to meters in ARKit.
        return sqrtf(vector.x * vector.x + vector.y * vector.y + vector.z * vector.z)
    }

}
