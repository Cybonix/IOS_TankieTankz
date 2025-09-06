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
    private let maxAnimationFrames: Int = 8  // More frames for smoother animation
    private var animationFrameCounter: Int = 0  // Counter to slow down animation
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
        
        // Create tank body wider than it is tall for better tank appearance
        let tankWidth = tankSize * 1.3  // 30% wider
        let tankHeight = tankSize
        tankBody = SKShapeNode(rectOf: CGSize(width: tankWidth, height: tankHeight))
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
        let halfTankWidth = tankWidth / 2
        let halfTankHeight = tankHeight / 2
        
        // Top-left corner
        let topLeftCorner = SKShapeNode(rectOf: CGSize(width: cornerSize, height: cornerSize))
        topLeftCorner.fillColor = isPlayer ? .green : .red
        topLeftCorner.strokeColor = isPlayer ? .green : .red
        topLeftCorner.position = CGPoint(x: -halfTankWidth - cornerSize/2, y: -halfTankHeight - cornerSize/2)
        tankNode.addChild(topLeftCorner)
        
        // Top-right corner
        let topRightCorner = SKShapeNode(rectOf: CGSize(width: cornerSize, height: cornerSize))
        topRightCorner.fillColor = isPlayer ? .green : .red
        topRightCorner.strokeColor = isPlayer ? .green : .red
        topRightCorner.position = CGPoint(x: halfTankWidth + cornerSize/2, y: -halfTankHeight - cornerSize/2)
        tankNode.addChild(topRightCorner)
        
        // Bottom-left corner
        let bottomLeftCorner = SKShapeNode(rectOf: CGSize(width: cornerSize, height: cornerSize))
        bottomLeftCorner.fillColor = isPlayer ? .green : .red
        bottomLeftCorner.strokeColor = isPlayer ? .green : .red
        bottomLeftCorner.position = CGPoint(x: -halfTankWidth - cornerSize/2, y: halfTankHeight + cornerSize/2)
        tankNode.addChild(bottomLeftCorner)
        
        // Bottom-right corner
        let bottomRightCorner = SKShapeNode(rectOf: CGSize(width: cornerSize, height: cornerSize))
        bottomRightCorner.fillColor = isPlayer ? .green : .red
        bottomRightCorner.strokeColor = isPlayer ? .green : .red
        bottomRightCorner.position = CGPoint(x: halfTankWidth + cornerSize/2, y: halfTankHeight + cornerSize/2)
        tankNode.addChild(bottomRightCorner)
        
        // Create tank tracks and wheels
        setupTracksAndWheels(tankNode: tankNode, tankSize: tankSize)
        
        // Place the node contents at center of the sprite
        tankNode.position = .zero
    }
    
    private func setupTracksAndWheels(tankNode: SKNode, tankSize: CGFloat) {
        let trackColor = darkenColor(isPlayer ? .green : .red)
        let wheelColor = darkenColor(trackColor)
        
        // Use the actual tank dimensions for wider tank
        let tankWidth = tankSize * 1.3  // Match the wider tank body
        let tankHeight = tankSize
        let halfTankWidth = tankWidth / 2
        let halfTankHeight = tankHeight / 2
        let wheelWidth = tankSize * 0.15   // 15% of tank size
        let wheelHeight = tankSize * 0.15  // 15% of tank size
        let wheelOffset = tankSize * 0.05  // 5% of tank size - much closer to body
        
        // Left track
        leftTrack = SKShapeNode(rect: CGRect(x: -halfTankWidth - wheelOffset, y: -halfTankHeight, width: wheelWidth, height: tankHeight))
        leftTrack.fillColor = trackColor
        leftTrack.strokeColor = trackColor
        tankNode.addChild(leftTrack)
        
        // Right track
        rightTrack = SKShapeNode(rect: CGRect(x: halfTankWidth + wheelOffset - wheelWidth, y: -halfTankHeight, width: wheelWidth, height: tankHeight))
        rightTrack.fillColor = trackColor
        rightTrack.strokeColor = trackColor
        tankNode.addChild(rightTrack)
        
        // Create wheels
        let wheelDistance: CGFloat = tankHeight / 4  // Space wheels based on tank height
        for i in 0..<5 {
            let yPos = -halfTankHeight + CGFloat(i) * wheelDistance
            
            // Left wheel
            let leftWheel = SKShapeNode(rect: CGRect(
                x: -halfTankWidth - wheelOffset - 2,
                y: yPos,
                width: wheelWidth + 4,
                height: wheelHeight))
            leftWheel.fillColor = wheelColor
            leftWheel.strokeColor = wheelColor
            tankNode.addChild(leftWheel)
            leftWheels.append(leftWheel)
            
            // Right wheel
            let rightWheel = SKShapeNode(rect: CGRect(
                x: halfTankWidth + wheelOffset - wheelWidth - 2,
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
        
        // Use the actual tank dimensions for wider tank
        let tankWidth = currentTankSize * 1.3
        let tankHeight = currentTankSize
        let halfTankWidth = tankWidth / 2
        let halfTankHeight = tankHeight / 2
        let cannonOffset = currentTankSize * 0.2  // 20% of tank size
        
        switch direction {
        case .up:
            tankCannon.position = CGPoint(x: 0, y: -halfTankHeight - cannonOffset)
            tankCannon.zRotation = CGFloat.pi / 2 // 90 degrees
        case .down:
            tankCannon.position = CGPoint(x: 0, y: halfTankHeight + cannonOffset)
            tankCannon.zRotation = CGFloat.pi * 3 / 2 // 270 degrees
        case .left:
            tankCannon.position = CGPoint(x: -halfTankWidth - cannonOffset, y: 0)
            tankCannon.zRotation = CGFloat.pi // 180 degrees
        case .right:
            tankCannon.position = CGPoint(x: halfTankWidth + cannonOffset, y: 0)
            tankCannon.zRotation = 0 // 0 degrees
        }
    }
    
    func updatePosition() {
        // Store last position to detect movement
        lastPosition = position
        
        // Move based on direction with smoother, proportional speed
        let moveSpeed = currentTankSize * 0.15  // 15% of tank size for smooth movement
        switch direction {
        case .up:
            position.y += moveSpeed
        case .down:
            position.y -= moveSpeed
        case .left:
            position.x -= moveSpeed
        case .right:
            position.x += moveSpeed
        }
        
        // Check if actually moved
        isMoving = (lastPosition != position)
        
        // Update animation frame if moving (slower animation for smoothness)
        if isMoving {
            animationFrameCounter += 1
            if animationFrameCounter >= 3 {  // Update every 3 frames for smoother animation
                animationFrame = (animationFrame + 1) % maxAnimationFrames
                animationFrameCounter = 0
            }
            updateWheelAnimation()
        }
        
        // Update cannon orientation when direction changes
        updateCannonPosition()
    }
    
    private func updateWheelAnimation() {
        guard isMoving else { return }
        
        // Use proportional values based on wider tank dimensions
        let tankHeight = currentTankSize
        let halfTankHeight = tankHeight / 2
        let wheelDistance: CGFloat = tankHeight / 4  // Same as in setupTracksAndWheels
        let animationRange = currentTankSize * 0.06  // Smaller animation range for smoother movement
        let animOffset = CGFloat(animationFrame * 2 % Int(animationRange))
        let reverseAnimOffset = animationRange - animOffset
        
        // Animate wheels based on direction
        switch direction {
        case .up, .down:
            let yOffset = direction == .up ? reverseAnimOffset : animOffset
            for i in 0..<leftWheels.count {
                let baseY = -halfTankHeight + CGFloat(i) * wheelDistance
                let animatedY = baseY + (yOffset * 0.3)  // Reduced intensity for smoother animation
                // Clamp to stay within tank bounds
                let clampedY = max(-halfTankHeight, min(halfTankHeight - wheelDistance, animatedY))
                leftWheels[i].position.y = clampedY
                rightWheels[i].position.y = clampedY
            }
        case .left, .right:
            // For horizontal movement, animate wheels vertically to simulate track rotation
            for i in 0..<leftWheels.count {
                let baseY = -halfTankHeight + CGFloat(i) * wheelDistance
                // Create a subtle vertical oscillation to simulate wheel rotation
                let rotationOffset = sin(CGFloat(animationFrame) * 0.5) * (wheelDistance * 0.1)
                let animatedY = baseY + rotationOffset
                let clampedY = max(-halfTankHeight, min(halfTankHeight - wheelDistance, animatedY))
                leftWheels[i].position.y = clampedY
                rightWheels[i].position.y = clampedY
            }
        }
        
        // Add track animation by slightly adjusting track positions
        animateTracks()
    }
    
    private func animateTracks() {
        guard isMoving, let leftTrack = leftTrack, let rightTrack = rightTrack else { return }
        
        let trackAnimationOffset = CGFloat(animationFrame % 4) * 0.5 // Small offset for track movement
        let baseLeftX = leftTrack.position.x
        let baseRightX = rightTrack.position.x
        
        switch direction {
        case .up, .down:
            // Slight horizontal oscillation for tracks during vertical movement
            leftTrack.position.x = baseLeftX + (direction == .up ? trackAnimationOffset : -trackAnimationOffset)
            rightTrack.position.x = baseRightX + (direction == .up ? -trackAnimationOffset : trackAnimationOffset)
        case .left, .right:
            // Slight vertical oscillation for tracks during horizontal movement  
            leftTrack.position.y = trackAnimationOffset * (direction == .left ? 1 : -1)
            rightTrack.position.y = trackAnimationOffset * (direction == .left ? -1 : 1)
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
        // Use wider rectangular physics body to match visual tank shape
        let tankWidth = size * 1.3  // 30% wider to match visual
        let tankHeight = size
        let tankSize = CGSize(width: tankWidth, height: tankHeight)
        
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
