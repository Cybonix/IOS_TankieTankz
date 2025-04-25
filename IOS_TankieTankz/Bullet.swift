//
//  Bullet.swift
//  IOS_TankieTankz
//
//  Created by Joseph Mark Orimoloye on 4/24/25.
//

import SpriteKit

class Bullet: SKShapeNode {
    let direction: Direction
    let isEnemy: Bool
    let fromBoss: Bool
    let biomeType: BiomeType
    
    // For collision detection
    let bulletSize: CGFloat
    
    init(position: CGPoint, direction: Direction, isEnemy: Bool, fromBoss: Bool, biomeType: BiomeType) {
        self.direction = direction
        self.isEnemy = isEnemy
        self.fromBoss = fromBoss
        self.biomeType = biomeType
        
        // Size will be larger for boss bullets and adjusted for biome visibility
        bulletSize = fromBoss ? 12 : (biomeType == .desert || biomeType == .snow ? 7 : 5)
        
        super.init()
        
        // Set up bullet visuals
        setupBulletVisuals()
        
        // Position the bullet
        self.position = position
        
        // Set up physics for collision detection
        setupPhysicsBody()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupBulletVisuals() {
        // Create the bullet shape
        path = CGPath(rect: CGRect(x: -bulletSize/2, y: -bulletSize/2, width: bulletSize, height: bulletSize), transform: nil)
        
        // Set bullet color based on the biome and bullet type
        fillColor = getBulletColor()
        strokeColor = biomeType == .desert || biomeType == .snow ? .black : fillColor
        lineWidth = biomeType == .desert || biomeType == .snow ? 2.0 : 0.0
        
        // Add glow effect
        addGlowEffect()
    }
    
    private func getBulletColor() -> SKColor {
        switch (isEnemy, fromBoss, biomeType) {
        // Boss bullet colors based on biome
        case (_, true, .urban):
            return SKColor(red: 0, green: 1.0, blue: 1.0, alpha: 1.0) // Bright cyan
        case (_, true, .desert):
            return SKColor(red: 0, green: 0, blue: 0.7, alpha: 1.0) // Dark blue
        case (_, true, .snow):
            return SKColor(red: 0, green: 0, blue: 0.6, alpha: 1.0) // Very dark blue
        case (_, true, .volcanic):
            return SKColor(red: 0, green: 1.0, blue: 0.8, alpha: 1.0) // Turquoise
            
        // Enemy bullet colors based on biome
        case (true, false, .urban):
            return SKColor(red: 1.0, green: 0.2, blue: 1.0, alpha: 1.0) // Magenta
        case (true, false, .desert):
            return SKColor(red: 0.5, green: 0, blue: 0.5, alpha: 1.0) // Dark magenta
        case (true, false, .snow):
            return SKColor(red: 0.4, green: 0, blue: 0.4, alpha: 1.0) // Very dark magenta
        case (true, false, .volcanic):
            return SKColor(red: 1.0, green: 0.4, blue: 1.0, alpha: 1.0) // Lighter magenta
            
        // Player bullet colors based on biome
        case (false, false, .urban):
            return SKColor(red: 1.0, green: 1.0, blue: 0, alpha: 1.0) // Yellow
        case (false, false, .desert):
            return SKColor(red: 0.8, green: 0.2, blue: 0, alpha: 1.0) // Dark orange-red
        case (false, false, .snow):
            return SKColor(red: 0.7, green: 0, blue: 0, alpha: 1.0) // Dark red
        case (false, false, .volcanic):
            return SKColor(red: 1.0, green: 1.0, blue: 0.4, alpha: 1.0) // Light yellow
        }
    }
    
    private func addGlowEffect() {
        let glowColor: SKColor
        
        switch (isEnemy, fromBoss, biomeType) {
        // Glow colors for boss bullets
        case (_, true, .urban), (_, true, .volcanic):
            glowColor = .cyan
        case (_, true, .desert):
            glowColor = SKColor(red: 0, green: 0, blue: 0.4, alpha: 1.0)
        case (_, true, .snow):
            glowColor = SKColor(red: 0, green: 0, blue: 0.3, alpha: 1.0)
            
        // Glow colors for enemy bullets
        case (true, false, .urban), (true, false, .volcanic):
            glowColor = .white
        case (true, false, .desert):
            glowColor = SKColor(red: 0.4, green: 0, blue: 0.4, alpha: 1.0)
        case (true, false, .snow):
            glowColor = SKColor(red: 0.3, green: 0, blue: 0.3, alpha: 1.0)
            
        // Glow colors for player bullets
        case (false, false, .urban), (false, false, .volcanic):
            glowColor = .white
        case (false, false, .desert):
            glowColor = SKColor(red: 0.6, green: 0, blue: 0, alpha: 1.0)
        case (false, false, .snow):
            glowColor = SKColor(red: 0.5, green: 0, blue: 0, alpha: 1.0)
        }
        
        // Add glow effect
        let glowSize: CGFloat = fromBoss ? 15 : 10
        let effectNode = SKEffectNode()
        effectNode.shouldRasterize = true
        effectNode.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius": glowSize])
        
        // Create a copy of the bullet shape for the glow
        let glowPath = CGPath(rect: CGRect(x: -bulletSize/2, y: -bulletSize/2, width: bulletSize, height: bulletSize), transform: nil)
        let glowShape = SKShapeNode(path: glowPath)
        glowShape.fillColor = glowColor
        glowShape.strokeColor = .clear
        glowShape.alpha = 0.6
        
        effectNode.addChild(glowShape)
        addChild(effectNode)
    }
    
    private func setupPhysicsBody() {
        physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: bulletSize, height: bulletSize))
        physicsBody?.isDynamic = true
        physicsBody?.affectedByGravity = false
        physicsBody?.categoryBitMask = isEnemy ? PhysicsCategory.enemyBullet : PhysicsCategory.playerBullet
        physicsBody?.contactTestBitMask = isEnemy ? PhysicsCategory.playerTank : PhysicsCategory.enemyTank
        physicsBody?.collisionBitMask = PhysicsCategory.none
    }
    
    func updatePosition() {
        let speed: CGFloat = isEnemy ? 5 : 10
        
        switch direction {
        case .up:
            position.y += speed
        case .down:
            position.y -= speed
        case .left:
            position.x -= speed
        case .right:
            position.x += speed
        }
    }
}