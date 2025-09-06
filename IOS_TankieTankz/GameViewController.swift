//
//  GameViewController.swift
//  IOS_TankieTankz
//
//  Created by Joseph Mark Orimoloye on 4/24/25.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
    // Current game scene reference
    private var gameScene: GameScene?
    
    // Input states
    private var movementTouchActive = false
    private var firingTouchActive = false
    private var movementTouchID: UITouch?
    private var firingTouchID: UITouch?
    
    // Split the screen into zones
    private var movementZone: CGRect = .zero
    private var firingZone: CGRect = .zero

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure the view
        if let view = self.view as! SKView? {
            // Get actual device screen bounds
            let screenBounds = UIScreen.main.bounds
            
            // Create logical scene size based on screen points (not pixels)
            // This ensures consistent gameplay across all iPhone models
            let sceneSize = CGSize(width: screenBounds.width, height: screenBounds.height)
            
            let scene = GameScene(size: sceneSize)
            gameScene = scene
            
            // Use aspectFill to fill the entire screen while maintaining aspect ratio
            scene.scaleMode = .aspectFill
            
            // Present the scene
            view.presentScene(scene)
            
            view.ignoresSiblingOrder = true
            
            // Define control zones (left half for movement, right half for firing)
            // Use screen bounds for consistent touch zones across all devices
            let screenWidth = screenBounds.width
            let screenHeight = screenBounds.height
            movementZone = CGRect(x: 0, y: 0, width: screenWidth / 2, height: screenHeight)
            firingZone = CGRect(x: screenWidth / 2, y: 0, width: screenWidth / 2, height: screenHeight)
            
            #if DEBUG
            view.showsFPS = true
            view.showsNodeCount = true
            #endif
        }
    }
    
    // MARK: - Touch Handling
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let gameScene = gameScene else { return }
        
        for touch in touches {
            let location = touch.location(in: view)
            
            // Check which zone was touched
            if movementZone.contains(location) && !movementTouchActive {
                // Movement touch in left zone
                movementTouchActive = true
                movementTouchID = touch
                gameScene.handlePlayerMovement(to: convertToSceneCoordinates(touch))
            } else if firingZone.contains(location) && !firingTouchActive {
                // Firing touch in right zone
                firingTouchActive = true
                firingTouchID = touch
                gameScene.handlePlayerFiring(at: convertToSceneCoordinates(touch), currentTime: CACurrentMediaTime())
            } else {
                // Pass to scene for UI elements
                gameScene.touchesBegan([touch], with: event)
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let gameScene = gameScene else { return }
        
        for touch in touches {
            // Handle movement updates
            if touch == movementTouchID {
                gameScene.handlePlayerMovement(to: convertToSceneCoordinates(touch))
            }
            
            // Handle continuous firing while moving finger
            if touch == firingTouchID {
                gameScene.handlePlayerFiring(at: convertToSceneCoordinates(touch), currentTime: CACurrentMediaTime())
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let gameScene = gameScene else { return }
        
        for touch in touches {
            // Reset movement touch if this is the active movement touch
            if touch == movementTouchID {
                movementTouchActive = false
                movementTouchID = nil
            }
            
            // Reset firing touch if this is the active firing touch
            if touch == firingTouchID {
                firingTouchActive = false
                firingTouchID = nil
            }
            
            // Pass to scene for UI elements
            gameScene.touchesEnded([touch], with: event)
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Handle the same as touches ended
        touchesEnded(touches, with: event)
    }
    
    // MARK: - Helper Methods
    
    // Convert UIKit coordinates to SpriteKit scene coordinates
    private func convertToSceneCoordinates(_ touch: UITouch) -> CGPoint {
        guard let view = self.view as? SKView, let scene = view.scene else {
            return .zero
        }
        
        let locationInView = touch.location(in: view)
        return scene.convertPoint(fromView: locationInView)
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait // Only allow portrait orientation for this game
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
