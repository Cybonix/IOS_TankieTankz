//
//  PowerUpManager.swift
//  IOS_TankieTankz
//
//  Created by Joseph Mark Orimoloye on 4/24/25.
//

import SpriteKit

class PowerUpManager {
    // Reference to the game scene
    private weak var gameScene: GameScene?
    
    // Collections of power-ups
    private var availablePowerUps: [PowerUp] = []
    private var activePowerUps: [PowerUp] = []
    private var collectedPowerUps: [PowerUp] = []
    
    // Constants
    private let maxActivePowerUps = 3
    private let maxCollectedPowerUps = 3
    private let boardSize = 3 // Number of levels per "board"
    private let healthThreshold = 85 // Minimum health percentage for power-up
    
    // Notification display
    private var showNotification = false
    private var notificationText = ""
    private var notificationStartTime: TimeInterval = 0
    private let notificationDuration: TimeInterval = 2.0
    
    // Track game progress
    private var boardsCompleted = 0
    private var newBoard = false
    
    // UI elements for HUD
    private var notificationNode: SKNode?
    private var powerUpHudNodes: [SKNode] = []
    
    init(gameScene: GameScene) {
        self.gameScene = gameScene
    }
    
    func update(currentTime: TimeInterval) {
        // Update available power-ups
        var powerUpsToRemove: [PowerUp] = []
        
        for powerUp in availablePowerUps {
            if powerUp.isCollected {
                powerUpsToRemove.append(powerUp)
            }
            
            // Animate power-up
            powerUp.update(currentTime: currentTime)
        }
        
        // Remove collected power-ups
        for powerUp in powerUpsToRemove {
            if let index = availablePowerUps.firstIndex(where: { $0 === powerUp }) {
                availablePowerUps.remove(at: index)
            }
        }
        
        // Update active power-ups
        var activePowerUpsToRemove: [PowerUp] = []
        
        for powerUp in activePowerUps {
            if powerUp.isExpired(currentTime: currentTime) {
                activePowerUpsToRemove.append(powerUp)
            }
        }
        
        // Remove expired power-ups
        for powerUp in activePowerUpsToRemove {
            if let index = activePowerUps.firstIndex(where: { $0 === powerUp }) {
                activePowerUps.remove(at: index)
            }
        }
        
        // Update notification
        if showNotification && currentTime - notificationStartTime > notificationDuration {
            showNotification = false
            notificationNode?.removeFromParent()
            notificationNode = nil
        }
    }
    
    func draw(on scene: SKScene) {
        // This method would be called if we wanted to add power-ups directly to the scene
        // But power-ups should generally be added to the scene when created
    }
    
    func drawHUD(on scene: SKScene, at position: CGPoint, size: CGSize) {
        // Clear previous HUD elements
        for node in powerUpHudNodes {
            node.removeFromParent()
        }
        powerUpHudNodes.removeAll()
        
        // Create container for power-up HUD
        let hudNode = SKNode()
        hudNode.position = position
        hudNode.zPosition = 150 // Above most game elements
        
        // Draw collected power-ups
        for (index, powerUp) in collectedPowerUps.enumerated() {
            let iconNode = createPowerUpHUDIcon(powerUp: powerUp, index: index, isActive: false)
            iconNode.position = CGPoint(x: size.width - 60 - CGFloat(index * 70), y: size.height - 60)
            hudNode.addChild(iconNode)
            powerUpHudNodes.append(iconNode)
        }
        
        // Draw active power-ups with remaining time
        let activeDisplayPowerUps = activePowerUps.filter { $0.type != .extraLife } // Don't show instant power-ups
        for (index, powerUp) in activeDisplayPowerUps.enumerated() {
            let iconNode = createPowerUpHUDIcon(powerUp: powerUp, index: index, isActive: true, currentTime: CACurrentMediaTime())
            iconNode.position = CGPoint(x: size.width / 2 - CGFloat(activeDisplayPowerUps.count * 35) + CGFloat(index * 70), y: 40)
            hudNode.addChild(iconNode)
            powerUpHudNodes.append(iconNode)
        }
        
        scene.addChild(hudNode)
        powerUpHudNodes.append(hudNode)
    }
    
