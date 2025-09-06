//
//  Constants.swift
//  IOS_TankieTankz
//
//  Created by Joseph Mark Orimoloye on 4/24/25.
//

import Foundation
import SpriteKit
import UIKit

// MARK: - Screen Scaling
struct ScreenScale {
    // Get current screen scale factor - more aggressive scaling for modern phones
    static var scaleFactor: CGFloat {
        let screenBounds = UIScreen.main.bounds
        let screenArea = screenBounds.width * screenBounds.height
        
        // Debug logging
        print("📱 Screen bounds: \(screenBounds.width) x \(screenBounds.height)")
        print("📐 Screen area: \(screenArea)")
        
        // Use very aggressive scaling - everything needs to be much smaller
        // iPhone SE (375pt) = 0.7 scale (even iPhone SE objects were too big)
        // iPhone 14 (390pt) = ~0.5 scale 
        // iPhone Pro Max (430pt) = ~0.4 scale
        let referenceWidth: CGFloat = 300 // Much smaller reference
        let widthRatio = referenceWidth / screenBounds.width
        let scaleFactor = max(0.3, min(0.7, widthRatio))
        
        print("🔧 Scale factor: \(scaleFactor)")
        return scaleFactor
    }
    
    // Scale a value based on current screen size
    static func scale(_ value: CGFloat) -> CGFloat {
        return value * scaleFactor
    }
    
    // Scale font sizes based on screen width percentage
    static func scaleFont(_ fontSize: CGFloat) -> CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        // Map font sizes to percentages of screen width
        let percentage: CGFloat = switch fontSize {
        case 48: 0.08  // Large titles (Game Over, Victory) = 8% of screen width
        case 42: 0.07  // Big text = 7% of screen width
        case 36: 0.065 // Medium-large text = 6.5% of screen width
        case 28: 0.055 // Medium text = 5.5% of screen width
        case 24: 0.045 // Small text (HUD) = 4.5% of screen width
        case 22: 0.04  // Very small text = 4% of screen width
        default: fontSize / screenWidth // Fallback: use original as percentage
        }
        
        let scaledSize = screenWidth * percentage
        print("🔤 Font \(fontSize)pt -> \(scaledSize)pt (\(percentage * 100)% of \(screenWidth)pt width)")
        return max(8, scaledSize) // Minimum readable size
    }
}

// MARK: - Tank Properties
struct TankConstants {
    // Directly specify sizes for modern phones - no more scaling calculation issues
    static var PLAYER_TANK_SIZE: CGFloat { 
        let screenWidth = UIScreen.main.bounds.width
        // Tanks should be about 8% of screen width
        return max(15, screenWidth * 0.08)
    }
    
    static var ENEMY_TANK_SIZE: CGFloat { 
        let screenWidth = UIScreen.main.bounds.width
        return max(15, screenWidth * 0.08)
    }
    
    static var BOSS_TANK_SIZE: CGFloat { 
        let screenWidth = UIScreen.main.bounds.width
        return max(20, screenWidth * 0.12)
    }
    
    static let BOSS_SCALE_FACTOR: CGFloat = 1.5
    static var TANK_CENTER_OFFSET: CGFloat { ScreenScale.scale(25) }
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
    // Direct sizes based on screen width
    static var BULLET_SIZE: CGFloat { 
        let screenWidth = UIScreen.main.bounds.width
        return max(3, screenWidth * 0.015) // 1.5% of screen width
    }
    
    static var MISSILE_SIZE: CGFloat { 
        let screenWidth = UIScreen.main.bounds.width
        return max(4, screenWidth * 0.02) // 2% of screen width
    }
    
    // Speeds (don't scale these as they're movement rates)
    static let BULLET_SPEED: CGFloat = 12
    static let MISSILE_SPEED: CGFloat = 8
    static let MISSILE_MAX_LIFETIME: TimeInterval = 10.0
    static let RAPID_FIRE_INTERVAL: TimeInterval = 0.1
    static let NORMAL_FIRE_INTERVAL: TimeInterval = 0.3
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
