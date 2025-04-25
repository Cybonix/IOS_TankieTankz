//
//  EnemyTank.swift
//  IOS_TankieTankz
//
//  Created by Joseph Mark Orimoloye on 4/24/25.
//

import SpriteKit

class EnemyTank: BaseTank {
    var isBoss: Bool = false
    var isDestroyed: Bool = false
    private var directionChangeTime: TimeInterval = 0
    private let directionChangeInterval: TimeInterval = 2.0 // Change direction every 2 seconds
    
    init(position: CGPoint, direction: Direction, isBoss: Bool) {
        super.init(position: position, direction: direction, health: isBoss ? 200 : 50, isPlayer: false)
        self.isBoss = isBoss
        
        // If it's a boss tank, make it larger and use a different color
        if isBoss {
            setScale(1.5) // 50% larger than regular tanks
            
            // Change color to indicate it's a boss (cycle through children)
            for child in children {
                if let shapeNode = child as? SKShapeNode {
                    shapeNode.fillColor = .cyan
                    shapeNode.strokeColor = .cyan
                }
                
                // If the child has its own children (like our container node)
                for grandchild in child.children {
                    if let shapeNode = grandchild as? SKShapeNode {
                        shapeNode.fillColor = .cyan
                        shapeNode.strokeColor = .cyan
                    }
                }
            }
        }
        
        setupPhysicsBody()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setupPhysicsBody() {
        // Create a physics body for the tank
        let bodySize = CGSize(width: 50, height: 50)
        let scaledSize = CGSize(
            width: bodySize.width * (isBoss ? 1.5 : 1.0),
            height: bodySize.height * (isBoss ? 1.5 : 1.0)
        )
        
        physicsBody = SKPhysicsBody(rectangleOf: scaledSize)
        physicsBody?.isDynamic = true
        physicsBody?.affectedByGravity = false
        physicsBody?.allowsRotation = false
        physicsBody?.categoryBitMask = PhysicsCategory.enemyTank
        physicsBody?.contactTestBitMask = PhysicsCategory.playerBullet | PhysicsCategory.playerMissile
        physicsBody?.collisionBitMask = PhysicsCategory.wall
    }
    
    func updateDirection(currentTime: TimeInterval) {
        // Change direction periodically
        if currentTime - directionChangeTime >= directionChangeInterval {
            direction = Direction.allCases.randomElement() ?? .down
            directionChangeTime = currentTime
        }
    }
}

// Physics categories will be defined centrally
struct PhysicsCategory {
    static let none: UInt32 = 0
    static let playerTank: UInt32 = 0x1 << 0
    static let enemyTank: UInt32 = 0x1 << 1
    static let playerBullet: UInt32 = 0x1 << 2
    static let enemyBullet: UInt32 = 0x1 << 3
    static let playerMissile: UInt32 = 0x1 << 4
    static let wall: UInt32 = 0x1 << 5
    static let powerUp: UInt32 = 0x1 << 6
}