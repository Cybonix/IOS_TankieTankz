import Foundation
import SpriteKit
import UIKit

// MARK: - Physics Categories for SpriteKit
struct PhysicsCategory {
    static let none: UInt32 = 0
    static let tank: UInt32 = 0x1 << 0
    static let bullet: UInt32 = 0x1 << 1  
    static let missile: UInt32 = 0x1 << 2
    static let powerUp: UInt32 = 0x1 << 3
    static let obstacle: UInt32 = 0x1 << 4
    static let boundary: UInt32 = 0x1 << 5
    static let player: UInt32 = 0x1 << 6
    static let enemy: UInt32 = 0x1 << 7
}

// MARK: - CGVector Extensions
extension CGVector {
    var magnitude: CGFloat {
        return sqrt(dx * dx + dy * dy)
    }
    
    var normalized: CGVector {
        let mag = magnitude
        return mag > 0 ? CGVector(dx: dx / mag, dy: dy / mag) : CGVector.zero
    }
    
    func rotated(by angle: CGFloat) -> CGVector {
        let cos = Foundation.cos(angle)
        let sin = Foundation.sin(angle)
        return CGVector(dx: dx * cos - dy * sin, dy: dx * sin + dy * cos)
    }
    
    static func +(left: CGVector, right: CGVector) -> CGVector {
        return CGVector(dx: left.dx + right.dx, dy: left.dy + right.dy)
    }
    
    static func -(left: CGVector, right: CGVector) -> CGVector {
        return CGVector(dx: left.dx - right.dx, dy: left.dy - right.dy)
    }
    
    static func *(vector: CGVector, scalar: CGFloat) -> CGVector {
        return CGVector(dx: vector.dx * scalar, dy: vector.dy * scalar)
    }
}

// MARK: - CGPoint Extensions
extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        let dx = x - point.x
        let dy = y - point.y
        return sqrt(dx * dx + dy * dy)
    }
    
    func angle(to point: CGPoint) -> CGFloat {
        return atan2(point.y - y, point.x - x)
    }
    
    func moved(by vector: CGVector) -> CGPoint {
        return CGPoint(x: x + vector.dx, y: y + vector.dy)
    }
    
    static func +(left: CGPoint, right: CGVector) -> CGPoint {
        return CGPoint(x: left.x + right.dx, y: left.y + right.dy)
    }
    
    static func -(left: CGPoint, right: CGPoint) -> CGVector {
        return CGVector(dx: left.x - right.x, dy: left.y - right.y)
    }
}

// MARK: - SKNode Extensions
extension SKNode {
    func addGlow(color: UIColor, radius: CGFloat) {
        let glow = SKEffectNode()
        let glowFilter = CIFilter(name: "CIGaussianBlur")
        glowFilter?.setValue(radius, forKey: "inputRadius")
        glow.filter = glowFilter
        
        let glowSprite = SKSpriteNode(texture: nil, color: color, size: frame.size)
        glow.addChild(glowSprite)
        
        insertChild(glow, at: 0)
    }
    
    func removeGlow() {
        children.compactMap { $0 as? SKEffectNode }.forEach { $0.removeFromParent() }
    }
}

// MARK: - SKSpriteNode Extensions  
extension SKSpriteNode {
    convenience init(color: UIColor, size: CGSize, cornerRadius: CGFloat = 0) {
        self.init(texture: nil, color: color, size: size)
        
        if cornerRadius > 0 {
            let path = UIBezierPath(roundedRect: CGRect(origin: CGPoint(x: -size.width/2, y: -size.height/2), size: size), cornerRadius: cornerRadius)
            let shape = SKShapeNode(path: path.cgPath)
            shape.fillColor = color
            shape.strokeColor = .clear
            texture = SKView().texture(from: shape)
        }
    }
}

