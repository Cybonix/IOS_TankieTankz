# IOS TankieTankz 🎮

[![Swift](https://img.shields.io/badge/Swift-5.0+-orange.svg)](https://swift.org)
[![iOS](https://img.shields.io/badge/iOS-13.0+-blue.svg)](https://developer.apple.com/ios/)
[![SpriteKit](https://img.shields.io/badge/SpriteKit-Framework-green.svg)](https://developer.apple.com/spritekit/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

A modern iOS tank battle game built with SpriteKit featuring dynamic biomes, power-ups, boss battles, and smooth gameplay mechanics.

## 🎯 Game Features

### ✨ Core Gameplay
- **Tank Combat System**: Player vs AI tanks with intelligent enemy behavior
- **Multiple Weapon Types**: Standard bullets and guided missiles
- **Power-Up System**: Shield, rapid fire, damage boost, and invincibility
- **Health System**: Visual health bars and hit effects
- **Lives System**: 3 lives with visual heart indicators

### 🌍 Dynamic Biomes
- **Urban**: Levels 1-3 with city environments
- **Desert**: Levels 5-7 with sandy battlefields  
- **Snow**: Levels 9-11 with winter landscapes
- **Volcanic**: Boss levels (4, 8, 12) with lava themes

### 🎮 Advanced Features
- **Boss Battles**: Special tank encounters on levels 4, 8, and 12
- **Responsive Controls**: Touch-based movement and firing
- **Sound System**: CAF audio files for immersive experience
- **Performance Optimized**: 60 FPS gameplay with cached calculations
- **Cross-Device Scaling**: Percentage-based UI for all iPhone sizes

## 🏗️ Technical Architecture

### Core Components
```
IOS_TankieTankz/
├── GameScene.swift          # Main game logic and scene management
├── BaseTank.swift          # Tank entity with visuals and physics
├── Bullet.swift            # Projectile system with biome-specific colors
├── Missile.swift           # Guided missile implementation
├── PowerUp.swift           # Power-up system and effects
├── SoundManager.swift      # Audio management (CAF files)
├── Constants.swift         # Game constants and scaling
└── Assets/                 # Audio files and resources
```

### Key Systems

#### Tank System (`BaseTank.swift`)
- **Wider Tank Design**: 1.3x width ratio for better appearance
- **Animated Tracks**: Smooth wheel and track animations
- **Performance Cached**: Dimensions cached to prevent recalculation
- **Direction-Aware**: Cannon positioning based on movement direction

#### Physics System
- **Collision Detection**: Proper bullet-tank collision with rectangular physics bodies
- **Category-Based**: Separate physics categories for players, enemies, bullets
- **Boundary Management**: Tanks stay within screen bounds with proper margins

#### UI System
- **Percentage-Based Scaling**: All UI elements scale based on screen width
- **HUD Layout**: Score, level, lives (hearts), and health bar
- **Responsive Buttons**: 60% width x 12% height touch targets
- **Font Scaling**: Dynamic font sizing (3.5% - 7% of screen width)

## 🚀 Current Status (January 2025)

### ✅ Completed Features
- [x] Core tank movement and combat
- [x] Bullet physics and collision detection  
- [x] Power-up system with visual effects
- [x] Multi-biome background system
- [x] Boss battle mechanics
- [x] Sound integration (CAF files)
- [x] Performance optimizations
- [x] UI scaling and responsiveness
- [x] Tank track animations
- [x] Smooth gameplay mechanics

### 🎯 Recent Major Fixes (Latest Session)
- [x] **Division by Zero Fix**: Prevented game crashes in animation calculations
- [x] **Bullet Direction**: Fixed backwards shooting, bullets now spawn from cannon tips
- [x] **Tank Tracks**: Moved tracks closer to tank body (2% offset instead of 5%)
- [x] **Cannon Positioning**: Corrected up/down cannon directions in SpriteKit coordinates
- [x] **Performance**: Cached tank dimensions to eliminate calculation overhead
- [x] **Track Animation**: Fixed floating tracks with proper base position resets

### 🔧 Technical Improvements
- **Animation System**: 8 frames with 3-frame intervals for smoother movement
- **Physics Bodies**: Rectangular shapes matching wider tank visuals (1.3x width)
- **Memory Optimization**: Cached frequently-calculated values
- **Error Prevention**: Guards against zero values in modulo operations

## 📱 Device Compatibility

### Supported Devices
- **iPhone SE**: 375pt width → 0.4 scale factor
- **iPhone 14**: 390pt width → ~0.35 scale factor  
- **iPhone Pro Max**: 430pt width → ~0.25 scale factor

### Scaling Constants
```swift
// Tank sizes: 5% of screen width
PLAYER_TANK_SIZE: max(15, screenWidth * 0.05)
ENEMY_TANK_SIZE: max(15, screenWidth * 0.05) 
BOSS_TANK_SIZE: max(18, screenWidth * 0.075)

// Font sizes: 3.5% - 7% of screen width
HUD_FONT: screenWidth * 0.045 (4.5%)
TITLE_FONT: screenWidth * 0.07 (7%)
```

## 🎮 Gameplay Mechanics

### Controls
- **Movement**: Touch and drag to move tank in 4 directions
- **Firing**: Touch screen to fire bullets in movement direction
- **Power-ups**: Automatic collection on contact

### Progression
- **12 Levels Total**: 3 levels per biome + boss levels
- **Enemy Count**: Increases from 3 (Level 1) to 11 (Level 11)
- **Boss Levels**: Special encounters on levels 4, 8, 12
- **Scoring**: 20 points per enemy kill

### Power-Up System
- **Shield**: 8-second protection
- **Rapid Fire**: 6-second faster shooting
- **Damage Boost**: 5-second enhanced bullets
- **Invincibility**: 3-second immunity

## 🔊 Audio System

### Sound Files (CAF Format)
- `player_shoot.caf` - Player weapon sounds
- `enemy_shoot.caf` - Enemy weapon sounds  
- `explosion.caf` - Destruction effects
- `player_hit.caf` / `enemy_hit.caf` - Damage sounds
- `player_move.caf` / `enemy_move.caf` - Movement audio
- `boss_tank_move.caf` - Boss-specific audio

## 🔨 Development Setup

### Requirements
- **Xcode 14.0+**
- **iOS 13.0+**  
- **Swift 5.0+**
- **SpriteKit Framework**

### Build Instructions
1. Open `IOS_TankieTankz.xcodeproj` in Xcode
2. Select target device or simulator
3. Build and run (⌘+R)

### Project Structure
```
IOS_TankieTankz.xcodeproj/
├── IOS_TankieTankz/           # Main source code
│   ├── *.swift               # Game logic files
│   └── Assets/               # Audio and resource files
├── Documentation/            # Project documentation
└── Source/                   # Additional source materials
```

## 📊 Performance Metrics

### Optimizations Applied
- **Frame Rate**: Solid 60 FPS gameplay
- **Memory Usage**: Cached calculations prevent redundant operations
- **Animation Smoothness**: 3-frame intervals with 8 total frames
- **Physics Performance**: Rectangular collision bodies optimized for tank shapes
- **Audio Performance**: CAF format for efficient iOS audio playback

### Key Performance Fixes
1. **Cached Tank Dimensions**: Eliminated real-time calculations
2. **Division by Zero Prevention**: Added guards for modulo operations
3. **Smooth Track Animation**: Base position resets prevent drift
4. **Optimized Bullet Spawning**: Calculated once per shot

## 🤝 Contributing

This project is actively developed with AI assistance. Key areas for contribution:
- Additional biome types and visual variety
- New power-up mechanics  
- Enhanced boss battle AI
- Multiplayer functionality
- Achievement system

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Contact

- **Developer**: Joseph Mark Orimoloye
- **Email**: cybonix@gmail.com
- **GitHub**: [@Cybonix](https://github.com/Cybonix)
- **Repository**: [IOS_TankieTankz](https://github.com/Cybonix/IOS_TankieTankz)

---

*Last Updated: January 2025*
*Game Status: Fully Functional - Ready for Distribution*