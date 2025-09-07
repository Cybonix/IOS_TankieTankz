//
//  Constants.swift
//  IOS_TankieTankz
//
//  Created by Joseph Mark Orimoloye on 4/24/25.
//

import Foundation
import SpriteKit
import UIKit

// MARK: - Game Types

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

enum BiomeType: Int, CaseIterable {
    case urban = 0
    case desert = 1
    case snow = 2
    case volcanic = 3
}

// MARK: - Physics Categories

struct PhysicsCategory {
    static let none: UInt32 = 0
    static let wall: UInt32 = 0b1
    static let playerTank: UInt32 = 0b10
    static let enemyTank: UInt32 = 0b100
    static let playerBullet: UInt32 = 0b1000
    static let enemyBullet: UInt32 = 0b10000
    static let powerUp: UInt32 = 0b100000
    static let playerMissile: UInt32 = 0b1000000
}

// MARK: - Screen Scaling
struct ScreenScale {
    // Get current screen scale factor - more aggressive scaling for modern phones
    static var scaleFactor: CGFloat {
        let screenBounds = UIScreen.main.bounds
        
        // Ultra-aggressive scaling - everything needs to be much smaller for modern iPhones
        // iPhone SE (375pt) = 0.4 scale
        // iPhone 14 (390pt) = ~0.35 scale 
        // iPhone Pro Max (430pt) = ~0.25 scale
        let referenceWidth: CGFloat = 150 // Much smaller reference for ultra-small scaling
        let widthRatio = referenceWidth / screenBounds.width
        let scaleFactor = max(0.2, min(0.5, widthRatio))
        
        return scaleFactor
    }
    
    // Scale a value based on current screen size
    static func scale(_ value: CGFloat) -> CGFloat {
        return value * scaleFactor
    }
    
    // Scale font sizes based on screen width percentage - much smaller for modern iPhones
    static func scaleFont(_ fontSize: CGFloat) -> CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        // Map font sizes to percentages of screen width - increased for better readability
        let percentage: CGFloat = switch fontSize {
        case 48: 0.07  // Large titles (Game Over, Victory) = 7% of screen width
        case 42: 0.06  // Big text = 6% of screen width  
        case 36: 0.055 // Medium-large text = 5.5% of screen width
        case 28: 0.05  // Medium text = 5% of screen width
        case 24: 0.045 // Small text (HUD) = 4.5% of screen width
        case 22: 0.035 // Very small text = 3.5% of screen width
        default: fontSize / screenWidth // Fallback: use original as percentage
        }
        
        let scaledSize = screenWidth * percentage
        return max(8, scaledSize) // Minimum readable size
    }
}

// MARK: - Tank Properties
struct TankConstants {
    // Well-sized tanks for good visibility and gameplay on modern iPhones
    static var PLAYER_TANK_SIZE: CGFloat { 
        let screenWidth = UIScreen.main.bounds.width
        // Tanks should be about 5% of screen width for good visibility
        return max(15, screenWidth * 0.05)
    }
    
    static var ENEMY_TANK_SIZE: CGFloat { 
        let screenWidth = UIScreen.main.bounds.width
        return max(15, screenWidth * 0.05)
    }
    
    static var BOSS_TANK_SIZE: CGFloat { 
        let screenWidth = UIScreen.main.bounds.width
        return max(18, screenWidth * 0.075)
    }
    
    static let BOSS_SCALE_FACTOR: CGFloat = 1.5
    static var TANK_CENTER_OFFSET: CGFloat { 
        let screenWidth = UIScreen.main.bounds.width
        return max(8, screenWidth * 0.02) // 2% of screen width
    }
}

// MARK: - Health and Combat
struct CombatConstants {
    static let HIT_FLASH_DURATION: TimeInterval = 0.2
    static let PLAYER_MAX_HEALTH = 100
    static let ENEMY_MAX_HEALTH = 100
    static let BOSS_MAX_HEALTH = 150
    static let DEFAULT_BULLET_DAMAGE = 10
    static let ENHANCED_BULLET_DAMAGE = 15
    static let BOSS_BULLET_DAMAGE = 20
    static let COLLISION_DAMAGE_TO_BOSS = 75
    static let INVULNERABILITY_TIME: TimeInterval = 1.0
}

