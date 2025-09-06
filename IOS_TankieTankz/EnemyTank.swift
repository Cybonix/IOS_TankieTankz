//
//  EnemyTank.swift
//  IOS_TankieTankz
//
//  Created by Joseph Mark Orimoloye on 4/24/25.
//

import SpriteKit
import Foundation

class EnemyTank: BaseTank {
    // Remove default values to prevent double-initialization
    let isBoss: Bool
    let bossType: BossType
    var isDestroyed: Bool = false
    private var directionChangeTime: TimeInterval = 0
    private let directionChangeInterval: TimeInterval = 2.0
    
    // Convenience initializer for backward compatibility
    convenience init(position: CGPoint, direction: Direction, isBoss: Bool) {
        self.init(position: position, direction: direction, isBoss: isBoss, bossType: .assault)
    }
    
    // Main initializer - Fixed Swift initialization order
    init(position: CGPoint, direction: Direction, isBoss: Bool, bossType: BossType) {
        let health = isBoss ? CombatConstants.BOSS_MAX_HEALTH : CombatConstants.ENEMY_MAX_HEALTH
        
        // CRITICAL: Set let properties before super.init (Swift requirement)
        self.isBoss = isBoss
        self.bossType = bossType
        
        // Call super init first - let parent initialize fully
        super.init(position: position, direction: direction, health: health, isPlayer: false)
        
        // AFTER super.init completes, setup child-specific features
        setupEnemyFeatures()
    }
    
    private func setupEnemyFeatures() {
        // Setup boss appearance if needed (after full initialization)
        if isBoss {
            setScale(TankConstants.BOSS_SCALE_FACTOR)
            setupBossAppearance()
        }
        
        // Setup physics body last (after all visual setup)
        setupPhysicsBody()
    }
    
    private func setupBossAppearance() {
        let bossColors = bossType.colors
        
        // Apply boss colors to tank components
        for child in children {
            if let shapeNode = child as? SKShapeNode {
                shapeNode.fillColor = UIColor(cgColor: bossColors.primary.cgColor)
                shapeNode.strokeColor = UIColor(cgColor: bossColors.secondary.cgColor)
            }
            
            // Apply to nested components
            for grandchild in child.children {
                if let shapeNode = grandchild as? SKShapeNode {
                    shapeNode.fillColor = UIColor(cgColor: bossColors.primary.cgColor)
                    shapeNode.strokeColor = UIColor(cgColor: bossColors.secondary.cgColor)
                }
            }
        }
        
        // Add glow effect for boss tanks
        addGlow(color: bossColors.secondary, radius: DisplayConstants.GLOW_EFFECT_RADIUS)
    }
    
    required init?(coder aDecoder: NSCoder) {
        // Initialize let properties before super.init
        self.isBoss = false
        self.bossType = .assault
        super.init(coder: aDecoder)
    }
    
    private func setupPhysicsBody() {
        // Create a physics body for the tank
        let bodySize = CGSize(width: TankConstants.ENEMY_TANK_SIZE, height: TankConstants.ENEMY_TANK_SIZE)
        let scaleFactor: CGFloat = isBoss ? TankConstants.BOSS_SCALE_FACTOR : 1.0
        let scaledSize = CGSize(
            width: bodySize.width * scaleFactor,
            height: bodySize.height * scaleFactor
        )
        
        physicsBody = SKPhysicsBody(rectangleOf: scaledSize)
        physicsBody?.isDynamic = true
        physicsBody?.affectedByGravity = false
        physicsBody?.allowsRotation = false
        physicsBody?.categoryBitMask = PhysicsCategory.enemyTank
        physicsBody?.contactTestBitMask = PhysicsCategory.playerBullet | PhysicsCategory.playerMissile | PhysicsCategory.playerTank
        physicsBody?.collisionBitMask = PhysicsCategory.wall | PhysicsCategory.playerTank | PhysicsCategory.enemyTank
    }
    
    func updateDirection(currentTime: TimeInterval) {
        // Change direction periodically
        if currentTime - directionChangeTime >= directionChangeInterval {
            direction = Direction.allCases.randomElement() ?? .down
            directionChangeTime = currentTime
        }
    }
}

// PhysicsCategory is now defined in Constants.swift
