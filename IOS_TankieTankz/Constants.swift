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
        
        // Use screen area to determine scale - modern phones have much more screen real estate
        // iPhone SE (375x667 = 250,125) should be scale 1.0
        // iPhone 14 (390x844 = 329,160) should be scale ~0.7-0.8 
        // iPhone 14 Pro Max (430x932 = 400,760) should be scale ~0.6-0.7
        let referenceArea: CGFloat = 250_000 // Base area for scaling
        let areaRatio = referenceArea / screenArea
        
        // Apply scaling with reasonable bounds
        return max(0.5, min(1.2, areaRatio))
    }
    
    // Scale a value based on current screen size
    static func scale(_ value: CGFloat) -> CGFloat {
        return value * scaleFactor
    }
    
    // Scale font sizes - use slightly different scaling for readability
    static func scaleFont(_ fontSize: CGFloat) -> CGFloat {
        // Fonts need less aggressive scaling to remain readable
        let fontScaleFactor = max(0.6, min(1.0, scaleFactor + 0.1))
        return fontSize * fontScaleFactor
    }
}

// MARK: - Tank Properties
struct TankConstants {
    // Base sizes (will be scaled for different screens)
    static let BASE_PLAYER_TANK_SIZE: CGFloat = 45
    static let BASE_ENEMY_TANK_SIZE: CGFloat = 45
    static let BASE_BOSS_TANK_SIZE: CGFloat = 65
    
    // Scaled sizes
    static var PLAYER_TANK_SIZE: CGFloat { ScreenScale.scale(BASE_PLAYER_TANK_SIZE) }
    static var ENEMY_TANK_SIZE: CGFloat { ScreenScale.scale(BASE_ENEMY_TANK_SIZE) }
    static var BOSS_TANK_SIZE: CGFloat { ScreenScale.scale(BASE_BOSS_TANK_SIZE) }
    
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
    // Base sizes
    static let BASE_BULLET_SIZE: CGFloat = 6
    static let BASE_MISSILE_SIZE: CGFloat = 8
    
    // Scaled sizes
    static var BULLET_SIZE: CGFloat { ScreenScale.scale(BASE_BULLET_SIZE) }
    static var MISSILE_SIZE: CGFloat { ScreenScale.scale(BASE_MISSILE_SIZE) }
    
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
