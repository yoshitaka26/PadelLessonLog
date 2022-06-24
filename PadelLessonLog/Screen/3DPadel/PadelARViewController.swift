//
//  PadelARViewController.swift
//  PadelLessonLog
//
//  Created by Yoshitaka Tanaka on 2021/11/24.
//

import UIKit
import SceneKit
import ARKit

final class PadelARViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet private weak var sceneView: ARSCNView!
    @IBOutlet private weak var lowOrHighSlider: UISlider!
    @IBOutlet private weak var ballOrPin: UISegmentedControl!
    
    var padelCourt: SCNNode?
    var detectedPlane: SCNNode?
    var ballArray = [SCNNode]()
    var lineArray = [SCNNode]()
    var pinArray = [SCNNode]()
    
    var drawingNodes = [BallLineGeometryNode]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = createBarButtonItem(image: UIImage.chevronBackwardCircle, select: #selector(back))
        navigationItem.rightBarButtonItem = createBarButtonItem(image: UIImage.arrowClockwiseCircle, select: #selector(refresh))
        
        sceneView.autoenablesDefaultLighting = true
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Run the view's session
        sceneView.session.run()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    @objc
    func back() {
        self.navigationController?.popViewController(animated: true)
    }
    @objc
    func refresh() {
        refreshButtonPressed()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // タップ位置のスクリーン座標を取得
        guard let touch = touches.first else { return }
        let pos = touch.location(in: sceneView)
        
        planeHitTest(pos)
    }
    
    // パデルコートを表示
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if padelCourt == nil {
            guard let planeAnchor = anchor as? ARPlaneAnchor else { fatalError("平面取得ができない") }
            
            planeAnchor.addPlaneNode(on: node, contents: UIColor.clear)
            
            let virtualNode = VirtualObjectNode()
            virtualNode.position = SCNVector3(
                virtualNode.simdWorldPosition.x - 0.38,
                virtualNode.simdWorldPosition.y,
                virtualNode.simdWorldPosition.z + 0.24
                                )
            DispatchQueue.main.async(execute: {
                node.addChildNode(virtualNode)
            })
            padelCourt = virtualNode
        }
    }
    
    private func planeHitTest(_ pos: CGPoint) {
        let results = sceneView.hitTest(pos, types: .existingPlaneUsingExtent)

        // closest hit anchor
        guard let anchor = results.first?.anchor else { return }
        
        // corresponding node
        guard let node = sceneView.node(for: anchor) else { return }
        
        // Search a child node which has a plane geometry
        for child in node.childNodes {
            guard (child.geometry as? SCNPlane) != nil else { return }
            
            guard let an = results.first else { return }
            
            let objectNode = SCNNode()
            
            if ballOrPin.selectedSegmentIndex == 0 {
                let sphare = SCNSphere(radius: 0.007)
                sphare.firstMaterial?.diffuse.contents = UIColor.yellow
                objectNode.geometry = sphare
                
                let hight: Float = lowOrHighSlider.value
                
                objectNode.position = SCNVector3(
                    an.worldTransform.columns.3.x,
                    an.worldTransform.columns.3.y + hight,
                    an.worldTransform.columns.3.z
                )
                
                ballArray.append(objectNode)
                
                let color = UIColor.red.withAlphaComponent(0.6)
                let drawingNode = BallLineGeometryNode(color: color, lineWidth: 0.003)
                sceneView.scene.rootNode.addChildNode(drawingNode)
                drawingNodes.append(drawingNode)
                
            } else {
                let cone = SCNCone(topRadius: 0.002, bottomRadius: 0.008, height: 0.07)
                
                cone.firstMaterial?.diffuse.contents = UIColor.blue
                objectNode.geometry = cone
                objectNode.position = SCNVector3(
                    an.worldTransform.columns.3.x,
                    an.worldTransform.columns.3.y,
                    an.worldTransform.columns.3.z
                )

                pinArray.append(objectNode)
                
                if let lineNode = drawingNodes.first {
                    lineArray.append(lineNode)
                    drawingNodes.removeAll()
                }
            }
            
            sceneView.scene.rootNode.addChildNode(objectNode)
            
            guard let currentDrawing = drawingNodes.first else { return }
            
            DispatchQueue.main.async(execute: {
                let vertice = objectNode.position
                currentDrawing.addVertice(vertice)
            })
            
            break
        }
    }
    
    func refreshButtonPressed() {
        
        if !ballArray.isEmpty {
            for ball in ballArray {
                ball.removeFromParentNode()
            }
        }
        
        if !pinArray.isEmpty {
            for pin in pinArray {
                pin.removeFromParentNode()
            }
        }
        
        lineArray.append(contentsOf: drawingNodes)
        drawingNodes.removeAll()
        
        if !lineArray.isEmpty {
            for line in lineArray {
                line.removeFromParentNode()
            }
        }
    }
}
