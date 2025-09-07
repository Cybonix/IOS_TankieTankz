//
//  Missile.swift
//  IOS_TankieTankz
//
//  Created by Joseph Mark Orimoloye on 4/24/25.
//

import SpriteKit
import Foundation

class Missile: SKNode {
    let targetTank: EnemyTank
    let biomeType: BiomeType
    let missileSpeed: CGFloat = WeaponConstants.MISSILE_SPEED
    private var size: CGFloat = WeaponConstants.MISSILE_SIZE
    private var angle: CGFloat = 0.0
    private var smokeTrail: [SmokeParticle] = []
    private var lastSmokeTime: TimeInterval = 0
    private let smokeInterval: TimeInterval = 0.05 // 50ms between smoke particles
    private var animationFrame: Int = 0
    
    // Missile visual components
    private var missileBody: SKShapeNode!
    private var missileCone: SKShapeNode!
    private var leftFin: SKShapeNode!
    private var rightFin: SKShapeNode!
    private var exhaust: SKShapeNode!
    
    init(position: CGPoint, targetTank: EnemyTank, biomeType: BiomeType) {
        self.targetTank = targetTank
        self.biomeType = biomeType
        
        super.init()
        self.position = position
        
        setupMissileVisuals()
        setupPhysicsBody()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupMissileVisuals() {
        // Create the missile body
        missileBody = SKShapeNode(rectOf: CGSize(width: size, height: size * 3))
        missileBody.fillColor = getMissileColor()
        missileBody.strokeColor = biomeType == .desert || biomeType == .snow ? .black : missileBody.fillColor
        missileBody.lineWidth = biomeType == .desert || biomeType == .snow ? 2.0 : 0.0
        addChild(missileBody)
        
        // Create the missile nose cone
        let conePath = CGMutablePath()
        conePath.move(to: CGPoint(x: -size/2, y: -size * 1.5))
        conePath.addLine(to: CGPoint(x: 0, y: -size * 2))
        conePath.addLine(to: CGPoint(x: size/2, y: -size * 1.5))
        conePath.closeSubpath()
        
        missileCone = SKShapeNode(path: conePath)
        missileCone.fillColor = getMissileColor()
        missileCone.strokeColor = biomeType == .desert || biomeType == .snow ? .black : missileCone.fillColor
        missileCone.lineWidth = biomeType == .desert || biomeType == .snow ? 2.0 : 0.0
        addChild(missileCone)
        
        // Create the left fin
        let leftFinPath = CGMutablePath()
        leftFinPath.move(to: CGPoint(x: -size/2, y: size * 1.5))
        leftFinPath.addLine(to: CGPoint(x: -size * 1.5, y: size * 2))
        leftFinPath.addLine(to: CGPoint(x: -size/2, y: size))
        leftFinPath.closeSubpath()
        
        leftFin = SKShapeNode(path: leftFinPath)
        leftFin.fillColor = getMissileColor()
        leftFin.strokeColor = biomeType == .desert || biomeType == .snow ? .black : leftFin.fillColor
        leftFin.lineWidth = biomeType == .desert || biomeType == .snow ? 2.0 : 0.0
        addChild(leftFin)
        
        // Create the right fin
        let rightFinPath = CGMutablePath()
        rightFinPath.move(to: CGPoint(x: size/2, y: size * 1.5))
        rightFinPath.addLine(to: CGPoint(x: size * 1.5, y: size * 2))
        rightFinPath.addLine(to: CGPoint(x: size/2, y: size))
        rightFinPath.closeSubpath()
        
        rightFin = SKShapeNode(path: rightFinPath)
        rightFin.fillColor = getMissileColor()
        rightFin.strokeColor = biomeType == .desert || biomeType == .snow ? .black : rightFin.fillColor
        rightFin.lineWidth = biomeType == .desert || biomeType == .snow ? 2.0 : 0.0
        addChild(rightFin)
        
        // Create the exhaust flame
        updateExhaustFlame()
        
        // Add glow effect
        addGlowEffect()
    }
    
    private func updateExhaustFlame() {
        // Remove existing exhaust if any
        exhaust?.removeFromParent()
        
        // Create animated exhaust flame
        let flameHeight = 5 + (animationFrame % 3) * 3
        let flamePath = CGMutablePath()
        flamePath.move(to: CGPoint(x: -size/4, y: size * 1.5))
        flamePath.addLine(to: CGPoint(x: 0, y: size * 1.5 + CGFloat(flameHeight)))
        flamePath.addLine(to: CGPoint(x: size/4, y: size * 1.5))
        flamePath.closeSubpath()
        
        exhaust = SKShapeNode(path: flamePath)
        exhaust.fillColor = getExhaustColor()
        exhaust.strokeColor = biomeType == .desert || biomeType == .snow ? .black : exhaust.fillColor
        exhaust.lineWidth = biomeType == .desert || biomeType == .snow ? 1.5 : 0.0
        addChild(exhaust)
    }
    
    private func getMissileColor() -> SKColor {
        switch biomeType {
        case .urban:
            return SKColor(red: 1.0, green: 1.0, blue: 0, alpha: 1.0) // Yellow
        case .desert:
            return SKColor(red: 0.8, green: 0, blue: 0, alpha: 1.0) // Dark red
        case .snow:
            return SKColor(red: 0.7, green: 0, blue: 0, alpha: 1.0) // Darker red
        case .volcanic:
            return SKColor(red: 1.0, green: 1.0, blue: 0.4, alpha: 1.0) // Light yellow
        }
    }
    
    private func getExhaustColor() -> SKColor {
        switch biomeType {
        case .urban, .volcanic:
            return SKColor(red: 0, green: 0.9, blue: 1.0, alpha: 1.0) // Bright cyan
        case .desert:
            return SKColor(red: 0, green: 0, blue: 0.7, alpha: 1.0) // Dark blue
        case .snow:
            return SKColor(red: 0, green: 0, blue: 0.6, alpha: 1.0) // Darker blue
        }
    }
    
    private func addGlowEffect() {
        // Add glow effects only if performance allows
        if PerformanceSettings.ENABLE_GLOW_EFFECTS {
            // Add glow to missile body
            let glowColor: SKColor
            
            switch biomeType {
            case .urban, .volcanic:
                glowColor = .white
            case .desert:
                glowColor = SKColor(red: 0.5, green: 0, blue: 0, alpha: 1.0)
            case .snow:
                glowColor = SKColor(red: 0.4, green: 0, blue: 0, alpha: 1.0)
            }
            
            // Add missile body glow
            let bodyGlow = SKEffectNode()
            bodyGlow.shouldRasterize = true
            bodyGlow.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius": 10])
            
            let glowShape = SKShapeNode(rectOf: CGSize(width: size, height: size * 3))
            glowShape.fillColor = glowColor
            glowShape.strokeColor = .clear
            glowShape.alpha = 0.6
            
            bodyGlow.addChild(glowShape)
            insertChild(bodyGlow, at: 0)  // Insert below the missile for glow effect
            
            // Add exhaust glow
            let exhaustGlowColor: SKColor
            
            switch biomeType {
            case .urban, .volcanic:
                exhaustGlowColor = .cyan
            case .desert:
                exhaustGlowColor = SKColor(red: 0, green: 0, blue: 0.4, alpha: 1.0)
            case .snow:
                exhaustGlowColor = SKColor(red: 0, green: 0, blue: 0.3, alpha: 1.0)
            }
            
            let exhaustGlow = SKEffectNode()
            exhaustGlow.shouldRasterize = true
            exhaustGlow.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius": 15])
            
            let exhaustGlowShape = SKShapeNode(rectOf: CGSize(width: size, height: size * 2))
            exhaustGlowShape.fillColor = exhaustGlowColor
            exhaustGlowShape.strokeColor = .clear
            exhaustGlowShape.alpha = 0.7
            exhaustGlowShape.position = CGPoint(x: 0, y: size * 1.5)
            
            exhaustGlow.addChild(exhaustGlowShape)
            insertChild(exhaustGlow, at: 0)
        }
    }
    
    private func setupPhysicsBody() {
        physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: size, height: size * 3))
        physicsBody?.isDynamic = true
        physicsBody?.affectedByGravity = false
        physicsBody?.categoryBitMask = PhysicsCategory.playerMissile
        physicsBody?.contactTestBitMask = PhysicsCategory.enemyTank
        physicsBody?.collisionBitMask = PhysicsCategory.none
    }
    
    func updatePosition(currentTime: TimeInterval) -> Bool {
        // Update animation frame
        animationFrame += 1
        updateExhaustFlame()
        
        // Add smoke trail
        if currentTime - lastSmokeTime > smokeInterval {
            addSmokeParticle(currentTime: currentTime)
            lastSmokeTime = currentTime
        }
        
        // Update smoke trail particles
        updateSmokeTrail(currentTime: currentTime)
        
        // Check if target is still valid
        if targetTank.isDestroyed || targetTank.health <= 0 {
            return false
        }
        
        // Calculate angle to target
        let dx = targetTank.position.x - position.x
        let dy = targetTank.position.y - position.y
        angle = atan2(dy, dx)
        
        // Rotate missile to face target
        zRotation = angle + CGFloat.pi / 2 // Add 90 degrees because missile sprite is oriented upward
        
        // Move missile towards target
        position.x += cos(angle) * missileSpeed
        position.y += sin(angle) * missileSpeed
        
        // Check if missile has reached its target
        let distanceSquared = dx * dx + dy * dy
        let reachedTarget = distanceSquared < 50 * 50 // Within 50 pixels
        
        return !reachedTarget // Return true if missile should continue, false if it reached target
    }
    
    func checkCollision(with tank: EnemyTank) -> Bool {
        // Check if this is our target - then we need to be very close
        if tank === targetTank {
            let dx = tank.position.x - position.x
            let dy = tank.position.y - position.y
            return dx * dx + dy * dy < 20 * 20 // Very close distance
        }
        
        // For other tanks, use expanded hitbox
        let hitboxSize: CGFloat = tank.isBoss ? 75 : 50
        
        let tankFrame = CGRect(
            x: tank.position.x - hitboxSize/2,
            y: tank.position.y - hitboxSize/2,
            width: hitboxSize,
            height: hitboxSize
        )
        
        let missileFrame = CGRect(
            x: position.x - size/2,
            y: position.y - size*1.5,
            width: size,
            height: size*3
        )
        
        return tankFrame.intersects(missileFrame)
    }
    
    private func addSmokeParticle(currentTime: TimeInterval) {
        let smokeParticle = SmokeParticle(position: position, birthTime: currentTime, biomeType: biomeType)
        addChild(smokeParticle)
        smokeTrail.append(smokeParticle)
    }
    
    private func updateSmokeTrail(currentTime: TimeInterval) {
        var particlesToRemove: [SmokeParticle] = []
        
        for particle in smokeTrail {
            if particle.update(currentTime: currentTime) {
                // Particle is dead, mark for removal
                particlesToRemove.append(particle)
            }
        }
        
        // Remove dead particles
        for particle in particlesToRemove {
            particle.removeFromParent()
            if let index = smokeTrail.firstIndex(where: { $0 === particle }) {
                smokeTrail.remove(at: index)
            }
        }
    }
}