    private func createPowerUpHUDIcon(powerUp: PowerUp, index: Int, isActive: Bool, currentTime: TimeInterval = 0) -> SKNode {
        let iconNode = SKNode()
        let iconSize: CGFloat = 30
        
        // Background circle
        let bgCircle = SKShapeNode(circleOfRadius: iconSize / 2)
        bgCircle.fillColor = getPowerUpColor(powerUp.type)
        bgCircle.strokeColor = .white
        bgCircle.lineWidth = 2.0
        iconNode.addChild(bgCircle)
        
        // Create simplified icon based on power-up type
        switch powerUp.type {
        case .shieldBoost:
            // Cross
            let vLine = SKShapeNode(rectOf: CGSize(width: 2, height: iconSize * 0.6))
            vLine.fillColor = .white
            let hLine = SKShapeNode(rectOf: CGSize(width: iconSize * 0.6, height: 2))
            hLine.fillColor = .white
            iconNode.addChild(vLine)
            iconNode.addChild(hLine)
        case .rapidFire:
            // Lightning bolt
            let boltPath = CGMutablePath()
            boltPath.move(to: CGPoint(x: -iconSize * 0.2, y: -iconSize * 0.2))
            boltPath.addLine(to: CGPoint(x: 0, y: 0))
            boltPath.addLine(to: CGPoint(x: -iconSize * 0.1, y: 0))
            boltPath.addLine(to: CGPoint(x: iconSize * 0.2, y: iconSize * 0.2))
            boltPath.addLine(to: CGPoint(x: 0, y: 0))
            boltPath.addLine(to: CGPoint(x: iconSize * 0.1, y: 0))
            boltPath.closeSubpath()
            
            let bolt = SKShapeNode(path: boltPath)
            bolt.fillColor = .white
            bolt.strokeColor = .white
            iconNode.addChild(bolt)
        case .extraLife:
            // Heart
            let heartPath = CGMutablePath()
            let heartSize = iconSize * 0.3
            
            heartPath.move(to: CGPoint(x: 0, y: heartSize * 0.3))
            heartPath.addCurve(
                to: CGPoint(x: 0, y: -heartSize * 0.7),
                control1: CGPoint(x: -heartSize * 0.8, y: 0),
                control2: CGPoint(x: -heartSize * 0.8, y: -heartSize * 0.4)
            )
            heartPath.addCurve(
                to: CGPoint(x: 0, y: heartSize * 0.3),
                control1: CGPoint(x: heartSize * 0.8, y: -heartSize * 0.4),
                control2: CGPoint(x: heartSize * 0.8, y: 0)
            )
            
            let heart = SKShapeNode(path: heartPath)
            heart.fillColor = .white
            heart.strokeColor = .white
            iconNode.addChild(heart)
        case .damageBoost:
            // Explosion burst
            for i in 0..<8 {
                let angle = Double(i) * Double.pi / 4.0
                let line = SKShapeNode()
                let path = CGMutablePath()
                
                path.move(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(
                    x: cos(angle) * iconSize * 0.3,
                    y: sin(angle) * iconSize * 0.3
                ))
                
                line.path = path
                line.strokeColor = .white
                line.lineWidth = 2.0
                iconNode.addChild(line)
            }
        case .missileAutoFire:
            // Missile
            let missileBody = SKShapeNode(rectOf: CGSize(width: iconSize * 0.2, height: iconSize * 0.4))
            missileBody.fillColor = .white
            missileBody.strokeColor = .white
            iconNode.addChild(missileBody)
            
            // Nose cone
            let nosePath = CGMutablePath()
            nosePath.move(to: CGPoint(x: -iconSize * 0.1, y: -iconSize * 0.2))
            nosePath.addLine(to: CGPoint(x: 0, y: -iconSize * 0.3))
            nosePath.addLine(to: CGPoint(x: iconSize * 0.1, y: -iconSize * 0.2))
            nosePath.closeSubpath()
            
            let nose = SKShapeNode(path: nosePath)
            nose.fillColor = .white
            nose.strokeColor = .white
            iconNode.addChild(nose)
            
            // Fins
            let finPath = CGMutablePath()
            finPath.move(to: CGPoint(x: -iconSize * 0.1, y: iconSize * 0.2))
            finPath.addLine(to: CGPoint(x: -iconSize * 0.2, y: iconSize * 0.3))
            finPath.addLine(to: CGPoint(x: -iconSize * 0.1, y: iconSize * 0.15))
            finPath.closeSubpath()
            
            let leftFin = SKShapeNode(path: finPath)
            leftFin.fillColor = .white
            leftFin.strokeColor = .white
            iconNode.addChild(leftFin)
            
            let rightFinPath = CGMutablePath()
            rightFinPath.move(to: CGPoint(x: iconSize * 0.1, y: iconSize * 0.2))
            rightFinPath.addLine(to: CGPoint(x: iconSize * 0.2, y: iconSize * 0.3))
            rightFinPath.addLine(to: CGPoint(x: iconSize * 0.1, y: iconSize * 0.15))
            rightFinPath.closeSubpath()
            
            let rightFin = SKShapeNode(path: rightFinPath)
            rightFin.fillColor = .white
            rightFin.strokeColor = .white
            iconNode.addChild(rightFin)
        }
        
        // For active power-ups, add timer indicator
        if isActive {
            let remainingTime = powerUp.getRemainingTime(currentTime: currentTime)
            let percentRemaining = remainingTime / powerUp.duration
            
            // Create timer arc around icon
            let timerPath = UIBezierPath(arcCenter: CGPoint.zero,
                                         radius: iconSize / 2 + 5,
                                         startAngle: -CGFloat.pi / 2, // Start from top
                                         endAngle: -CGFloat.pi / 2 + CGFloat(percentRemaining) * CGFloat.pi * 2,
                                         clockwise: true)
            
            let timerNode = SKShapeNode(path: timerPath.cgPath)
            timerNode.strokeColor = .white
            timerNode.lineWidth = 2.0
            timerNode.fillColor = .clear
            iconNode.addChild(timerNode)
            
            // Add time remaining text
            let secondsRemaining = Int(remainingTime)
            let timeLabel = SKLabelNode(fontNamed: "Arial")
            timeLabel.text = "\(secondsRemaining)"
            timeLabel.fontSize = 12
            timeLabel.fontColor = .white
            timeLabel.position = CGPoint(x: 0, y: -iconSize)
            timeLabel.verticalAlignmentMode = .top
            timeLabel.horizontalAlignmentMode = .center
            iconNode.addChild(timeLabel)
            
            // Make icon flash if expiring soon (last 3 seconds)
            if remainingTime < 3.0 {
                let blinkAction = SKAction.sequence([
                    SKAction.fadeAlpha(to: 0.5, duration: 0.25),
                    SKAction.fadeAlpha(to: 1.0, duration: 0.25)
                ])
                let repeatBlink = SKAction.repeatForever(blinkAction)
                iconNode.run(repeatBlink)
            }
        }
        
        // Add name label below
        let powerUpName = getPowerUpShortName(powerUp.type)
        let nameLabel = SKLabelNode(fontNamed: "Arial")
        nameLabel.text = powerUpName
        nameLabel.fontSize = 12
        nameLabel.fontColor = .white
        nameLabel.position = CGPoint(x: 0, y: -iconSize - 5)
        nameLabel.verticalAlignmentMode = .top
        nameLabel.horizontalAlignmentMode = .center
        iconNode.addChild(nameLabel)
        
        return iconNode
    }
    
