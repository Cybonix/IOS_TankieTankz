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
    
    // Health bar components
    private var healthBarContainer: SKNode!
    private var healthBarBackground: SKShapeNode!
    private var healthBarForeground: SKShapeNode!
    private let maxHealth: Int
    
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
        self.maxHealth = health
        
        // Call super init first - let parent initialize fully
        super.init(position: position, direction: direction, health: health, isPlayer: false)
        
        // AFTER super.init completes, setup child-specific features
        setupEnemyFeatures()
        setupHealthBar()
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
        self.maxHealth = CombatConstants.ENEMY_MAX_HEALTH
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
        physicsBody?.collisionBitMask = PhysicsCategory.wall | PhysicsCategory.playerTank
    }
    
    func updateDirection(currentTime: TimeInterval) {
        // Change direction periodically
        if currentTime - directionChangeTime >= directionChangeInterval {
            direction = Direction.allCases.randomElement() ?? .down
            directionChangeTime = currentTime
        }
    }
    
    func update(currentTime: TimeInterval) {
        // Update hit effect from parent class
        updateHitEffect(currentTime: currentTime)
        
        // Update direction
        updateDirection(currentTime: currentTime)
        
        // Update health bar
        updateHealthBar()
    }
    
    private func setupHealthBar() {
        // Create container for health bar
        healthBarContainer = SKNode()
        addChild(healthBarContainer)
        
        // Health bar dimensions
        let barWidth: CGFloat = isBoss ? 60 : 40
        let barHeight: CGFloat = 6
        let tankSize = isBoss ? TankConstants.BOSS_TANK_SIZE : TankConstants.ENEMY_TANK_SIZE
        let yOffset: CGFloat = tankSize * 0.7 + 15  // Position above tank
        
        // Background (red)
        healthBarBackground = SKShapeNode(rectOf: CGSize(width: barWidth, height: barHeight))
        healthBarBackground.fillColor = .red
        healthBarBackground.strokeColor = .black
        healthBarBackground.lineWidth = 1
        healthBarBackground.position = CGPoint(x: 0, y: yOffset)
        healthBarContainer.addChild(healthBarBackground)
        
        // Foreground (green, will shrink as health decreases)
        healthBarForeground = SKShapeNode(rectOf: CGSize(width: barWidth, height: barHeight))
        healthBarForeground.fillColor = .green
        healthBarForeground.strokeColor = .clear
        healthBarForeground.position = CGPoint(x: 0, y: yOffset)
        healthBarContainer.addChild(healthBarForeground)
        
        // Initial health bar update
        updateHealthBar()
    }
    
    private func updateHealthBar() {
        guard let healthBarForeground = healthBarForeground else { return }
        
        // Calculate health percentage
        let healthPercentage = max(0, min(1, Double(health) / Double(maxHealth)))
        
        // Update foreground bar width based on health
        let barWidth: CGFloat = isBoss ? 60 : 40
        let currentWidth = barWidth * CGFloat(healthPercentage)
        
        // Update the foreground bar size
        let newPath = CGPath(rect: CGRect(x: -currentWidth/2, y: -3, width: currentWidth, height: 6), transform: nil)
        healthBarForeground.path = newPath
        
        // Change color based on health level
        if healthPercentage > 0.6 {
            healthBarForeground.fillColor = .green
        } else if healthPercentage > 0.3 {
            healthBarForeground.fillColor = .yellow
        } else {
            healthBarForeground.fillColor = .red
        }
        
        // Hide health bar if enemy is destroyed or at full health
        let shouldShowHealthBar = health > 0 && health < maxHealth
        healthBarContainer.isHidden = !shouldShowHealthBar
    }
}

// PhysicsCategory is now defined in Constants.swift