// Smoke particle class
class SmokeParticle: SKShapeNode {
    private let birthTime: TimeInterval
    private let maxAge: TimeInterval = 0.5 // 500ms
    private let biomeType: BiomeType
    
    init(position: CGPoint, birthTime: TimeInterval, biomeType: BiomeType) {
        self.birthTime = birthTime
        self.biomeType = biomeType
        
        super.init()
        
        // Random size for particle
        let size = CGFloat.random(in: 3...8)
        path = CGPath(ellipseIn: CGRect(x: -size/2, y: -size/2, width: size, height: size), transform: nil)
        
        // Position slightly randomized around missile
        self.position = CGPoint(
            x: position.x + CGFloat.random(in: -5...5),
            y: position.y + CGFloat.random(in: -5...5)
        )
        
        // Set color based on biome
        fillColor = getSmokeColor()
        strokeColor = .clear
        
        // Add glow effect
        addGlowEffect()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func getSmokeColor() -> SKColor {
        switch biomeType {
        case .urban, .volcanic:
            return SKColor(red: 0.7, green: 0.7, blue: 1.0, alpha: 1.0) // Light blue
        case .desert:
            return SKColor(red: 0.2, green: 0.2, blue: 0.5, alpha: 1.0) // Dark blue-gray
        case .snow:
            return SKColor(red: 0.1, green: 0.1, blue: 0.4, alpha: 1.0) // Very dark blue
        }
    }
    
    private func addGlowEffect() {
        // Add glow effect only if performance allows
        if PerformanceSettings.ENABLE_GLOW_EFFECTS {
            let glowColor: SKColor
            
            switch biomeType {
            case .urban, .volcanic:
                glowColor = .white
            case .desert:
                glowColor = SKColor(red: 0, green: 0, blue: 0.3, alpha: 1.0)
            case .snow:
                glowColor = SKColor(red: 0, green: 0, blue: 0.2, alpha: 1.0)
            }
            
            // Add glow effect via SKEffectNode
            let effectNode = SKEffectNode()
            effectNode.shouldRasterize = true
            effectNode.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius": 5])
            
            // Create a copy of the smoke shape for the glow
            if let smokePath = path {
                let glowShape = SKShapeNode(path: smokePath)
                glowShape.fillColor = glowColor
                glowShape.strokeColor = .clear
                glowShape.alpha = 0.6
                
                effectNode.addChild(glowShape)
                addChild(effectNode)
            }
        }
    }
    
    // Returns true if the particle should be removed
    func update(currentTime: TimeInterval) -> Bool {
        let age = currentTime - birthTime
        if age >= maxAge {
            return true
        }
        
        // Fade out based on age
        let alpha = 1.0 - (age / maxAge)
        self.alpha = CGFloat(alpha)
        
        return false
    }
}