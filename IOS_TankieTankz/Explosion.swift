//
//  Explosion.swift
//  IOS_TankieTankz
//
//  Created by Joseph Mark Orimoloye on 4/24/25.
//

import SpriteKit

class Explosion: SKNode {
    private var currentFrame: Int = 0
    private let maxFrames: Int = 12
    private let frameDuration: TimeInterval = 0.05
    private var lastFrameTime: TimeInterval = 0
    private let radius: CGFloat = 50
    
    var isFinished: Bool = false
    
    private var explosionCircle: SKShapeNode!
    private var particleEmitter: SKEmitterNode?
    
    init(position: CGPoint) {
        super.init()
        self.position = position
        
        setupExplosion()
        setupParticleEmitter()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupExplosion() {
        // Create the initial explosion circle
        explosionCircle = SKShapeNode(circleOfRadius: 5)
        explosionCircle.fillColor = SKColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 1.0) // Orange
        explosionCircle.strokeColor = SKColor(red: 1.0, green: 0.4, blue: 0.0, alpha: 1.0) // Darker orange
        explosionCircle.lineWidth = 2.0
        addChild(explosionCircle)
        
        // Add glow effect
        addGlowEffect()
        
        // Set the initial frame time
        lastFrameTime = CACurrentMediaTime()
    }
    
    private func setupParticleEmitter() {
        // Create particle emitter for additional effect
        particleEmitter = SKEmitterNode()
        if let emitter = particleEmitter {
            emitter.particleBirthRate = 100
            emitter.numParticlesToEmit = 50
            emitter.particleLifetime = 0.5
            emitter.particleLifetimeRange = 0.25
            emitter.emissionAngleRange = CGFloat.pi * 2 // Full circle
            emitter.particleSpeed = 100
            emitter.particleSpeedRange = 50
            emitter.particleSize = CGSize(width: 5, height: 5)
            emitter.particleScale = 1.0
            emitter.particleScaleRange = 0.5
            emitter.particleScaleSpeed = -1.0 // Shrink over time
            emitter.particleAlpha = 1.0
            emitter.particleAlphaRange = 0.2
            emitter.particleAlphaSpeed = -2.0 // Fade out
            emitter.particleColor = SKColor(red: 1.0, green: 0.7, blue: 0.3, alpha: 1.0) // Orange-yellow
            emitter.particleColorBlendFactor = 1.0
            emitter.particleColorBlendFactorRange = 0.3
            emitter.particleColorBlendFactorSpeed = -1.0
            emitter.particleColorSequence = SKKeyframeSequence(keyframeValues: [
                SKColor(red: 1.0, green: 0.7, blue: 0.3, alpha: 1.0), // Orange-yellow
                SKColor(red: 1.0, green: 0.3, blue: 0.0, alpha: 1.0), // Red-orange
                SKColor(red: 0.6, green: 0.1, blue: 0.0, alpha: 0.8), // Dark red
                SKColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 0.5)  // Gray smoke
            ], times: [0.0, 0.25, 0.5, 1.0])
            
            addChild(emitter)
        }
    }
    
    private func addGlowEffect() {
        // Add glow to explosion only if performance allows
        if PerformanceSettings.ENABLE_GLOW_EFFECTS {
            let glowNode = SKEffectNode()
            glowNode.shouldRasterize = true
            glowNode.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius": 20])
            
            let glowCircle = SKShapeNode(circleOfRadius: 10)
            glowCircle.fillColor = SKColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 0.7) // Orange glow
            glowCircle.strokeColor = .clear
            
            glowNode.addChild(glowCircle)
            insertChild(glowNode, at: 0) // Insert below the explosion circle
        }
    }
    
    func update() {
        let currentTime = CACurrentMediaTime()
        let delta = currentTime - lastFrameTime
        
        // Update frames at the frame duration rate
        if delta >= frameDuration && !isFinished {
            currentFrame += 1
            lastFrameTime = currentTime
            
            // Update explosion size and appearance
            updateExplosionFrame()
            
            // Check if the explosion is finished
            if currentFrame >= maxFrames {
                isFinished = true
                // Stop particle emission
                particleEmitter?.particleBirthRate = 0
            }
        }
    }
    
    private func updateExplosionFrame() {
        // Calculate explosion radius based on frame
        let progress = CGFloat(currentFrame) / CGFloat(maxFrames)
        
        if progress < 0.5 {
            // Expand during first half of animation
            let currentRadius = radius * (progress * 2) // 0 to 1 times radius
            explosionCircle.path = CGPath(ellipseIn: CGRect(x: -currentRadius, y: -currentRadius, 
                                                          width: currentRadius * 2, height: currentRadius * 2), 
                                        transform: nil)
            
            // Increase opacity for expansion
            explosionCircle.fillColor = SKColor(red: 1.0, green: 0.6 - 0.3 * progress * 2, blue: 0.2 - 0.2 * progress * 2, alpha: 1.0)
            explosionCircle.strokeColor = SKColor(red: 1.0, green: 0.4 - 0.4 * progress * 2, blue: 0.0, alpha: 1.0)
        } else {
            // Fade out during second half of animation
            let fadeProgress = (progress - 0.5) * 2 // 0 to 1 for second half
            let currentRadius = radius
            explosionCircle.path = CGPath(ellipseIn: CGRect(x: -currentRadius, y: -currentRadius, 
                                                          width: currentRadius * 2, height: currentRadius * 2), 
                                        transform: nil)
            
            // Decrease opacity for fade out
            let alpha = 1.0 - fadeProgress
            explosionCircle.fillColor = SKColor(red: 1.0, green: 0.3, blue: 0.0, alpha: alpha)
            explosionCircle.strokeColor = SKColor(red: 1.0, green: 0.0, blue: 0.0, alpha: alpha)
        }
    }
}