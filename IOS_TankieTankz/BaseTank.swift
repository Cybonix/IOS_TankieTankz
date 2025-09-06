//
//  BaseTank.swift
//  IOS_TankieTankz
//
//  Created by Joseph Mark Orimoloye on 4/24/25.
//

import SpriteKit

class BaseTank: SKSpriteNode {
    // Properties
    var direction: Direction = .up {
        didSet {
            updateCannonPosition()
        }
    }
    var health: Int = 100
    var isPlayer: Bool = false
    
    // Animation properties
    private var animationFrame: Int = 0
    private let maxAnimationFrames: Int = 4
    private var isMoving: Bool = false
    private var lastPosition: CGPoint = .zero
    
    // Hit effect properties
    var isHit: Bool = false
    var hitFlashStartTime: TimeInterval = 0
    private let hitFlashDuration: TimeInterval = 0.2
    
    // Tank shape nodes
    private var tankBody: SKShapeNode!
    private var tankCannon: SKShapeNode!
    private var leftTrack: SKShapeNode!
    private var rightTrack: SKShapeNode!
    private var leftWheels: [SKShapeNode] = []
    private var rightWheels: [SKShapeNode] = []
    
    // Tank size (stored for cannon positioning)
    private var currentTankSize: CGFloat = 0
    