    private func getPowerUpColor(_ type: PowerUpType) -> SKColor {
        switch type {
        case .shieldBoost:
            return .blue
        case .rapidFire:
            return .yellow
        case .extraLife:
            return .red
        case .damageBoost:
            return SKColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 1.0) // Orange
        case .missileAutoFire:
            return .green
        }
    }
    
    private func getPowerUpShortName(_ type: PowerUpType) -> String {
        switch type {
        case .shieldBoost:
            return "Shield"
        case .rapidFire:
            return "Rapid Fire"
        case .extraLife:
            return "Extra Life"
        case .damageBoost:
            return "DMG Boost"
        case .missileAutoFire:
            return "Missiles"
        }
    }
    
    func checkCollisions(playerX: Int, playerY: Int) {
        // Check collisions with available power-ups
        var powerUpsToRemove: [PowerUp] = []
        
        for powerUp in availablePowerUps {
            if powerUp.checkCollision(playerX: playerX, playerY: playerY) {
                // Collect the power-up if we have room
                if collectedPowerUps.count < maxCollectedPowerUps {
                    powerUp.isCollected = true
                    powerUp.removeFromParent()
                    collectedPowerUps.append(powerUp)
                    gameScene?.playPowerUpCollectSound()
                    showNotification(powerUp.getNotificationText())
                    
                    // For instant power-ups (Extra Life), activate immediately
                    if powerUp.type == .extraLife {
                        activatePowerUp(powerUp)
                    }
                    
                    powerUpsToRemove.append(powerUp)
                }
            }
        }
        
        // Remove collected power-ups from available list
        for powerUp in powerUpsToRemove {
            if let index = availablePowerUps.firstIndex(where: { $0 === powerUp }) {
                availablePowerUps.remove(at: index)
            }
        }
    }
    
    func checkActivations(playerTakingDamage: Bool, playerFiring: Bool) {
        // Process power-up activations based on trigger conditions
        var powerUpToActivate: PowerUp? = nil
        
        for powerUp in collectedPowerUps {
            // Check activation conditions
            let shouldActivate: Bool
            
            switch powerUp.type {
            case .shieldBoost:
                shouldActivate = playerTakingDamage // Activate shield when taking damage
            case .rapidFire, .damageBoost:
                shouldActivate = playerFiring // Activate when firing
            case .missileAutoFire:
                shouldActivate = true // Always activate on collection
            case .extraLife:
                shouldActivate = false // Already activated on collection
            }
            
            if shouldActivate {
                powerUpToActivate = powerUp
                break // Only activate one power-up at a time
            }
        }
        
        // Activate the chosen power-up
        if let powerUp = powerUpToActivate {
            if let index = collectedPowerUps.firstIndex(where: { $0 === powerUp }) {
                collectedPowerUps.remove(at: index)
            }
            activatePowerUp(powerUp)
        }
    }
    
    private func activatePowerUp(_ powerUp: PowerUp) {
        let currentTime = CACurrentMediaTime()
        
        // Set activation time
        powerUp.activationTime = currentTime
        powerUp.isActive = true
        
        // Add to active power-ups list (except Extra Life which is instant)
        if powerUp.type != .extraLife {
            activePowerUps.append(powerUp)
        }
        
        // Apply power-up effect
        switch powerUp.type {
        case .shieldBoost:
            gameScene?.activateShield(duration: powerUp.duration)
            gameScene?.playPowerUpActivationSound()
            showNotification("Shield Boost Activated!")
        case .rapidFire:
            gameScene?.activateRapidFire(duration: powerUp.duration)
            gameScene?.playPowerUpActivationSound()
            showNotification("Rapid Fire Activated!")
        case .extraLife:
            gameScene?.grantExtraLife()
            gameScene?.playPowerUpActivationSound()
            showNotification("Extra Life Acquired!")
        case .damageBoost:
            gameScene?.activateDamageBoost(duration: powerUp.duration)
            gameScene?.playPowerUpActivationSound()
            showNotification("Damage Boost Activated!")
        case .missileAutoFire:
            gameScene?.activateMissileAutoFire(duration: powerUp.duration)
            gameScene?.playPowerUpActivationSound()
            showNotification("Missile Auto-Fire Activated!")
        }
    }
    
    func onLevelComplete(levelNumber: Int, playerHealthPercent: Int) {
        // Check if we've completed a "board" (3 regular levels)
        let isBossLevel = gameScene?.isBossLevel(levelNumber) ?? false
        
        // Boss levels are not considered part of a board
        if levelNumber % boardSize == 0 && !isBossLevel {
            boardsCompleted += 1
            newBoard = true
            
            // If player health meets threshold, grant a power-up
            if playerHealthPercent >= healthThreshold {
                grantRandomPowerUp()
            }
        }
        
        // Always grant a power-up after defeating a boss, regardless of health
        if isBossLevel {
            grantRandomPowerUp()
        }
    }
    
    func onLevelStart(levelNumber: Int) {
        // Check if we should spawn a power-up on the board
        if newBoard {
            newBoard = false
            // No need to spawn power-ups on the battlefield - they're granted directly
        }
    }
    
    private func grantRandomPowerUp() {
        // If player already has max power-ups, don't grant more
        if collectedPowerUps.count >= maxCollectedPowerUps {
            return
        }
        
        // Create a new random power-up
        let randomType = PowerUpType.allCases.randomElement()!
        let powerUp = PowerUp(position: .zero, type: randomType)
        
        // Add to collected (not available on battlefield)
        powerUp.isCollected = true
        collectedPowerUps.append(powerUp)
        
        // Show notification
        showNotification("Power-Up Earned: \(PowerUp.getPowerUpName(randomType))!")
        
        // Play sound
        gameScene?.playPowerUpCollectSound()
        
        // For Extra Life, activate immediately
        if randomType == .extraLife {
            activatePowerUp(powerUp)
        }
    }
    
    private func showNotification(_ text: String) {
        guard let gameScene = gameScene else { return }
        
        // Remove existing notification
        notificationNode?.removeFromParent()
        
        // Create new notification
        let node = SKNode()
        node.zPosition = 200 // Above most game elements
        
        // Message label
        let label = SKLabelNode(fontNamed: "Arial-BoldMT")
        label.text = text
        label.fontSize = ScreenScale.scaleFont(24) // Much smaller, scaled font
        label.fontColor = .white
        label.position = CGPoint(x: gameScene.size.width / 2, y: gameScene.size.height / 2)
        node.addChild(label)
        
        // Shadow for better visibility
        let shadow = SKLabelNode(fontNamed: "Arial-BoldMT")
        shadow.text = text
        shadow.fontSize = ScreenScale.scaleFont(24) // Much smaller, scaled font
        shadow.fontColor = .black
        shadow.position = CGPoint(x: gameScene.size.width / 2 + 2, y: gameScene.size.height / 2 - 2)
        shadow.zPosition = -1 // Behind the main text
        node.addChild(shadow)
        
        // Fade in, hold, fade out animation
        let fadeIn = SKAction.fadeIn(withDuration: 0.3)
        let wait = SKAction.wait(forDuration: 1.4)
        let fadeOut = SKAction.fadeOut(withDuration: 0.3)
        let sequence = SKAction.sequence([fadeIn, wait, fadeOut, SKAction.removeFromParent()])
        node.alpha = 0
        node.run(sequence)
        
        gameScene.addChild(node)
        
        // Store reference and timing information
        notificationNode = node
        notificationText = text
        notificationStartTime = CACurrentMediaTime()
        showNotification = true
    }
    
    func hasActivePowerUp(_ type: PowerUpType) -> Bool {
        return activePowerUps.contains { $0.type == type && $0.isActive }
    }
    
    func reset() {
        // Clear all power-ups
        for powerUp in availablePowerUps {
            powerUp.removeFromParent()
        }
        availablePowerUps.removeAll()
        
        for powerUp in activePowerUps {
            powerUp.removeFromParent()
        }
        activePowerUps.removeAll()
        
        for powerUp in collectedPowerUps {
            powerUp.removeFromParent()
        }
        collectedPowerUps.removeAll()
        
        // Reset tracking variables
        boardsCompleted = 0
        newBoard = false
        showNotification = false
        
        // Remove UI elements
        notificationNode?.removeFromParent()
        notificationNode = nil
        
        for node in powerUpHudNodes {
            node.removeFromParent()
        }
        powerUpHudNodes.removeAll()
    }
    
    func spawnPowerUp(at position: CGPoint, in scene: SKScene) {
        let randomType = PowerUpType.allCases.randomElement()!
        let powerUp = PowerUp(position: position, type: randomType)
        scene.addChild(powerUp)
        availablePowerUps.append(powerUp)
    }
}