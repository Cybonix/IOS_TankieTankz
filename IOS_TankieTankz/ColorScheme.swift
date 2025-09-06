import UIKit

/**
 * Centralized color management for the TankieTankz iOS game.
 * Provides consistent color schemes across all biomes and game elements.
 * Ported from Android Kotlin to Swift for iOS development.
 */
struct ColorScheme {
    
    // MARK: - Boss Tank Colors
    struct BossColors {
        let primary: UIColor
        let secondary: UIColor
        let accent: UIColor
    }
    
    static let BOSS_ASSAULT = BossColors(
        primary: UIColor(red: 30/255, green: 180/255, blue: 255/255, alpha: 1.0),   // Bright cyan
        secondary: UIColor(red: 0/255, green: 240/255, blue: 240/255, alpha: 1.0),  // Cyan glow
        accent: UIColor(red: 0/255, green: 60/255, blue: 120/255, alpha: 1.0)       // Dark blue accent
    )
    
    static let BOSS_HEAVY = BossColors(
        primary: UIColor(red: 255/255, green: 100/255, blue: 100/255, alpha: 1.0),  // Light red
        secondary: UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 1.0),    // Bright red
        accent: UIColor(red: 120/255, green: 0/255, blue: 0/255, alpha: 1.0)        // Dark red accent
    )
    
    static let BOSS_SNIPER = BossColors(
        primary: UIColor(red: 150/255, green: 100/255, blue: 255/255, alpha: 1.0),  // Purple
        secondary: UIColor(red: 200/255, green: 150/255, blue: 255/255, alpha: 1.0), // Light purple
        accent: UIColor(red: 75/255, green: 0/255, blue: 150/255, alpha: 1.0)       // Dark purple accent
    )
    
    // MARK: - Biome-based Colors
    
    // Player Bullet Colors by Biome
    static func getPlayerBulletColor(biome: BiomeType) -> UIColor {
        switch biome {
        case .urban:
            return UIColor(red: 255/255, green: 255/255, blue: 0/255, alpha: 1.0)     // Bright yellow
        case .desert:
            return UIColor(red: 0/255, green: 200/255, blue: 0/255, alpha: 1.0)       // Bright green
        case .snow:
            return UIColor(red: 0/255, green: 255/255, blue: 255/255, alpha: 1.0)     // Cyan
        case .volcanic:
            return UIColor(red: 255/255, green: 100/255, blue: 0/255, alpha: 1.0)     // Orange
        }
    }
    
    // Enemy Bullet Colors by Biome
    static func getEnemyBulletColor(biome: BiomeType) -> UIColor {
        return UIColor.red // All biomes use red for enemy bullets
    }
    
    // Missile Colors by Biome
    static func getMissileBodyColor(biome: BiomeType) -> UIColor {
        switch biome {
        case .urban:
            return UIColor(red: 255/255, green: 255/255, blue: 0/255, alpha: 1.0)     // Bright yellow
        case .desert:
            return UIColor(red: 200/255, green: 0/255, blue: 0/255, alpha: 1.0)       // Dark red
        case .snow:
            return UIColor(red: 180/255, green: 0/255, blue: 0/255, alpha: 1.0)       // Darker red
        case .volcanic:
            return UIColor(red: 255/255, green: 255/255, blue: 100/255, alpha: 1.0)   // Lighter yellow
        }
    }
    
    static func getMissileExhaustColor(biome: BiomeType) -> UIColor {
        switch biome {
        case .urban, .volcanic:
            return UIColor(red: 0/255, green: 220/255, blue: 255/255, alpha: 1.0)     // Bright cyan
        case .desert:
            return UIColor(red: 0/255, green: 0/255, blue: 180/255, alpha: 1.0)       // Very dark blue
        case .snow:
            return UIColor(red: 0/255, green: 0/255, blue: 150/255, alpha: 1.0)       // Even darker blue
        }
    }
    
    static func getMissileSmokeColor(biome: BiomeType) -> UIColor {
        switch biome {
        case .urban, .volcanic:
            return UIColor(red: 170/255, green: 170/255, blue: 255/255, alpha: 1.0)   // Light blue
        case .desert:
            return UIColor(red: 50/255, green: 50/255, blue: 120/255, alpha: 1.0)     // Very dark blue-gray
        case .snow:
            return UIColor(red: 30/255, green: 30/255, blue: 100/255, alpha: 1.0)     // Almost black-blue
        }
    }
    
    // Glow Colors by Biome
    static func getGlowColor(biome: BiomeType, isExhaust: Bool = false) -> UIColor {
        switch biome {
        case .urban, .volcanic:
            return isExhaust ? UIColor.cyan : UIColor.white
        case .desert:
            return isExhaust ? UIColor(red: 0/255, green: 0/255, blue: 100/255, alpha: 1.0) : UIColor(red: 120/255, green: 0/255, blue: 0/255, alpha: 1.0)
        case .snow:
            return isExhaust ? UIColor(red: 0/255, green: 0/255, blue: 80/255, alpha: 1.0) : UIColor(red: 100/255, green: 0/255, blue: 0/255, alpha: 1.0)
        }
    }
    
    // MARK: - Health Bar Colors
    static let HEALTH_BAR_EMPTY = UIColor.darkGray
    static let HEALTH_BAR_FULL = UIColor.red
    static let HEALTH_BAR_BORDER = UIColor.black
    static let HEALTH_BAR_BOSS_FULL = UIColor(red: 255/255, green: 100/255, blue: 100/255, alpha: 1.0)
    
    // MARK: - Power-up Colors
    static let POWER_UP_SHIELD = UIColor.blue
    static let POWER_UP_RAPID_FIRE = UIColor.red
    static let POWER_UP_DAMAGE_BOOST = UIColor.orange
    static let POWER_UP_EXTRA_LIFE = UIColor.green
    static let POWER_UP_INVINCIBILITY = UIColor.magenta
    
    // MARK: - UI Colors
    static let UI_BACKGROUND = UIColor.black
    static let UI_TEXT = UIColor.white
    static let UI_BORDER = UIColor.gray
    static let UI_HIGHLIGHT = UIColor.yellow
    
    // MARK: - Obstacle Colors
    static let OBSTACLE_ROCK = UIColor(red: 60/255, green: 60/255, blue: 70/255, alpha: 1.0)         // Dark gray-blue
    static let OBSTACLE_SNOW_CAP = UIColor(red: 240/255, green: 240/255, blue: 255/255, alpha: 1.0)  // Light blue-white
    
    // MARK: - Effect Colors
    static let EXPLOSION_INNER = UIColor.yellow
    static let EXPLOSION_OUTER = UIColor.red
    static let HIT_FLASH = UIColor.white
}