    // Convenience initializer
    init(position: CGPoint, direction: Direction, health: Int, isPlayer: Bool) {
        // Initialize with a 1x1 texture that will be replaced by custom drawing
        super.init(texture: nil, color: .clear, size: CGSize(width: 1, height: 1))
        
        // Set basic properties
        self.position = position
        self.direction = direction
        self.health = health
        self.isPlayer = isPlayer
        self.lastPosition = position
        
        // Setup visuals immediately (no async needed)
        setupTankVisuals()
        setupPhysicsBody()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setupTankVisuals() {
        // Create a container node (NO scaling - use proper constants)
        let tankNode = SKNode()
        addChild(tankNode)
        
        // Use proper tank size from constants
        let tankSize = isPlayer ? TankConstants.PLAYER_TANK_SIZE : TankConstants.ENEMY_TANK_SIZE
        currentTankSize = tankSize
        
        // Create tank body using calculated size
        tankBody = SKShapeNode(rectOf: CGSize(width: tankSize, height: tankSize))
        tankBody.fillColor = isPlayer ? .green : .red
        tankBody.strokeColor = isPlayer ? .green : .red
        tankNode.addChild(tankBody)
        
        // Create tank cannon proportional to tank size
        let cannonWidth = tankSize * 0.2  // 20% of tank width
        let cannonHeight = tankSize * 0.4 // 40% of tank height
        tankCannon = SKShapeNode(rectOf: CGSize(width: cannonWidth, height: cannonHeight))
        tankCannon.fillColor = isPlayer ? .green : .red
        tankCannon.strokeColor = isPlayer ? .green : .red
        updateCannonPosition()
        tankNode.addChild(tankCannon)
        
        // Create tank corner details proportional to tank size
        let cornerSize: CGFloat = tankSize * 0.2  // 20% of tank size
        let halfTank = tankSize / 2
        
        // Top-left corner
        let topLeftCorner = SKShapeNode(rectOf: CGSize(width: cornerSize, height: cornerSize))
        topLeftCorner.fillColor = isPlayer ? .green : .red
        topLeftCorner.strokeColor = isPlayer ? .green : .red
        topLeftCorner.position = CGPoint(x: -halfTank - cornerSize/2, y: -halfTank - cornerSize/2)
        tankNode.addChild(topLeftCorner)
        
        // Top-right corner
        let topRightCorner = SKShapeNode(rectOf: CGSize(width: cornerSize, height: cornerSize))
        topRightCorner.fillColor = isPlayer ? .green : .red
        topRightCorner.strokeColor = isPlayer ? .green : .red
        topRightCorner.position = CGPoint(x: halfTank + cornerSize/2, y: -halfTank - cornerSize/2)
        tankNode.addChild(topRightCorner)
        
        // Bottom-left corner
        let bottomLeftCorner = SKShapeNode(rectOf: CGSize(width: cornerSize, height: cornerSize))
        bottomLeftCorner.fillColor = isPlayer ? .green : .red
        bottomLeftCorner.strokeColor = isPlayer ? .green : .red
        bottomLeftCorner.position = CGPoint(x: -halfTank - cornerSize/2, y: halfTank + cornerSize/2)
        tankNode.addChild(bottomLeftCorner)
        
        // Bottom-right corner
        let bottomRightCorner = SKShapeNode(rectOf: CGSize(width: cornerSize, height: cornerSize))
        bottomRightCorner.fillColor = isPlayer ? .green : .red
        bottomRightCorner.strokeColor = isPlayer ? .green : .red
        bottomRightCorner.position = CGPoint(x: halfTank + cornerSize/2, y: halfTank + cornerSize/2)
        tankNode.addChild(bottomRightCorner)
        
        // Create tank tracks and wheels
        setupTracksAndWheels(tankNode: tankNode, tankSize: tankSize)
        
        // Place the node contents at center of the sprite
        tankNode.position = .zero
    }
    
    private func setupTracksAndWheels(tankNode: SKNode, tankSize: CGFloat) {
        let trackColor = darkenColor(isPlayer ? .green : .red)
        let wheelColor = darkenColor(trackColor)
        
        // Scale all wheel/track components to tank size
        let halfTank = tankSize / 2
        let wheelWidth = tankSize * 0.2    // 20% of tank size
        let wheelHeight = tankSize * 0.2   // 20% of tank size
        let wheelOffset = tankSize * 0.16  // 16% of tank size
        
        // Left track
        leftTrack = SKShapeNode(rect: CGRect(x: -halfTank - wheelOffset, y: -halfTank, width: wheelWidth, height: tankSize))
        leftTrack.fillColor = trackColor
        leftTrack.strokeColor = trackColor
        tankNode.addChild(leftTrack)
        
        // Right track
        rightTrack = SKShapeNode(rect: CGRect(x: halfTank + wheelOffset - wheelWidth, y: -halfTank, width: wheelWidth, height: tankSize))
        rightTrack.fillColor = trackColor
        rightTrack.strokeColor = trackColor
        tankNode.addChild(rightTrack)
        
        // Create wheels
        let wheelDistance: CGFloat = tankSize / 4  // Space wheels based on tank size
        for i in 0..<5 {
            let yPos = -halfTank + CGFloat(i) * wheelDistance
            
            // Left wheel
            let leftWheel = SKShapeNode(rect: CGRect(
                x: -halfTank - wheelOffset - 2,
                y: yPos,
                width: wheelWidth + 4,
                height: wheelHeight))
            leftWheel.fillColor = wheelColor
            leftWheel.strokeColor = wheelColor
            tankNode.addChild(leftWheel)
            leftWheels.append(leftWheel)
            
            // Right wheel
            let rightWheel = SKShapeNode(rect: CGRect(
                x: halfTank + wheelOffset - wheelWidth - 2,
                y: yPos,
                width: wheelWidth + 4,
                height: wheelHeight))
            rightWheel.fillColor = wheelColor
            rightWheel.strokeColor = wheelColor
            tankNode.addChild(rightWheel)
            rightWheels.append(rightWheel)
        }
    }
    
    private func updateCannonPosition() {
        guard tankCannon != nil else { return }
        
        let halfTank = currentTankSize / 2
        let cannonOffset = currentTankSize * 0.2  // 20% of tank size
        
        switch direction {
        case .up:
            tankCannon.position = CGPoint(x: 0, y: -halfTank - cannonOffset)
            tankCannon.zRotation = CGFloat.pi / 2 // 90 degrees
        case .down:
            tankCannon.position = CGPoint(x: 0, y: halfTank + cannonOffset)
            tankCannon.zRotation = CGFloat.pi * 3 / 2 // 270 degrees
        case .left:
            tankCannon.position = CGPoint(x: -halfTank - cannonOffset, y: 0)
            tankCannon.zRotation = CGFloat.pi // 180 degrees
        case .right:
            tankCannon.position = CGPoint(x: halfTank + cannonOffset, y: 0)
            tankCannon.zRotation = 0 // 0 degrees
        }
    }
    
    func updatePosition() {
        // Store last position to detect movement
        lastPosition = position
        
        // Move based on direction
        switch direction {
        case .up:
            position.y += 5
        case .down:
            position.y -= 5
        case .left:
            position.x -= 5
        case .right:
            position.x += 5
        }
        
        // Check if actually moved
        isMoving = (lastPosition != position)
        
        // Update animation frame if moving
        if isMoving {
            animationFrame = (animationFrame + 1) % maxAnimationFrames
            updateWheelAnimation()
        }
        
        // Update cannon orientation when direction changes
        updateCannonPosition()
    }
    
    private func updateWheelAnimation() {
        let wheelDistance: CGFloat = 13
        let animOffset = isMoving ? CGFloat(animationFrame * 4 % 12) : 0
        let reverseAnimOffset = isMoving ? (12.5 - CGFloat(animationFrame * 4 % 12)) : 0
        
        // Move the wheels based on direction
        switch direction {
        case .up, .down:
            let yOffset = direction == .up ? reverseAnimOffset : animOffset
            for i in 0..<leftWheels.count {
                let wheelY = CGFloat(i) * wheelDistance + yOffset
                leftWheels[i].position.y = -25 + wheelY
                rightWheels[i].position.y = -25 + wheelY
            }
        case .left, .right:
            // For horizontal movement, would need to recreate wheels as horizontal
            // Simplified for now - just keep the vertical wheels in place
            break
        }
    }
    
    // MARK: - Helper Methods
    
    private func darkenColor(_ color: SKColor) -> SKColor {
        let factor: CGFloat = 0.7
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        return SKColor(red: r * factor, green: g * factor, blue: b * factor, alpha: a)
    }
    
    // MARK: - Hit Effect
    
    func updateHitEffect(currentTime: TimeInterval) {
        if isHit {
            // Check if hit effect duration has passed
            if currentTime - hitFlashStartTime >= hitFlashDuration {
                isHit = false
                resetColor()
            } else {
                // During hit effect, show white flash
                tankBody.fillColor = .white
                tankCannon.fillColor = .white
                // Would need to update other tank parts as well
            }
        }
    }
    
    private func resetColor() {
        let baseColor = isPlayer ? SKColor.green : SKColor.red
        tankBody.fillColor = baseColor
        tankCannon.fillColor = baseColor
        // Would need to update other tank parts as well
    }
    
    private func setupPhysicsBody() {
        let size = isPlayer ? TankConstants.PLAYER_TANK_SIZE : TankConstants.ENEMY_TANK_SIZE
        let tankSize = CGSize(width: size, height: size)
        
        physicsBody = SKPhysicsBody(rectangleOf: tankSize)
        physicsBody?.isDynamic = true
        physicsBody?.affectedByGravity = false
        physicsBody?.allowsRotation = false
        
        if isPlayer {
            physicsBody?.categoryBitMask = PhysicsCategory.playerTank
            physicsBody?.contactTestBitMask = PhysicsCategory.enemyBullet | PhysicsCategory.powerUp
            physicsBody?.collisionBitMask = PhysicsCategory.wall
        } else {
            physicsBody?.categoryBitMask = PhysicsCategory.enemyTank
            physicsBody?.contactTestBitMask = PhysicsCategory.playerBullet | PhysicsCategory.playerMissile
            physicsBody?.collisionBitMask = PhysicsCategory.wall
        }
    }
}
