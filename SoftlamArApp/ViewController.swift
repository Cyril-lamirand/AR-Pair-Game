//
//  ViewController.swift
//  SoftlamArApp
//
//  Created by Cyril Lamirand on 13/03/2023.
//

import UIKit
import RealityKit
import Combine

class ViewController: UIViewController {
    
    @IBOutlet var arView: ARView!
    
    var count = 0
    
    var tapCard1: Entity? = nil
    var tapCard2: Entity? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /**
            // Load the "Box" scene from the "Experience" Reality File
            //let boxAnchor = try! Experience.loadBox()
            // Add the box anchor to the scene
            //arView.scene.anchors.append(boxAnchor)
            // 1. 3D Model
            let sphere = MeshResource.generateSphere(radius: 0.05)
            let material = SimpleMaterial(color: .green, roughness: 0, isMetallic: true)
            let sphereEntity = ModelEntity(mesh: sphere, materials: [material])

            // 2. Create Anchor
            let sphereAnchor = AnchorEntity(world: SIMD3(x: 0, y: 0, z: 0))
            sphereAnchor.addChild(sphereEntity)

            // 3. Add achor to scene
            arView.scene.addAnchor(sphereAnchor)
        */
        let anchor = AnchorEntity(plane: .horizontal, minimumBounds: [0.2, 0.2])
        arView.scene.addAnchor(anchor);
        
        var cards: [Entity] = []
        
        /** Generate the cards */
        for _ in 1...16 {
            let box = MeshResource.generateBox(width: 0.04, height: 0.002, depth: 0.04)
            let material = SimpleMaterial(color: .gray, isMetallic: true)
            let model = ModelEntity(mesh: box, materials: [material])
            model.generateCollisionShapes(recursive: true)
            cards.append(model)
        }
        
        /** Create the "board" with cards */
        for (index, card) in cards.enumerated() {
            let x = Float(index % 4) - 1.5
            let z = Float(index / 4) - 1.5
            card.position = [x * 0.1, 0, z * 0.1]
            anchor.addChild(card)
        }
        
        /** Invisible box (needed to hide the objects at the beginning) */
        let boxSize: Float = 0.7
        let occlusionBoxMesh = MeshResource.generateBox(size: boxSize)
        let occlusionBox = ModelEntity(mesh: occlusionBoxMesh, materials: [OcclusionMaterial()])
        occlusionBox.position.y = -boxSize / 2
        anchor.addChild(occlusionBox)
        
        var cancellable: AnyCancellable? = nil
        
        cancellable = ModelEntity.loadModelAsync(named: "01")
            .append(ModelEntity.loadModelAsync(named: "02"))
            .append(ModelEntity.loadModelAsync(named: "03"))
            .append(ModelEntity.loadModelAsync(named: "04"))
            .append(ModelEntity.loadModelAsync(named: "05"))
            .append(ModelEntity.loadModelAsync(named: "06"))
            .append(ModelEntity.loadModelAsync(named: "07"))
            .append(ModelEntity.loadModelAsync(named: "08"))
            .collect()
            .sink( receiveCompletion: { error in
                print("Error : \(error)")
                    cancellable?.cancel()
                    
            }, receiveValue: { entities in
                var objects: [ModelEntity] = []
                /** Scalling the objects */
                entities[0].setScale(SIMD3<Float>(0.002, 0.002, 0.002), relativeTo: anchor)
                entities[1].setScale(SIMD3<Float>(0.002, 0.002, 0.002), relativeTo: anchor)
                entities[2].setScale(SIMD3<Float>(0.002, 0.002, 0.002), relativeTo: anchor)
                entities[3].setScale(SIMD3<Float>(0.002, 0.002, 0.002), relativeTo: anchor)
                entities[4].setScale(SIMD3<Float>(0.002, 0.002, 0.002), relativeTo: anchor)
                entities[5].setScale(SIMD3<Float>(0.001, 0.001, 0.001), relativeTo: anchor)
                entities[6].setScale(SIMD3<Float>(0.002, 0.002, 0.002), relativeTo: anchor)
                entities[7].setScale(SIMD3<Float>(0.001, 0.001, 0.001), relativeTo: anchor)
                /** Duplicate the objects */
                for entity in entities {
                    //entity.setScale(SIMD3<Float>(0.002, 0.002, 0.002), relativeTo: anchor)
                    entity.generateCollisionShapes(recursive: true)
                    for _ in 1...2 {
                        objects.append(entity.clone(recursive: true))
                    }
                }
                objects.shuffle()
                
                /** Placing the objects on cards */
                for (index, object) in objects.enumerated() {
                    cards[index].addChild(object)
                    cards[index].transform.rotation = simd_quatf(angle: .pi, axis: [1, 0, 0])
                }
                
                cancellable?.cancel()
            })
        
    }
    
    func returnSelectedCards() {
        if count == 2 {
            
        }
    }
    
    /** Action on tap */
    @IBAction func onTap(_ sender: UITapGestureRecognizer) {
        let tapLocation = sender.location(in: arView)
        if let card = arView.entity(at: tapLocation) {
            /** Rotating the card down (if), rotating the card up (else) */
            if card.transform.rotation.angle == .pi {
                var flipDownTransform = card.transform
                flipDownTransform.rotation = simd_quatf(angle: 0, axis: [1, 0, 0])
                card.move(to: flipDownTransform, relativeTo: card.parent, duration: 0.5, timingFunction: .easeInOut)
                count+=1
                print(count)
            } else {
                var flipUpTransform = card.transform
                flipUpTransform.rotation = simd_quatf(angle: .pi, axis: [1, 0, 0])
                card.move(to: flipUpTransform, relativeTo: card.parent, duration: 0.5, timingFunction: .easeInOut)
                count-=1
                print(count)
            }
        }
    }
}
