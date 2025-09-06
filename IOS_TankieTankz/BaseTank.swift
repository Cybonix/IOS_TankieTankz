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
    private var wheelSize: CGFloat = 10.0
    private var wheelOffset: CGFloat = 8.0
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
        
        // Defer visual setup to ensure proper initialization order
        DispatchQueue.main.async { [weak self] in
            self?.setupTankVisualsDeferred()
        }
    }
    
    private func setupTankVisualsDeferred() {
        setupTankVisuals()
        setupPhysicsBody()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setupTankVisuals() {
        // Create a container node to apply scale
        let tankNode = SKNode()
        addChild(tankNode)
        
        // Scale factor to match Android version
        let tankScale: CGFloat = 1.1
        tankNode.setScale(tankScale)
        
        // Create tank body (main rectangle)
        tankBody = SKShapeNode(rectOf: CGSize(width: 50, height: 50))
        tankBody.fillColor = isPlayer ? .green : .red
        tankBody.strokeColor = isPlayer ? .green : .red
        tankNode.addChild(tankBody)
        
        // Create tank cannon
        tankCannon = SKShapeNode(rectOf: CGSize(width: 10, height: 20))
        tankCannon.fillColor = isPlayer ? .green : .red
        tankCannon.strokeColor = isPlayer ? .green : .red
        updateCannonPosition()
        tankNode.addChild(tankCannon)
        
        // Create tank corner details
        let cornerSize: CGFloat = 10
        
        // Top-left corner
        let topLeftCorner = SKShapeNode(rectOf: CGSize(width: cornerSize, height: cornerSize))
        topLeftCorner.fillColor = isPlayer ? .green : .red
        topLeftCorner.strokeColor = isPlayer ? .green : .red
        topLeftCorner.position = CGPoint(x: -25 - cornerSize/2, y: -25 - cornerSize/2)
        tankNode.addChild(topLeftCorner)
        
        // Top-right corner
        let topRightCorner = SKShapeNode(rectOf: CGSize(width: cornerSize, height: cornerSize))
        topRightCorner.fillColor = isPlayer ? .green : .red
        topRightCorner.strokeColor = isPlayer ? .green : .red
        topRightCorner.position = CGPoint(x: 25 + cornerSize/2, y: -25 - cornerSize/2)
        tankNode.addChild(topRightCorner)
        
        // Bottom-left corner
        let bottomLeftCorner = SKShapeNode(rectOf: CGSize(width: cornerSize, height: cornerSize))
        bottomLeftCorner.fillColor = isPlayer ? .green : .red
        bottomLeftCorner.strokeColor = isPlayer ? .green : .red
        bottomLeftCorner.position = CGPoint(x: -25 - cornerSize/2, y: 25 + cornerSize/2)
        tankNode.addChild(bottomLeftCorner)
        
        // Bottom-right corner
        let bottomRightCorner = SKShapeNode(rectOf: CGSize(width: cornerSize, height: cornerSize))
        bottomRightCorner.fillColor = isPlayer ? .green : .red
        bottomRightCorner.strokeColor = isPlayer ? .green : .red
        bottomRightCorner.position = CGPoint(x: 25 + cornerSize/2, y: 25 + cornerSize/2)
        tankNode.addChild(bottomRightCorner)
        
        // Create tank tracks and wheels
        setupTracksAndWheels(tankNode: tankNode)
        
        // Place the node contents at center of the sprite
        tankNode.position = .zero
    }
    
    private func setupTracksAndWheels(tankNode: SKNode) {
        let trackColor = darkenColor(isPlayer ? .green : .red)
        let wheelColor = darkenColor(trackColor)
        
        // Left track
        leftTrack = SKShapeNode(rect: CGRect(x: -25 - wheelOffset, y: -25, width: wheelSize, height: 50))
        leftTrack.fillColor = trackColor
        leftTrack.strokeColor = trackColor
        tankNode.addChild(leftTrack)
        
        // Right track
        rightTrack = SKShapeNode(rect: CGRect(x: 25 + wheelOffset - wheelSize, y: -25, width: wheelSize, height: 50))
        rightTrack.fillColor = trackColor
        rightTrack.strokeColor = trackColor
        tankNode.addChild(rightTrack)
        
        // Create wheels
        let wheelDistance: CGFloat = 13
        for i in 0..<5 {
            let yPos = -25 + CGFloat(i) * wheelDistance
            
            // Left wheel
            let leftWheel = SKShapeNode(rect: CGRect(
                x: -25 - wheelOffset - 2,
                y: yPos,
                width: wheelSize + 4,
                height: wheelSize))
            leftWheel.fillColor = wheelColor
            leftWheel.strokeColor = wheelColor
            tankNode.addChild(leftWheel)
            leftWheels.append(leftWheel)
            
            // Right wheel
            let rightWheel = SKShapeNode(rect: CGRect(
                x: 25 + wheelOffset - wheelSize - 2,
                y: yPos,
                width: wheelSize + 4,
                height: wheelSize))
            rightWheel.fillColor = wheelColor
            rightWheel.strokeColor = wheelColor
            tankNode.addChild(rightWheel)
            rightWheels.append(rightWheel)
        }
    }
    
    private func updateCannonPosition() {
        switch direction {
        case .up:
            tankCannon.position = CGPoint(x: 0, y: -25 - 10)
            tankCannon.zRotation = CGFloat.pi / 2 // 90 degrees
        case .down:
            tankCannon.position = CGPoint(x: 0, y: 25 + 10)
            tankCannon.zRotation = CGFloat.pi * 3 / 2 // 270 degrees
        case .left:
            tankCannon.position = CGPoint(x: -25 - 10, y: 0)
            tankCannon.zRotation = CGFloat.pi // 180 degrees
        case .right:
            tankCannon.position = CGPoint(x: 25 + 10, y: 0)
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