//
//  PowerUp.swift
//  IOS_TankieTankz
//
//  Created by Joseph Mark Orimoloye on 4/24/25.
//

import SpriteKit
import Foundation

enum PowerUpType: Int, CaseIterable {
    case shieldBoost
    case rapidFire
    case extraLife
    case damageBoost
    case missileAutoFire
}

class PowerUp: SKNode {
    let type: PowerUpType
    private let size: CGFloat = 40.0
    private var animationFrame: Int = 0
    private let maxAnimationFrames: Int = 60
    private var glowAlpha: Int = 0
    
    // Status
    var isActive: Bool = false
    var isCollected: Bool = false
    var activationTime: TimeInterval = 0
    
    // Duration in seconds
    var duration: TimeInterval {
        switch type {
        case .shieldBoost:
            return 5.0
        case .rapidFire, .damageBoost, .missileAutoFire:
            return 10.0
        case .extraLife:
            return 0.0 // Instant effect
        }
    }
    
    // Power-up visuals
    private var iconNode: SKNode!
    private var glowNode: SKEffectNode!
    
    init(position: CGPoint, type: PowerUpType) {
        self.type = type
        
        super.init()
        self.position = position
        
        setupPowerUpVisuals()
        setupPhysicsBody()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupPowerUpVisuals() {
        // Create the container for all power-up visuals
        iconNode = SKNode()
        addChild(iconNode)
        
        // Add glow effect
        setupGlowEffect()
        
        // Draw power-up icon based on type
        drawPowerUpIcon()
    }
    
    private func setupGlowEffect() {
        // Create an effect node for glow
        glowNode = SKEffectNode()
        glowNode.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius": 10])
        glowNode.shouldRasterize = true
        
        // Add a circle shape for the glow
        let glowRadius: CGFloat = size / 2 + 10
        let glowCircle = SKShapeNode(circleOfRadius: glowRadius)
        glowCircle.fillColor = getTypeColor()
        glowCircle.strokeColor = .clear
        glowCircle.alpha = 0.6
        glowNode.addChild(glowCircle)
        
        // Add glow behind other elements
        insertChild(glowNode, at: 0)
    }
    
    private func getTypeColor() -> SKColor {
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
    
    private func drawPowerUpIcon() {
        // Base circle for the power-up
        let baseCircle = SKShapeNode(circleOfRadius: size / 2)
        baseCircle.fillColor = getTypeColor()
        baseCircle.strokeColor = .white
        baseCircle.lineWidth = 2.0
        iconNode.addChild(baseCircle)
        
        // Draw specific icon based on power-up type
        switch type {
        case .shieldBoost:
            drawShieldIcon()
        case .rapidFire:
            drawRapidFireIcon()
        case .extraLife:
            drawExtraLifeIcon()
        case .damageBoost:
            drawDamageBoostIcon()
        case .missileAutoFire:
            drawMissileIcon()
        }
    }
    
    private func drawShieldIcon() {
        // Cross inside shield
        let crossNode = SKNode()
        
        // Horizontal line
        let hLine = SKShapeNode(rectOf: CGSize(width: size * 0.5, height: size * 0.1))
        hLine.fillColor = .white
        hLine.strokeColor = .white
        crossNode.addChild(hLine)
        
        // Vertical line
        let vLine = SKShapeNode(rectOf: CGSize(width: size * 0.1, height: size * 0.5))
        vLine.fillColor = .white
        vLine.strokeColor = .white
        crossNode.addChild(vLine)
        
        iconNode.addChild(crossNode)
    }
    
    private func drawRapidFireIcon() {
        // Gun icon
        let gunNode = SKNode()
        
        // Gun body
        let gunRect = SKShapeNode(rectOf: CGSize(width: size * 0.5, height: size * 0.3))
        gunRect.fillColor = .white
        gunRect.strokeColor = .white
        gunRect.position = CGPoint(x: -size * 0.1, y: 0)
        gunNode.addChild(gunRect)
        
        // Gun barrel
        let barrelRect = SKShapeNode(rectOf: CGSize(width: size * 0.3, height: size * 0.1))
        barrelRect.fillColor = .white
        barrelRect.strokeColor = .white
        barrelRect.position = CGPoint(x: size * 0.15, y: 0)
        gunNode.addChild(barrelRect)
        
        // Bullets/lines coming out
        for i in 0..<3 {
            let lineX = size * 0.3 + CGFloat(i) * size * 0.1
            let line = SKShapeNode(rectOf: CGSize(width: size * 0.07, height: size * 0.03))
            line.fillColor = .yellow
            line.strokeColor = .yellow
            line.position = CGPoint(x: lineX, y: 0)
            gunNode.addChild(line)
        }
        
        iconNode.addChild(gunNode)
    }
    
    private func drawExtraLifeIcon() {
        // Heart shape
        let heartPath = CGMutablePath()
        let centerX: CGFloat = 0
        let centerY: CGFloat = 0
        let heartSize: CGFloat = size * 0.4
        
        // Top left curve
        heartPath.move(to: CGPoint(x: centerX, y: centerY + heartSize * 0.5))
        heartPath.addCurve(
            to: CGPoint(x: centerX, y: centerY - heartSize),
            control1: CGPoint(x: centerX - heartSize, y: centerY),
            control2: CGPoint(x: centerX - heartSize, y: centerY - heartSize * 0.5)
        )
        
        // Top right curve
        heartPath.addCurve(
            to: CGPoint(x: centerX, y: centerY + heartSize * 0.5),
            control1: CGPoint(x: centerX + heartSize, y: centerY - heartSize * 0.5),
            control2: CGPoint(x: centerX + heartSize, y: centerY)
        )
        
        let heartShape = SKShapeNode(path: heartPath)
        heartShape.fillColor = .white
        heartShape.strokeColor = .white
        
        iconNode.addChild(heartShape)
    }
    
    private func drawDamageBoostIcon() {
        // Bullet with damage indicator
        let bulletNode = SKNode()
        
        // Main bullet
        let bullet = SKShapeNode(circleOfRadius: size * 0.25)
        bullet.fillColor = .white
        bullet.strokeColor = .white
        bulletNode.addChild(bullet)
        
        // Power lines radiating out
        let numLines = 8
        for i in 0..<numLines {
            let angle = Double(i) * Double.pi * 2 / Double(numLines)
            let startRadius = size * 0.25
            let endRadius = size * 0.35
            
            let startX = cos(angle) * startRadius
            let startY = sin(angle) * startRadius
            let endX = cos(angle) * endRadius
            let endY = sin(angle) * endRadius
            
            let line = SKShapeNode()
            let path = CGMutablePath()
            path.move(to: CGPoint(x: startX, y: startY))
            path.addLine(to: CGPoint(x: endX, y: endY))
            line.path = path
            line.strokeColor = .yellow
            line.lineWidth = 3.0
            
            bulletNode.addChild(line)
        }
        
        iconNode.addChild(bulletNode)
    }
    
    private func drawMissileIcon() {
        // Missile with target
        let missileNode = SKNode()
        
        // Missile body
        let missileRect = SKShapeNode(rectOf: CGSize(width: size * 0.3, height: size * 0.5))
        missileRect.fillColor = .white
        missileRect.strokeColor = .white
        missileNode.addChild(missileRect)
        
        // Missile nose cone
        let conePath = CGMutablePath()
        conePath.move(to: CGPoint(x: -size * 0.15, y: -size * 0.25))
        conePath.addLine(to: CGPoint(x: 0, y: -size * 0.35))
        conePath.addLine(to: CGPoint(x: size * 0.15, y: -size * 0.25))
        conePath.closeSubpath()
        
        let cone = SKShapeNode(path: conePath)
        cone.fillColor = .white
        cone.strokeColor = .white
        missileNode.addChild(cone)
        
        // Missile fins
        let leftFinPath = CGMutablePath()
        leftFinPath.move(to: CGPoint(x: -size * 0.15, y: size * 0.25))
        leftFinPath.addLine(to: CGPoint(x: -size * 0.25, y: size * 0.35))
        leftFinPath.addLine(to: CGPoint(x: -size * 0.15, y: size * 0.15))
        leftFinPath.closeSubpath()
        
        let leftFin = SKShapeNode(path: leftFinPath)
        leftFin.fillColor = .white
        leftFin.strokeColor = .white
        missileNode.addChild(leftFin)
        
        let rightFinPath = CGMutablePath()
        rightFinPath.move(to: CGPoint(x: size * 0.15, y: size * 0.25))
        rightFinPath.addLine(to: CGPoint(x: size * 0.25, y: size * 0.35))
        rightFinPath.addLine(to: CGPoint(x: size * 0.15, y: size * 0.15))
        rightFinPath.closeSubpath()
        
        let rightFin = SKShapeNode(path: rightFinPath)
        rightFin.fillColor = .white
        rightFin.strokeColor = .white
        missileNode.addChild(rightFin)
        
        // Target reticle behind the missile
        let reticle = SKShapeNode(circleOfRadius: size * 0.4)
        reticle.strokeColor = .white
        reticle.lineWidth = 2.0
        reticle.fillColor = .clear
        reticle.zPosition = -1
        
        // Crosshairs
        let hLine = SKShapeNode()
        let hPath = CGMutablePath()
        hPath.move(to: CGPoint(x: -size * 0.4, y: 0))
        hPath.addLine(to: CGPoint(x: size * 0.4, y: 0))
        hLine.path = hPath
        hLine.strokeColor = .white
        hLine.lineWidth = 1.0
        reticle.addChild(hLine)
        
        let vLine = SKShapeNode()
        let vPath = CGMutablePath()
        vPath.move(to: CGPoint(x: 0, y: -size * 0.4))
        vPath.addLine(to: CGPoint(x: 0, y: size * 0.4))
        vLine.path = vPath
        vLine.strokeColor = .white
        vLine.lineWidth = 1.0
        reticle.addChild(vLine)
        
        iconNode.addChild(reticle)
        iconNode.addChild(missileNode)
        
        // Add rotation animation to reticle
        let rotateAction = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 4.0)
        let repeatAction = SKAction.repeatForever(rotateAction)
        reticle.run(repeatAction)
    }
    
    private func setupPhysicsBody() {
        physicsBody = SKPhysicsBody(circleOfRadius: size / 2)
        physicsBody?.isDynamic = false
        physicsBody?.categoryBitMask = PhysicsCategory.powerUp
        physicsBody?.contactTestBitMask = PhysicsCategory.playerTank
        physicsBody?.collisionBitMask = PhysicsCategory.none
    }
    
    func update(currentTime: TimeInterval) {
        // Update animation
        animationFrame = (animationFrame + 1) % maxAnimationFrames
        
        // Pulse the glow
        let pulseValue = abs(sin(Double(animationFrame) * Double.pi / 30.0))
        glowNode.alpha = CGFloat(pulseValue * 0.7 + 0.3) // Range 0.3 to 1.0
    }
    
    func checkCollision(playerX: Int, playerY: Int, playerSize: Int = 50) -> Bool {
        if isCollected { return false }
        
        let powerUpRect = CGRect(
            x: position.x - size / 2,
            y: position.y - size / 2,
            width: size,
            height: size
        )
        
        let playerRect = CGRect(
            x: CGFloat(playerX) - CGFloat(playerSize) / 2,
            y: CGFloat(playerY) - CGFloat(playerSize) / 2,
            width: CGFloat(playerSize),
            height: CGFloat(playerSize)
        )
        
        return powerUpRect.intersects(playerRect)
    }
    
    func getRemainingTime(currentTime: TimeInterval) -> TimeInterval {
        if !isActive || type == .extraLife { return 0 }
        let elapsed = currentTime - activationTime
        return max(0, duration - elapsed)
    }
    
    func isExpired(currentTime: TimeInterval) -> Bool {
        if type == .extraLife { return true } // Instant effect
        if !isActive { return false }
        
        return currentTime - activationTime >= duration
    }
    
    func getNotificationText() -> String {
        switch type {
        case .shieldBoost:
            return "Shield Boost Activated!"
        case .rapidFire:
            return "Rapid Fire Activated!"
        case .extraLife:
            return "Extra Life Acquired!"
        case .damageBoost:
            return "Damage Boost Activated!"
        case .missileAutoFire:
            return "Missile Auto-Fire Activated!"
        }
    }
    
    static func getPowerUpName(_ type: PowerUpType) -> String {
        switch type {
        case .shieldBoost:
            return "Shield Boost"
        case .rapidFire:
            return "Rapid Fire"
        case .extraLife:
            return "Extra Life"
        case .damageBoost:
            return "Damage Boost"
        case .missileAutoFire:
            return "Missile Auto-Fire"
        }
    }
}