// MARK: - Game Utility Functions
extension GameScene {
    func createParticleExplosion(at position: CGPoint, color: UIColor = .orange) {
        for _ in 0..<20 {
            let particle = SKSpriteNode(color: color, size: CGSize(width: 4, height: 4))
            particle.position = position
            
            let randomAngle = CGFloat.random(in: 0...2 * .pi)
            let randomSpeed = CGFloat.random(in: 50...150)
            let velocity = CGVector(dx: cos(randomAngle) * randomSpeed, dy: sin(randomAngle) * randomSpeed)
            
            let moveAction = SKAction.move(by: velocity, duration: 1.0)
            let fadeAction = SKAction.fadeOut(withDuration: 1.0)
            let scaleAction = SKAction.scale(to: 0.1, duration: 1.0)
            let removeAction = SKAction.removeFromParent()
            
            let particleSequence = SKAction.group([moveAction, fadeAction, scaleAction])
            let fullSequence = SKAction.sequence([particleSequence, removeAction])
            
            particle.run(fullSequence)
            addChild(particle)
        }
    }
    
    func screenShake(duration: TimeInterval = 0.1, intensity: CGFloat = 10) {
        let shakeLeft = SKAction.moveBy(x: -intensity, y: 0, duration: duration / 4)
        let shakeRight = SKAction.moveBy(x: intensity * 2, y: 0, duration: duration / 2)
        let shakeReturn = SKAction.moveBy(x: -intensity, y: 0, duration: duration / 4)
        
        let shakeSequence = SKAction.sequence([shakeLeft, shakeRight, shakeReturn])
        camera?.run(shakeSequence)
    }
}

// MARK: - Math Utilities
struct MathUtils {
    static func lerp(from: CGFloat, to: CGFloat, progress: CGFloat) -> CGFloat {
        return from + (to - from) * progress
    }
    
    static func clamp(_ value: CGFloat, min: CGFloat, max: CGFloat) -> CGFloat {
        return Swift.max(min, Swift.min(max, value))
    }
    
    static func degreesToRadians(_ degrees: CGFloat) -> CGFloat {
        return degrees * .pi / 180
    }
    
    static func radiansToDegrees(_ radians: CGFloat) -> CGFloat {
        return radians * 180 / .pi
    }
    
    static func randomBool() -> Bool {
        return Bool.random()
    }
    
    static func randomFloat(min: Float = 0, max: Float = 1) -> Float {
        return Float.random(in: min...max)
    }
}

// MARK: - Direction Enum (iOS equivalent of Android Direction enum)
enum Direction: CaseIterable {
    case up, down, left, right
    
    var vector: CGVector {
        switch self {
        case .up:
            return CGVector(dx: 0, dy: 1)
        case .down:
            return CGVector(dx: 0, dy: -1)
        case .left:
            return CGVector(dx: -1, dy: 0)
        case .right:
            return CGVector(dx: 1, dy: 0)
        }
    }
    
    var angle: CGFloat {
        switch self {
        case .up:
            return .pi / 2
        case .down:
            return -.pi / 2
        case .left:
            return .pi
        case .right:
            return 0
        }
    }
}

// MARK: - PowerUp Types (iOS equivalent)
enum PowerUpType: CaseIterable {
    case shieldBoost, rapidFire, damageBoost, extraLife, invincibility
    
    var duration: TimeInterval {
        switch self {
        case .shieldBoost:
            return GameConstants.SHIELD_DURATION
        case .rapidFire:
            return GameConstants.RAPID_FIRE_DURATION
        case .damageBoost:
            return GameConstants.DAMAGE_BOOST_DURATION
        case .invincibility:
            return GameConstants.INVINCIBILITY_DURATION
        case .extraLife:
            return 0 // Instant effect
        }
    }
    
    var color: UIColor {
        switch self {
        case .shieldBoost:
            return ColorScheme.POWER_UP_SHIELD
        case .rapidFire:
            return ColorScheme.POWER_UP_RAPID_FIRE
        case .damageBoost:
            return ColorScheme.POWER_UP_DAMAGE_BOOST
        case .extraLife:
            return ColorScheme.POWER_UP_EXTRA_LIFE
        case .invincibility:
            return ColorScheme.POWER_UP_INVINCIBILITY
        }
    }
}

// MARK: - Boss Types (iOS equivalent)
enum BossType: CaseIterable {
    case assault, miner, laser, stealth
    
    var colors: ColorScheme.BossColors {
        switch self {
        case .assault:
            return ColorScheme.BOSS_ASSAULT
        case .miner:
            return ColorScheme.BOSS_HEAVY
        case .laser:
            return ColorScheme.BOSS_SNIPER
        case .stealth:
            return ColorScheme.BOSS_SNIPER
        }
    }
    
    var maxHealth: Int {
        return GameConstants.BOSS_MAX_HEALTH
    }
}