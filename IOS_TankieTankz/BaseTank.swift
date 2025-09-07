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
    
    // Cached dimensions for performance
    private var cachedTankWidth: CGFloat = 0
    private var cachedTankHeight: CGFloat = 0
    private var cachedHalfTankWidth: CGFloat = 0
    private var cachedHalfTankHeight: CGFloat = 0
    private var cachedWheelWidth: CGFloat = 0
    private var cachedWheelOffset: CGFloat = 0
    
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
        
        // Cache dimensions for performance
        cachedTankWidth = tankSize * 1.3
        cachedTankHeight = tankSize
        cachedHalfTankWidth = cachedTankWidth / 2
        cachedHalfTankHeight = cachedTankHeight / 2
        cachedWheelWidth = tankSize * 0.12   // Match the new smaller wheels
        cachedWheelOffset = tankSize * 0.015  // Much closer to tank body - 1.5%
        
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
        let wheelWidth = tankSize * 0.12   // Slightly smaller for better fit
        let wheelHeight = tankSize * 0.12  // Match width for square wheels
        let wheelOffset = tankSize * 0.015  // Even closer to body - 1.5%
        
        // Create tracks that will rotate with tank direction
        setupRotatingTracks(tankNode: tankNode, tankWidth: tankWidth, tankHeight: tankHeight, 
                           wheelOffset: wheelOffset, wheelWidth: wheelWidth, trackColor: trackColor)
        
        // Create wheels that rotate with tank direction  
        setupRotatingWheels(tankNode: tankNode, tankWidth: tankWidth, tankHeight: tankHeight,
                           wheelOffset: wheelOffset, wheelWidth: wheelWidth, wheelHeight: wheelHeight, wheelColor: wheelColor)
    }
    
    private func setupRotatingTracks(tankNode: SKNode, tankWidth: CGFloat, tankHeight: CGFloat, 
                                   wheelOffset: CGFloat, wheelWidth: CGFloat, trackColor: SKColor) {
        // Create tracks based on tank orientation - always perpendicular to movement direction
        let trackLength = max(tankWidth, tankHeight)  // Use longer dimension for track length
        let trackWidth = wheelWidth
        
        // Create left track
        leftTrack = SKShapeNode(rectOf: CGSize(width: trackWidth, height: trackLength))
        leftTrack.fillColor = trackColor
        leftTrack.strokeColor = trackColor
        tankNode.addChild(leftTrack)
        
        // Create right track  
        rightTrack = SKShapeNode(rectOf: CGSize(width: trackWidth, height: trackLength))
        rightTrack.fillColor = trackColor
        rightTrack.strokeColor = trackColor
        tankNode.addChild(rightTrack)
        
        // Position tracks based on initial direction
        updateTrackPositions()
    }
    
    private func setupRotatingWheels(tankNode: SKNode, tankWidth: CGFloat, tankHeight: CGFloat,
                                   wheelOffset: CGFloat, wheelWidth: CGFloat, wheelHeight: CGFloat, wheelColor: SKColor) {
        // Create 5 wheels per side (will be repositioned based on direction)
        for i in 0..<5 {
            // Left wheel
            let leftWheel = SKShapeNode(rectOf: CGSize(width: wheelWidth, height: wheelHeight))
            leftWheel.fillColor = wheelColor
            leftWheel.strokeColor = wheelColor
            tankNode.addChild(leftWheel)
            leftWheels.append(leftWheel)
            
            // Right wheel
            let rightWheel = SKShapeNode(rectOf: CGSize(width: wheelWidth, height: wheelHeight))
            rightWheel.fillColor = wheelColor
            rightWheel.strokeColor = wheelColor
            tankNode.addChild(rightWheel)
            rightWheels.append(rightWheel)
        }
        
        // Position wheels based on initial direction
        updateWheelPositions()
    }
    
    private func updateTrackPositions() {
        guard let leftTrack = leftTrack, let rightTrack = rightTrack else { return }
        
        let trackOffset = cachedWheelOffset + cachedWheelWidth/2
        
        switch direction {
        case .up, .down:
            // Vertical movement - tracks on left and right sides
            leftTrack.position = CGPoint(x: -cachedHalfTankWidth - trackOffset, y: 0)
            rightTrack.position = CGPoint(x: cachedHalfTankWidth + trackOffset, y: 0)
            leftTrack.zRotation = 0  // Vertical orientation
            rightTrack.zRotation = 0
            
        case .left, .right:
            // Horizontal movement - tracks on top and bottom
            leftTrack.position = CGPoint(x: 0, y: cachedHalfTankHeight + trackOffset)
            rightTrack.position = CGPoint(x: 0, y: -cachedHalfTankHeight - trackOffset)
            leftTrack.zRotation = CGFloat.pi / 2  // Horizontal orientation
            rightTrack.zRotation = CGFloat.pi / 2
        }
    }
    
    private func updateWheelPositions() {
        let wheelSpacing = max(cachedTankWidth, cachedTankHeight) / CGFloat(leftWheels.count + 1)
        let wheelOffset = cachedWheelOffset
        
        switch direction {
        case .up, .down:
            // Wheels arranged vertically along the sides
            for i in 0..<leftWheels.count {
                let yPos = -cachedHalfTankHeight + CGFloat(i + 1) * wheelSpacing
                leftWheels[i].position = CGPoint(x: -cachedHalfTankWidth - wheelOffset, y: yPos)
                rightWheels[i].position = CGPoint(x: cachedHalfTankWidth + wheelOffset, y: yPos)
            }
            
        case .left, .right:
            // Wheels arranged horizontally along top and bottom
            for i in 0..<leftWheels.count {
                let xPos = -cachedHalfTankWidth + CGFloat(i + 1) * wheelSpacing
                leftWheels[i].position = CGPoint(x: xPos, y: cachedHalfTankHeight + wheelOffset)
                rightWheels[i].position = CGPoint(x: xPos, y: -cachedHalfTankHeight - wheelOffset)
            }
        }
    }
    
    private func updateCannonPosition() {
        guard tankCannon != nil, currentTankSize > 0 else { return }
        
        // Use cached dimensions for performance
        let cannonOffset = currentTankSize * 0.2  // 20% of tank size
        
        switch direction {
        case .up:
            tankCannon.position = CGPoint(x: 0, y: cachedHalfTankHeight + cannonOffset)  // Above tank
            tankCannon.zRotation = CGFloat.pi / 2 // 90 degrees
        case .down:
            tankCannon.position = CGPoint(x: 0, y: -cachedHalfTankHeight - cannonOffset)  // Below tank
            tankCannon.zRotation = CGFloat.pi * 3 / 2 // 270 degrees
        case .left:
            tankCannon.position = CGPoint(x: -cachedHalfTankWidth - cannonOffset, y: 0)
            tankCannon.zRotation = CGFloat.pi // 180 degrees
        case .right:
            tankCannon.position = CGPoint(x: cachedHalfTankWidth + cannonOffset, y: 0)
            tankCannon.zRotation = 0 // 0 degrees
        }
        
        // Update tracks and wheels to match new direction
        updateTrackPositions()
        updateWheelPositions()
    }
    
    func updatePosition() {
        // Store last position to detect movement
        lastPosition = position
        
        // Move based on direction with smoother, proportional speed
        let moveSpeed = max(1, currentTankSize * 0.15)  // 15% of tank size for smooth movement, minimum 1
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
        guard isMoving, currentTankSize > 0 else { 
            // Reset to base positions when not moving
            updateWheelPositions()
            return 
        }
        
        let animationIntensity: CGFloat = 0.3  // Reduced for smoother animation
        let animationOffset = sin(CGFloat(animationFrame) * 0.5) * animationIntensity
        
        // Animate wheels based on current direction and track layout
        switch direction {
        case .up, .down:
            // Wheels along the sides - animate vertically
            let wheelSpacing = cachedTankHeight / CGFloat(leftWheels.count + 1)
            for i in 0..<leftWheels.count {
                let baseY = -cachedHalfTankHeight + CGFloat(i + 1) * wheelSpacing
                let animatedY = baseY + (direction == .up ? animationOffset : -animationOffset)
                
                leftWheels[i].position = CGPoint(x: -cachedHalfTankWidth - cachedWheelOffset, y: animatedY)
                rightWheels[i].position = CGPoint(x: cachedHalfTankWidth + cachedWheelOffset, y: animatedY)
            }
            
        case .left, .right:
            // Wheels along top/bottom - animate horizontally  
            let wheelSpacing = cachedTankWidth / CGFloat(leftWheels.count + 1)
            for i in 0..<leftWheels.count {
                let baseX = -cachedHalfTankWidth + CGFloat(i + 1) * wheelSpacing
                let animatedX = baseX + (direction == .right ? animationOffset : -animationOffset)
                
                leftWheels[i].position = CGPoint(x: animatedX, y: cachedHalfTankHeight + cachedWheelOffset)
                rightWheels[i].position = CGPoint(x: animatedX, y: -cachedHalfTankHeight - cachedWheelOffset)
            }
        }
        
        // Add subtle track animation
        animateTracks()
    }
    
    private func animateTracks() {
        guard isMoving, let leftTrack = leftTrack, let rightTrack = rightTrack else { 
            // Reset track positions when not moving
            updateTrackPositions()
            return 
        }
        
        let trackAnimationOffset = CGFloat(animationFrame % max(4, 1)) * 0.2 // Subtle movement
        let trackOffset = cachedWheelOffset + cachedWheelWidth/2
        
        switch direction {
        case .up, .down:
            // Tracks on sides - slight horizontal oscillation
            let baseLeftX = -cachedHalfTankWidth - trackOffset
            let baseRightX = cachedHalfTankWidth + trackOffset
            
            leftTrack.position = CGPoint(
                x: baseLeftX + (direction == .up ? trackAnimationOffset : -trackAnimationOffset), 
                y: 0
            )
            rightTrack.position = CGPoint(
                x: baseRightX + (direction == .up ? -trackAnimationOffset : trackAnimationOffset), 
                y: 0
            )
            
        case .left, .right:
            // Tracks on top/bottom - slight vertical oscillation
            let baseTopY = cachedHalfTankHeight + trackOffset
            let baseBottomY = -cachedHalfTankHeight - trackOffset
            
            leftTrack.position = CGPoint(
                x: 0, 
                y: baseTopY + (direction == .right ? trackAnimationOffset : -trackAnimationOffset)
            )
            rightTrack.position = CGPoint(
                x: 0, 
                y: baseBottomY + (direction == .right ? -trackAnimationOffset : trackAnimationOffset)
            )
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
            physicsBody?.collisionBitMask = PhysicsCategory.wall | PhysicsCategory.enemyTank  // Add enemy tank collision
        } else {
            physicsBody?.categoryBitMask = PhysicsCategory.enemyTank
            physicsBody?.contactTestBitMask = PhysicsCategory.playerBullet | PhysicsCategory.playerMissile | PhysicsCategory.playerTank
            physicsBody?.collisionBitMask = PhysicsCategory.wall | PhysicsCategory.playerTank  // Only collision with wall and player tank
        }
    }
}
