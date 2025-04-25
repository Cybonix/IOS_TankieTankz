//
//  Constants.swift
//  IOS_TankieTankz
//
//  Created by Joseph Mark Orimoloye on 4/24/25.
//

import Foundation
import SpriteKit

// Define this flag to prevent duplicate definitions
// Swift doesn't use #define but we can achieve the same with conditional compilation
#if swift(>=5.0)
// This is just a marker to indicate that physics categories are defined in this file
#endif

// Physics categories for collision detection
struct PhysicsCategory {
    static let none: UInt32 = 0
    static let player: UInt32 = 0x1 << 0
    static let playerTank: UInt32 = 0x1 << 0  // Same as player for compatibility
    static let playerBullet: UInt32 = 0x1 << 1
    static let playerMissile: UInt32 = 0x1 << 2
    static let enemyTank: UInt32 = 0x1 << 3
    static let enemyBullet: UInt32 = 0x1 << 4
    static let powerUp: UInt32 = 0x1 << 5
    static let wall: UInt32 = 0x1 << 6
}

// Game constants
struct GameConstants {
    // Screen bounds adjustment for different devices
    static let horizontalMargin: CGFloat = 25.0
    static let verticalMargin: CGFloat = 25.0
    
    // Player constants
    static let playerStartLives: Int = 3
    static let playerInvulnerabilityDuration: TimeInterval = 3.0
    
    // Weapon constants
    static let normalBulletCooldown: TimeInterval = 0.3
    static let rapidFireCooldown: TimeInterval = 0.15
    static let missileFireCooldown: TimeInterval = 2.0
    
    // Power-up constants
    static let powerUpDuration: TimeInterval = 10.0
    static let shieldDuration: TimeInterval = 15.0
    
    // Game timing
    static let fixedTimestep: TimeInterval = 1.0 / 60.0  // 60 fps
}

// Notification names for game events
extension Notification.Name {
    static let gameDidPause = Notification.Name("GameShouldPause")
    static let gameDidResume = Notification.Name("GameShouldResume")
    static let gameShouldSaveState = Notification.Name("GameShouldSaveState")
    static let levelDidComplete = Notification.Name("LevelDidComplete")
    static let gameDidComplete = Notification.Name("GameDidComplete")
}