// MARK: - Weapon Properties
struct WeaponConstants {
    // Much smaller bullets and missiles for better gameplay
    static var BULLET_SIZE: CGFloat { 
        let screenWidth = UIScreen.main.bounds.width
        return max(2, screenWidth * 0.008) // 0.8% of screen width (was 1.5% - too big)
    }
    
    static var MISSILE_SIZE: CGFloat { 
        let screenWidth = UIScreen.main.bounds.width
        return max(3, screenWidth * 0.012) // 1.2% of screen width (was 2% - too big)
    }
    
    // Speeds (reduced for slower, smoother gameplay)
    static let BULLET_SPEED: CGFloat = 6  // Reduced from 12 for slower gameplay
    static let MISSILE_SPEED: CGFloat = 4  // Reduced from 8 for slower gameplay
    static let MISSILE_MAX_LIFETIME: TimeInterval = 15.0  // Increased to compensate for slower speed
    static let RAPID_FIRE_INTERVAL: TimeInterval = 0.15  // Slightly slower rapid fire
    static let NORMAL_FIRE_INTERVAL: TimeInterval = 0.5   // Slower normal firing
    static let SMOKE_INTERVAL: TimeInterval = 0.05
    static let SMOKE_PARTICLE_MAX_AGE: TimeInterval = 0.5
}

// MARK: - Power-up System
struct PowerUpConstants {
    static let MAX_ACTIVE_POWERUPS = 3
    static let MAX_COLLECTED_POWERUPS = 5
    static let HEALTH_THRESHOLD_FOR_POWERUP = 85
    static let SHIELD_DURATION: TimeInterval = 8.0
    static let RAPID_FIRE_DURATION: TimeInterval = 6.0
    static let DAMAGE_BOOST_DURATION: TimeInterval = 5.0
    static let INVINCIBILITY_DURATION: TimeInterval = 3.0
}

// MARK: - Level Configuration
struct LevelConstants {
    static let MAX_LEVELS = 12
    static let BOSS_LEVELS = [4, 8, 12]
    static let MAX_LIVES = 3
    static let SCORE_PER_ENEMY_KILL = 20
    
    static let ENEMIES_PER_LEVEL = [
        0, // Level 0 (unused)
        3, // Level 1
        4, // Level 2
        5, // Level 3
        1, // Level 4 (Boss)
        6, // Level 5
        7, // Level 6
        8, // Level 7
        1, // Level 8 (Boss)
        9, // Level 9
        10, // Level 10
        11, // Level 11
        1  // Level 12 (Final Boss)
    ]
}

// MARK: - Screen and Effects
struct DisplayConstants {
    static let SCREEN_MARGIN: CGFloat = 100
    static let OFF_SCREEN_REMOVAL_DISTANCE: CGFloat = 20
    static let OBSTACLE_SIZE: CGFloat = 80
    static let EXPLOSION_DURATION: TimeInterval = 0.5
    static let GLOW_EFFECT_RADIUS: CGFloat = 15
    static let SHADOW_LAYER_SIZE: CGFloat = 5
    static let ANIMATION_FRAME_CYCLE = 3
}

// MARK: - iOS Specific
struct iOSConstants {
    static let TARGET_FPS = 60.0
    static let TOUCH_SENSITIVITY: CGFloat = 1.0
    static let JOYSTICK_DEAD_ZONE: CGFloat = 0.1
    static let HAPTIC_FEEDBACK_INTENSITY: Float = 0.5
    static let FIXED_TIMESTEP: TimeInterval = 1.0 / 60.0
}

// MARK: - Performance Settings
struct PerformanceSettings {
    // Disable expensive visual effects for better performance on older devices
    static let ENABLE_GLOW_EFFECTS = false  // Set to false for smoother gameplay
    static let ENABLE_BLUR_EFFECTS = false  // Set to false for better performance
}
