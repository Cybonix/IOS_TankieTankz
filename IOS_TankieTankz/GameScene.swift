//
//  GameScene.swift
//  IOS_TankieTankz
//
//  Created by Joseph Mark Orimoloye on 4/24/25.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    // MARK: - Properties
    
    // Game state
    private var isRunning: Bool = false
    private var playerTank: BaseTank?
    private var isPlayerDestroyed: Bool = false
    private var isGameOver: Bool = false
    private var isLevelComplete: Bool = false
    private var isGameComplete: Bool = false
    
    // Player lives system
    private var playerLives: Int = 3
    
    // Level tracking
    private var currentLevel: Int = 1
    private let maxLevel: Int = 9
    private let levelsPerBoard = 3
    private let bossLevels = [4, 8] // Levels 4 and 8 are boss levels
    
    // Track current biome for visuals and bullet coloring
    private var currentBiome: BiomeType = .urban
    
    // Game collections
    private var bullets: [Bullet] = []
    private var enemyTanks: [EnemyTank] = []
    private var explosions: [Explosion] = []
    private var missiles: [Missile] = []
    private var battlefield: Battlefield?
    
    // Score tracking
    private var score: Int = 0
    private var tanksDestroyed: Int = 0
    private var enemyTanksSpawned: Int = 0
    private var maxEnemyTanks: Int = 1
    
    // Power-up system
    private var powerUpManager: PowerUpManager?
    private var lastMissileFiredTime: TimeInterval = 0
    private let missileFireInterval: TimeInterval = 2.0
    
    // Power-up status
    private var rapidFireActive = false
    private var rapidFireUntil: TimeInterval = 0
    private var damageBoostActive = false
    private var damageBoostUntil: TimeInterval = 0
    private var shieldActive = false
    private var shieldUntil: TimeInterval = 0
    private var missileAutoFireActive = false
    private var missileAutoFireUntil: TimeInterval = 0
    
    // Sound manager for game sound effects
    private var soundManager: SoundManager?
    private var lastPlayerMoveTime: TimeInterval = 0
    private var lastEnemyMoveTime: TimeInterval = 0
    private var currentBoardNumber = 1 // For tracking 3-level "boards"
    private let moveSoundInterval: TimeInterval = 0.2 // Interval between movement sounds
    
    // Victory sequence timing
    private var victoryStartTime: TimeInterval = 0
    private let levelCompletionDelay: TimeInterval = 3.0
    
    // HUD elements
    private var hudNode: SKNode?
    private var scoreLabel: SKLabelNode?
    private var livesLabel: SKLabelNode?
    private var levelLabel: SKLabelNode?
    private var healthBar: SKSpriteNode?
    private var healthBarBackground: SKSpriteNode?
    
    // Touch control
    private var lastBulletFiredTime: TimeInterval = 0
    private let normalBulletCooldown: TimeInterval = 0.03 
    private let rapidFireCooldown: TimeInterval = 0.015
    
    // Update timing (fixed timestep)
    private let fixedTimeStep: TimeInterval = 1.0 / 60.0 // 60 updates per second
    private var lastUpdateTime: TimeInterval = 0
    private var accumulator: TimeInterval = 0
    
    // MARK: - Scene Setup
    
    override func didMove(to view: SKView) {
        setupGame()
    }
    
    private func setupGame() {
        // Create and configure the player tank
        let centerX = size.width / 2
        let bottomY = size.height * 0.2
        playerTank = BaseTank(position: CGPoint(x: centerX, y: bottomY), direction: .up, health: 100, isPlayer: true)
        
        if let playerTank = playerTank {
            addChild(playerTank)
        }
        
        // Create battlefield controller
        battlefield = Battlefield(scene: self, playerTank: playerTank!, bullets: bullets, enemyTanks: enemyTanks)
        
        // Setup sound manager
        soundManager = SoundManager()
        
        // Setup power-up manager
        powerUpManager = PowerUpManager(gameScene: self)
        
        // Setup game parameters for Level 1
        setupLevel()
        
        // Setup HUD
        setupHUD()
        
        // Set game as running
        isRunning = true
    }
    
    private func setupHUD() {
        // Create HUD container node
        hudNode = SKNode()
        if let hudNode = hudNode {
            addChild(hudNode)
            
            // HUD background
            let hudHeight: CGFloat = 100
            let hudBackground = SKSpriteNode(color: SKColor(red: 0.08, green: 0.08, blue: 0.16, alpha: 1.0), 
                                              size: CGSize(width: size.width, height: hudHeight))
            hudBackground.position = CGPoint(x: size.width/2, y: size.height - hudHeight/2)
            hudBackground.zPosition = 100
            hudNode.addChild(hudBackground)
            
            // HUD Border
            let borderNode = SKShapeNode(rect: CGRect(x: 0, y: size.height - hudHeight, 
                                                    width: size.width, height: 3))
            borderNode.fillColor = .white
            borderNode.strokeColor = .white
            borderNode.zPosition = 101
            hudNode.addChild(borderNode)
            
            // Score Label
            scoreLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
            if let scoreLabel = scoreLabel {
                scoreLabel.text = "SCORE: 0"
                scoreLabel.fontSize = 32
                scoreLabel.fontColor = .yellow
                scoreLabel.position = CGPoint(x: 20 + scoreLabel.frame.width/2, 
                                             y: size.height - 40)
                scoreLabel.horizontalAlignmentMode = .left
                scoreLabel.zPosition = 102
                hudNode.addChild(scoreLabel)
            }
            
            // Level Label
            levelLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
            if let levelLabel = levelLabel {
                levelLabel.text = "LEVEL: 1"
                levelLabel.fontSize = 32
                levelLabel.fontColor = .yellow
                levelLabel.position = CGPoint(x: 20 + levelLabel.frame.width/2, 
                                             y: size.height - 80)
                levelLabel.horizontalAlignmentMode = .left
                levelLabel.zPosition = 102
                hudNode.addChild(levelLabel)
            }
            
            // Lives Label (hearts)
            livesLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
            if let livesLabel = livesLabel {
                livesLabel.text = "♥♥♥" // 3 hearts
                livesLabel.fontSize = 32
                livesLabel.fontColor = .red
                livesLabel.position = CGPoint(x: size.width/2, 
                                             y: size.height - 40)
                livesLabel.horizontalAlignmentMode = .center
                livesLabel.zPosition = 102
                hudNode.addChild(livesLabel)
            }
            
            // Health Bar Background
            let healthBarWidth: CGFloat = 150
            let healthBarHeight: CGFloat = 20
            healthBarBackground = SKSpriteNode(color: .darkGray, 
                                              size: CGSize(width: healthBarWidth, height: healthBarHeight))
            if let healthBarBackground = healthBarBackground {
                healthBarBackground.position = CGPoint(x: size.width - 20 - healthBarWidth/2, 
                                                      y: size.height - 30)
                healthBarBackground.zPosition = 102
                hudNode.addChild(healthBarBackground)
                
                // Health Bar Fill
                healthBar = SKSpriteNode(color: .green, 
                                         size: CGSize(width: healthBarWidth, height: healthBarHeight))
                if let healthBar = healthBar {
                    healthBar.anchorPoint = CGPoint(x: 0, y: 0.5) // Left-aligned
                    healthBar.position = CGPoint(x: -healthBarWidth/2, y: 0)
                    healthBarBackground.addChild(healthBar)
                }
                
                // Health Bar Border
                let borderWidth: CGFloat = 2.0
                let healthBarBorder = SKShapeNode(rect: CGRect(x: -healthBarWidth/2 - borderWidth/2, 
                                                             y: -healthBarHeight/2 - borderWidth/2, 
                                                             width: healthBarWidth + borderWidth, 
                                                             height: healthBarHeight + borderWidth), 
                                                  cornerRadius: 0)
                healthBarBorder.strokeColor = .white
                healthBarBorder.lineWidth = borderWidth
                healthBarBorder.zPosition = 103
                healthBarBackground.addChild(healthBarBorder)
            }
        }
    }
    
    private func setupLevel() {
        // Clear any existing entities
        for bullet in bullets {
            bullet.removeFromParent()
        }
        bullets.removeAll()
        
        for enemyTank in enemyTanks {
            enemyTank.removeFromParent()
        }
        enemyTanks.removeAll()
        
        for explosion in explosions {
            explosion.removeFromParent()
        }
        explosions.removeAll()
        
        for missile in missiles {
            missile.removeFromParent()
        }
        missiles.removeAll()
        
        // Reset player position but maintain health between levels
        if let playerTank = playerTank {
            playerTank.position = CGPoint(x: size.width / 2, y: size.height * 0.2)
        }
        
        // Set the max number of enemy tanks for this level
        maxEnemyTanks = enemyTanksPerLevel(currentLevel)
        
        // Reset enemy tank count
        enemyTanksSpawned = 0
        
        // Spawn initial enemy tank(s) based on the level
        let initialTanks = min(3, maxEnemyTanks) // Cap at 3 tanks on screen
        for _ in 0..<initialTanks {
            spawnEnemyTank(isInitialSpawn: true)
        }
        
        // Reset game state flags
        isLevelComplete = false
        isGameComplete = false
        isPlayerDestroyed = false
        
        // Update background for the current level
        updateBackgroundForCurrentLevel()
        
        // Inform power-up manager of level start
        powerUpManager?.onLevelStart(levelNumber: currentLevel)
    }
    
    private func enemyTanksPerLevel(_ level: Int) -> Int {
        let enemyTanksMap: [Int: Int] = [
            1: 1, // Level 1: 1 enemy tank
            2: 2, // Level 2: 2 enemy tanks
            3: 3, // Level 3: 3 enemy tanks
            4: 1, // Level 4: 1 boss tank (stronger)
            5: 2, // Level 5: 2 enemy tanks
            6: 3, // Level 6: 3 enemy tanks
            7: 3, // Level 7: 3 enemy tanks
            8: 1, // Level 8: 1 boss tank (stronger)
            9: 3  // Level 9: 3 enemy tanks - final level
        ]
        
        return enemyTanksMap[level] ?? 1
    }
    
    private func isBossLevel(_ level: Int) -> Bool {
        return bossLevels.contains(level)
    }
    
    private func updateBackgroundForCurrentLevel() {
        // Update the biome type first
        if bossLevels.contains(currentLevel) {
            currentBiome = .volcanic
        } else if currentLevel <= 3 {
            currentBiome = .urban
        } else if currentLevel <= 7 {
            currentBiome = .desert
        } else {
            currentBiome = .snow
        }
        
        // Update the background
        backgroundColor = colorForBiome(currentBiome)
    }
    
    private func colorForBiome(_ biome: BiomeType) -> SKColor {
        switch biome {
        case .urban:
            return SKColor(red: 0.0, green: 0.16, blue: 0.0, alpha: 1.0) // Dark green
        case .desert:
            return SKColor(red: 0.24, green: 0.16, blue: 0.08, alpha: 1.0) // Brown
        case .snow:
            return SKColor(red: 0.12, green: 0.16, blue: 0.35, alpha: 1.0) // Deep blue
        case .volcanic:
            return SKColor(red: 0.12, green: 0.0, blue: 0.2, alpha: 1.0) // Dark purple
        }
    }
    
    private func spawnEnemyTank(isInitialSpawn: Bool = false) {
        let screenWidth = size.width
        
        let randomX: CGFloat
        if isInitialSpawn && enemyTanks.count < maxEnemyTanks {
            // For initial spawn, space out the tanks evenly
            let sectionWidth = screenWidth / CGFloat(maxEnemyTanks + 1)
            randomX = sectionWidth * CGFloat(enemyTanks.count + 1)
        } else {
            // For respawns during gameplay, use random positions
            randomX = CGFloat.random(in: 0...(screenWidth - 50))
        }
        
        // Check if the current level is a boss level
        let isBossLevel = bossLevels.contains(currentLevel)
        
        // Create appropriate tank based on level type
        let newEnemyTank: EnemyTank
        if isBossLevel {
            // Boss tanks spawn in the center for dramatic effect
            let bossX = isInitialSpawn ? screenWidth / 2 : randomX
            newEnemyTank = EnemyTank(
                position: CGPoint(x: bossX, y: size.height - 150),
                direction: .down,
                isBoss: true
            )
        } else {
            // Regular enemy tank
            newEnemyTank = EnemyTank(
                position: CGPoint(x: randomX, y: size.height - 150),
                direction: .down,
                isBoss: false
            )
        }
        
        addChild(newEnemyTank)
        enemyTanks.append(newEnemyTank)
        enemyTanksSpawned += 1
    }
    
    // MARK: - Game Loop
    
    override func update(_ currentTime: TimeInterval) {
        // First-time setup
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
            return
        }
        
        // Calculate delta time
        var deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        // Cap delta time to prevent spiral of death when game lags severely
        deltaTime = min(deltaTime, 0.05) // Cap at 50ms
        
        accumulator += deltaTime
        
        // Handle player firing with highest priority for responsiveness
        // (This would be handled in touch events)
        
        // Process fixed timestep updates (physics, movement, game logic)
        while accumulator >= fixedTimeStep {
            updateGameLogic(currentTime: currentTime)
            accumulator -= fixedTimeStep
        }
    }
    
    private func updateGameLogic(currentTime: TimeInterval) {
        // Use minimal synchronization for better performance
        updateExplosions()
        
        // Process player actions first to prioritize responsiveness
        if !isPlayerDestroyed, let playerTank = playerTank {
            updateTankPosition(tank: playerTank)
            powerUpManager?.update(currentTime: currentTime)
            checkPowerUpExpiration(currentTime: currentTime)
            powerUpManager?.checkCollisions(playerX: Int(playerTank.position.x), playerY: Int(playerTank.position.y))
        }
        
        // Update player health UI
        updateHealthUI()
        
        // Check win/lose conditions
        checkForWinOrLoseConditions(currentTime: currentTime)
        
        // Update bullets every frame as they're critical for gameplay
        updateBullets()
        
        // Update missiles every frame (there are typically few of these)
        updateMissiles(currentTime: currentTime)
        
        // Always update enemy tank positions every frame for smooth movement
        updateEnemyTankPositions()
        
        // Handle enemy firing with throttling
        updateEnemyTankFiring(currentTime: currentTime)
        
        // Check if we should fire missiles
        if missileAutoFireActive && !isPlayerDestroyed && currentTime - lastMissileFiredTime >= missileFireInterval {
            fireMissile()
            lastMissileFiredTime = currentTime
        }
        
        // Process collisions
        battlefield?.checkCollisions()
    }
    
    // MARK: - Update Methods
    
    private func updateExplosions() {
        var explosionsToRemove: [Explosion] = []
        
        for explosion in explosions {
            explosion.update()
            if explosion.isFinished {
                explosionsToRemove.append(explosion)
            }
        }
        
        for explosion in explosionsToRemove {
            explosion.removeFromParent()
            if let index = explosions.firstIndex(of: explosion) {
                explosions.remove(at: index)
            }
        }
    }
    
    private func updateBullets() {
        var bulletsToRemove: [Bullet] = []
        
        for bullet in bullets {
            bullet.updatePosition()
            
            // Check bounds
            if bullet.position.x < 0 || bullet.position.x > size.width ||
               bullet.position.y < 0 || bullet.position.y > size.height {
                bulletsToRemove.append(bullet)
            }
        }
        
        for bullet in bulletsToRemove {
            bullet.removeFromParent()
            if let index = bullets.firstIndex(of: bullet) {
                bullets.remove(at: index)
            }
        }
        
        // Safety check - if we exceed bullet limit, clean up older bullets
        if bullets.count > 100 {
            let enemyBullets = bullets.filter { $0.isEnemy }
            let playerBullets = bullets.filter { !$0.isEnemy }
            
            var bulletsToKeep: [Bullet] = []
            
            // Keep a balanced set of bullets for gameplay fairness
            bulletsToKeep.append(contentsOf: enemyBullets.suffix(min(25, enemyBullets.count)))
            
            // Then add player bullets
            let playerBulletLimit = max(10, 50 - bulletsToKeep.count)
            bulletsToKeep.append(contentsOf: playerBullets.suffix(min(playerBulletLimit, playerBullets.count)))
            
            // Remove bullets not in the keep list
            let bulletsToRemove = bullets.filter { !bulletsToKeep.contains($0) }
            for bullet in bulletsToRemove {
                bullet.removeFromParent()
            }
            bullets = bulletsToKeep
        }
    }
    
    private func updateMissiles(currentTime: TimeInterval) {
        var missilesToRemove: [Missile] = []
        var enemyTanksToRemove: [EnemyTank] = []
        var explosionsToCreate: [CGPoint] = []
        var scoreGain = 0
        var tanksDestroyedCount = 0
        
        // First pass: update missile positions
        for missile in missiles {
            let shouldContinue = missile.updatePosition(currentTime: currentTime)
            if !shouldContinue {
                missilesToRemove.append(missile)
            }
        }
        
        // Second pass: check collisions
        let missilesList = missiles.filter { !missilesToRemove.contains($0) }
        
        for missile in missilesList {
            for enemyTank in enemyTanks {
                // Skip already marked tanks
                if enemyTanksToRemove.contains(enemyTank) { continue }
                
                if missile.checkCollision(with: enemyTank) {
                    // Mark missile for removal
                    missilesToRemove.append(missile)
                    
                    // Handle damage calculation
                    // Make missiles extremely powerful
                    let missileDamage = damageBoostActive ?
                        (enemyTank.isBoss ? 100 : 80) : // Almost instakill regular tanks with boost
                        (enemyTank.isBoss ? 75 : 60)    // Strong without boost
                    
                    // Apply damage
                    enemyTank.health -= missileDamage
                    
                    // Trigger hit flash effect
                    enemyTank.isHit = true
                    enemyTank.hitFlashStartTime = currentTime
                    
                    if enemyTank.health <= 0 && !enemyTank.isDestroyed {
                        // Mark tank for removal
                        enemyTank.isDestroyed = true
                        enemyTanksToRemove.append(enemyTank)
                        
                        // Track score changes to apply in a single update
                        scoreGain += 20
                        tanksDestroyedCount += 1
                        
                        // Create main explosion
                        explosionsToCreate.append(CGPoint(x: enemyTank.position.x, y: enemyTank.position.y))
                    } else {
                        // Create impact explosion
                        explosionsToCreate.append(CGPoint(x: enemyTank.position.x, y: enemyTank.position.y))
                    }
                    
                    // Only process one hit per missile
                    break
                }
            }
        }
        
        // Apply all changes
        for missile in missilesToRemove {
            missile.removeFromParent()
            if let index = missiles.firstIndex(of: missile) {
                missiles.remove(at: index)
            }
        }
        
        if !missilesToRemove.isEmpty {
            playMissileImpactSound()
        }
        
        for enemyTank in enemyTanksToRemove {
            enemyTank.removeFromParent()
            if let index = enemyTanks.firstIndex(of: enemyTank) {
                enemyTanks.remove(at: index)
            }
        }
        
        if !enemyTanksToRemove.isEmpty {
            score += scoreGain
            tanksDestroyed += tanksDestroyedCount
            updateScoreDisplay()
        }
        
        for explosionPoint in explosionsToCreate {
            createExplosion(at: explosionPoint)
        }
    }
    
    private func updateTankPosition(tank: BaseTank) {
        tank.updatePosition()
        
        // Boundary checking
        let tankSize: CGFloat = 50 * 1.1 + 5 // Base size * scale factor + margin
        let hudHeight: CGFloat = 100
        
        // Keep tank within bounds
        var position = tank.position
        
        if position.x - tankSize/2 < 0 {
            position.x = tankSize/2
            if !tank.isPlayer {
                changeDirectionRandomly(tank: tank)
            }
        } else if position.x + tankSize/2 > size.width {
            position.x = size.width - tankSize/2
            if !tank.isPlayer {
                changeDirectionRandomly(tank: tank)
            }
        }
        
        if position.y - tankSize/2 < 0 {
            position.y = tankSize/2
            if !tank.isPlayer {
                changeDirectionRandomly(tank: tank)
            }
        } else if position.y + tankSize/2 > size.height - hudHeight {
            position.y = size.height - hudHeight - tankSize/2
            if !tank.isPlayer {
                changeDirectionRandomly(tank: tank)
            }
        }
        
        tank.position = position
        playMovementSound(tank: tank, currentTime: CACurrentMediaTime())
    }
    
    private func changeDirectionRandomly(tank: BaseTank) {
        // Regular tank behavior - random direction
        if let enemyTank = tank as? EnemyTank, enemyTank.isBoss, Double.random(in: 0...1) <= 0.7 {
            // Boss tank behavior - target player
            if let playerTank = playerTank {
                // Calculate best direction to approach player
                let dx = playerTank.position.x - tank.position.x
                let dy = playerTank.position.y - tank.position.y
                
                // Choose horizontal or vertical movement based on which distance is greater
                if abs(dx) > abs(dy) {
                    // Horizontal movement
                    tank.direction = dx > 0 ? .right : .left
                } else {
                    // Vertical movement
                    tank.direction = dy > 0 ? .down : .up
                }
            } else {
                tank.direction = Direction.allCases.randomElement() ?? .up
            }
        } else {
            tank.direction = Direction.allCases.randomElement() ?? .up
        }
    }
    
    private func updateEnemyTankPositions() {
        var enemyTanksToRemove: [EnemyTank] = []
        
        for enemyTank in enemyTanks {
            updateTankPosition(tank: enemyTank)
            
            if enemyTank.health <= 0 {
                enemyTanksToRemove.append(enemyTank)
                
                // Update score
                score += enemyTank.isBoss ? 50 : 10
                tanksDestroyed += 1
                
                // Create explosion
                createExplosion(at: enemyTank.position)
                
                updateScoreDisplay()
            }
        }
        
        for enemyTank in enemyTanksToRemove {
            enemyTank.removeFromParent()
            if let index = enemyTanks.firstIndex(of: enemyTank) {
                enemyTanks.remove(at: index)
            }
        }
        
        // Spawn new enemy tanks if needed
        // Ensure we never have more than 3 tanks on screen at once (or number specified by level)
        let effectiveMaxTanks = min(3, maxEnemyTanks) // Cap at 3 tanks regardless of level setting
        
        // Only spawn if we have room for more tanks and haven't exceeded the level's total
        if enemyTanks.count < effectiveMaxTanks && enemyTanksSpawned < maxEnemyTanks {
            spawnEnemyTank()
        }
    }
    
    // MARK: - Tank Firing Logic
    
    private var enemyFireCooldown: [EnemyTank: TimeInterval] = [:]
    
    private func updateEnemyTankFiring(currentTime: TimeInterval) {
        let enemyFiringFrequencies = [1.0, 1.0, 1.2, 1.4, 1.6] // Index 0 not used, 1 tank: 1s, 2 tanks: 1.2s, etc.
        
        let tankCount = enemyTanks.count
        if tankCount == 0 { return }
        
        let baseCooldown = tankCount < enemyFiringFrequencies.count ? 
            enemyFiringFrequencies[tankCount] : enemyFiringFrequencies.last!
        
        var bulletsToCreate: [Bullet] = []
        var tanksThatFired: [EnemyTank] = []
        
        for enemyTank in enemyTanks {
            // Skip dead tanks
            if enemyTank.health <= 0 { continue }
            
            // Check cooldown
            let lastFireTime = enemyFireCooldown[enemyTank] ?? 0
            let tankCooldown = enemyTank.isBoss ? 0.6 : baseCooldown
            
            if currentTime - lastFireTime > tankCooldown {
                // Calculate direction to player
                let directionToPlayer = calculateDirectionToPlayer(enemyPosition: enemyTank.position)
                
                // Create bullet
                let bullet = Bullet(
                    position: CGPoint(x: enemyTank.position.x, y: enemyTank.position.y),
                    direction: directionToPlayer,
                    isEnemy: true,
                    fromBoss: enemyTank.isBoss,
                    biomeType: currentBiome
                )
                
                bulletsToCreate.append(bullet)
                tanksThatFired.append(enemyTank)
            }
        }
        
        // Add bullets if we're below the limit
        if !bulletsToCreate.isEmpty {
            let maxEnemyBullets = 30 + (2 * enemyTanks.count)
            let bulletsToAdd = min(bulletsToCreate.count, maxEnemyBullets - bullets.filter { $0.isEnemy }.count)
            
            for i in 0..<bulletsToAdd {
                let bullet = bulletsToCreate[i]
                addChild(bullet)
                bullets.append(bullet)
                
                // Update cooldown for the tank that fired
                let firedTank = tanksThatFired[i]
                enemyFireCooldown[firedTank] = currentTime
            }
            
            // Only play sound once per batch to reduce audio load
            if enemyTanks.count <= 3 || bulletsToAdd <= 2 {
                soundManager?.playSound(.enemyShoot)
            }
        }
    }
    
    private func calculateDirectionToPlayer(enemyPosition: CGPoint) -> Direction {
        guard let playerTank = playerTank else { return .down }
        
        let dx = playerTank.position.x - enemyPosition.x
        let dy = playerTank.position.y - enemyPosition.y
        
        if abs(dx) > abs(dy) {
            return dx > 0 ? .right : .left
        } else {
            return dy > 0 ? .down : .up
        }
    }
    
    // MARK: - Player Controls
    
    func handlePlayerFiring(at position: CGPoint, currentTime: TimeInterval) {
        guard let playerTank = playerTank, !isPlayerDestroyed else { return }
        
        // Check cooldown - allows for rapid fire with the power-up
        let cooldown = rapidFireActive ? rapidFireCooldown : normalBulletCooldown
        
        if currentTime - lastBulletFiredTime > cooldown {
            // Calculate firing direction based on touch position
            let dx = position.x - playerTank.position.x
            let dy = position.y - playerTank.position.y
            
            let firingDirection: Direction
            if abs(dx) > abs(dy) {
                firingDirection = dx > 0 ? .right : .left
            } else {
                firingDirection = dy > 0 ? .down : .up
            }
            
            // Update player tank direction
            playerTank.direction = firingDirection
            
            // Create bullet
            let bullet = Bullet(
                position: playerTank.position,
                direction: firingDirection,
                isEnemy: false,
                fromBoss: false,
                biomeType: currentBiome
            )
            
            addChild(bullet)
            bullets.append(bullet)
            
            // For power-up checks
            if !damageBoostActive {
                powerUpManager?.checkActivations(playerTakingDamage: false, playerFiring: true)
            }
            
            if !rapidFireActive {
                powerUpManager?.checkActivations(playerTakingDamage: false, playerFiring: true)
            }
            
            // Play sound
            soundManager?.playSound(.playerShoot)
            lastBulletFiredTime = currentTime
        }
    }
    
    func handlePlayerMovement(to position: CGPoint) {
        guard let playerTank = playerTank, !isPlayerDestroyed else { return }
        
        // Move player towards touch position
        let dx = position.x - playerTank.position.x
        let dy = position.y - playerTank.position.y
        
        if abs(dx) > abs(dy) {
            playerTank.direction = dx > 0 ? .right : .left
        } else {
            playerTank.direction = dy > 0 ? .down : .up
        }
    }
    
    private func fireMissile() {
        guard let playerTank = playerTank else { return }
        
        // Find nearest enemy tank
        var nearestTank: EnemyTank? = nil
        var minDistance: CGFloat = .greatestFiniteMagnitude
        
        for enemyTank in enemyTanks {
            let dx = enemyTank.position.x - playerTank.position.x
            let dy = enemyTank.position.y - playerTank.position.y
            let distance = dx * dx + dy * dy
            
            if CGFloat(distance) < minDistance {
                minDistance = CGFloat(distance)
                nearestTank = enemyTank
            }
        }
        
        // If there is a target, fire a missile at it
        if let nearestTank = nearestTank {
            let missile = Missile(
                position: playerTank.position,
                targetTank: nearestTank,
                biomeType: currentBiome
            )
            
            addChild(missile)
            missiles.append(missile)
            
            playMissileFireSound()
        }
    }
    
    // MARK: - Power-Up Management
    
    func activateShield(duration: TimeInterval) {
        let currentTime = CACurrentMediaTime()
        shieldActive = true
        shieldUntil = currentTime + duration
        playerInvulnerableUntil = shieldUntil // Use existing invulnerability system
    }
    
    func activateRapidFire(duration: TimeInterval) {
        let currentTime = CACurrentMediaTime()
        rapidFireActive = true
        rapidFireUntil = currentTime + duration
    }
    
    func activateDamageBoost(duration: TimeInterval) {
        let currentTime = CACurrentMediaTime()
        damageBoostActive = true
        damageBoostUntil = currentTime + duration
    }
    
    func activateMissileAutoFire(duration: TimeInterval) {
        let currentTime = CACurrentMediaTime()
        missileAutoFireActive = true
        missileAutoFireUntil = currentTime + duration
        lastMissileFiredTime = currentTime // Reset missile timer
    }
    
    func grantExtraLife() {
        playerLives += 1
        updateLivesDisplay()
    }
    
    private func checkPowerUpExpiration(currentTime: TimeInterval) {
        // Check each power-up for expiration
        if rapidFireActive && currentTime >= rapidFireUntil {
            rapidFireActive = false
            playPowerUpExpireSound()
        }
        
        if damageBoostActive && currentTime >= damageBoostUntil {
            damageBoostActive = false
            playPowerUpExpireSound()
        }
        
        if shieldActive && currentTime >= shieldUntil {
            shieldActive = false
            playPowerUpExpireSound()
        }
        
        if missileAutoFireActive && currentTime >= missileAutoFireUntil {
            missileAutoFireActive = false
            playPowerUpExpireSound()
        }
    }
    
    // MARK: - Game State Checks
    
    private var playerInvulnerableUntil: TimeInterval = 0
    private let playerInvulnerabilityDuration: TimeInterval = 3.0
    
    func isPlayerInvulnerable() -> Bool {
        return CACurrentMediaTime() < playerInvulnerableUntil
    }
    
    func getPlayerDestroyedState() -> Bool {
        return isPlayerDestroyed
    }
    
    func isDamageBoostActive() -> Bool {
        return damageBoostActive
    }
    
    private var gameOverDelayStartTime: TimeInterval = 0
    private let gameOverDelay: TimeInterval = 1.5 // 1.5 seconds to show explosion before ending game
    private var isGameEnding = false
    
    private func checkForWinOrLoseConditions(currentTime: TimeInterval) {
        // Check for player death
        if let playerTank = playerTank, playerTank.health <= 0 {
            // First time detecting player death
            if !isPlayerDestroyed {
                isPlayerDestroyed = true
                
                // Start death sequence
                isGameEnding = true
                gameOverDelayStartTime = currentTime
                
                // Create explosion at player position
                createExplosion(at: playerTank.position)
            } 
            // Check if we should process the end of death sequence
            else if isGameEnding && currentTime - gameOverDelayStartTime > gameOverDelay {
                // Decrease player lives
                playerLives -= 1
                updateLivesDisplay()
                
                if playerLives <= 0 {
                    // No lives left - Game Over
                    isGameOver = true
                    showGameOverScreen()
                } else {
                    // Player still has lives, reset for next life
                    resetPlayerForNextLife()
                }
            }
            return
        }
        
        // Check for level completion
        if enemyTanks.isEmpty && enemyTanksSpawned >= maxEnemyTanks {
            // All enemies defeated in this level
            if !isLevelComplete {
                isLevelComplete = true
                victoryStartTime = currentTime
                
                // Calculate player health percentage for power-up eligibility
                if let playerTank = playerTank {
                    let healthPercent = (playerTank.health * 100) / 100 // Health is out of 100
                    
                    // Notify power-up manager of level completion
                    powerUpManager?.onLevelComplete(levelNumber: currentLevel, playerHealthPercent: healthPercent)
                }
                
                // Check if this was the final level
                if currentLevel >= maxLevel {
                    // Play final victory sound
                    soundManager?.playSound(.finalVictory)
                    isGameComplete = true
                    showGameCompleteScreen()
                } else {
                    // Play regular victory sound
                    soundManager?.playSound(.victory)
                    showLevelCompleteScreen()
                }
            }
        }
    }
    
    private func resetPlayerForNextLife() {
        guard let playerTank = playerTank else { return }
        
        // Reset player state but keep the same tank object for continuity
        playerTank.health = 100
        playerTank.position = CGPoint(x: size.width / 2, y: size.height * 0.2)
        playerTank.direction = .up
        
        // Reset game state flags
        isGameEnding = false
        isPlayerDestroyed = false
        
        // Give player a brief invulnerability period
        playerInvulnerableUntil = CACurrentMediaTime() + playerInvulnerabilityDuration
        
        // Reset active power-ups
        rapidFireActive = false
        damageBoostActive = false
        shieldActive = false
        missileAutoFireActive = false
        
        // Clear bullets that might have been in flight
        for bullet in bullets {
            bullet.removeFromParent()
        }
        bullets.removeAll()
        
        // Clear missiles
        for missile in missiles {
            missile.removeFromParent()
        }
        missiles.removeAll()
        
        // Clear enemy cooldowns
        enemyFireCooldown.removeAll()
        
        // Play a respawn sound
        soundManager?.playSound(.victory)
        
        // Show respawn message
        showRespawnMessage()
        
        // Update health UI
        updateHealthUI()
    }
    
    // MARK: - UI Updates
    
    private func updateScoreDisplay() {
        scoreLabel?.text = "SCORE: \(score)"
    }
    
    private func updateLivesDisplay() {
        let hearts = String(repeating: "♥", count: playerLives)
        livesLabel?.text = hearts
    }
    
    private func updateHealthUI() {
        guard let playerTank = playerTank, let healthBar = healthBar else { return }
        
        let healthPercent = CGFloat(playerTank.health) / 100.0
        let healthBarWidth: CGFloat = 150
        
        healthBar.xScale = healthPercent
    }
    
    // MARK: - UI Screens
    
    private func showGameOverScreen() {
        let gameOverNode = SKNode()
        gameOverNode.zPosition = 200
        addChild(gameOverNode)
        
        // Semi-transparent overlay
        let overlay = SKSpriteNode(color: .black, size: size)
        overlay.alpha = 0.7
        overlay.position = CGPoint(x: size.width/2, y: size.height/2)
        gameOverNode.addChild(overlay)
        
        // Game Over text
        let gameOverLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        gameOverLabel.text = "GAME OVER"
        gameOverLabel.fontSize = 70
        gameOverLabel.fontColor = .red
        gameOverLabel.position = CGPoint(x: size.width/2, y: size.height * 0.75)
        gameOverNode.addChild(gameOverLabel)
        
        // Score information
        let scoreLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        scoreLabel.text = "SCORE: \(score)"
        scoreLabel.fontSize = 40
        scoreLabel.fontColor = .white
        scoreLabel.position = CGPoint(x: size.width/2, y: size.height * 0.65)
        gameOverNode.addChild(scoreLabel)
        
        let levelLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        levelLabel.text = "LEVEL REACHED: \(currentLevel)"
        levelLabel.fontSize = 40
        levelLabel.fontColor = .white
        levelLabel.position = CGPoint(x: size.width/2, y: size.height * 0.55)
        gameOverNode.addChild(levelLabel)
        
        let tanksLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        tanksLabel.text = "TANKS DESTROYED: \(tanksDestroyed)"
        tanksLabel.fontSize = 40
        tanksLabel.fontColor = .white
        tanksLabel.position = CGPoint(x: size.width/2, y: size.height * 0.45)
        gameOverNode.addChild(tanksLabel)
        
        // Restart button
        let restartButton = createButton(text: "RESTART", position: CGPoint(x: size.width/2, y: size.height * 0.35))
        restartButton.name = "restartButton"
        gameOverNode.addChild(restartButton)
        
        // Exit button
        let exitButton = createButton(text: "EXIT", position: CGPoint(x: size.width/2, y: size.height * 0.25))
        exitButton.name = "exitButton"
        gameOverNode.addChild(exitButton)
    }
    
    private func showLevelCompleteScreen() {
        let levelCompleteNode = SKNode()
        levelCompleteNode.zPosition = 200
        levelCompleteNode.name = "levelCompleteScreen"
        addChild(levelCompleteNode)
        
        // Semi-transparent overlay
        let overlay = SKSpriteNode(color: .black, size: size)
        overlay.alpha = 0.7
        overlay.position = CGPoint(x: size.width/2, y: size.height/2)
        levelCompleteNode.addChild(overlay)
        
        // Level Complete text
        let levelCompleteLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        levelCompleteLabel.text = "LEVEL \(currentLevel) COMPLETE!"
        levelCompleteLabel.fontSize = 70
        levelCompleteLabel.fontColor = .green
        levelCompleteLabel.position = CGPoint(x: size.width/2, y: size.height * 0.7)
        levelCompleteNode.addChild(levelCompleteLabel)
        
        // Score information
        let scoreLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        scoreLabel.text = "Score: \(score)"
        scoreLabel.fontSize = 40
        scoreLabel.fontColor = .white
        scoreLabel.position = CGPoint(x: size.width/2, y: size.height * 0.6)
        levelCompleteNode.addChild(scoreLabel)
        
        let tanksLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        tanksLabel.text = "Tanks Destroyed: \(tanksDestroyed)"
        tanksLabel.fontSize = 40
        tanksLabel.fontColor = .white
        tanksLabel.position = CGPoint(x: size.width/2, y: size.height * 0.5)
        levelCompleteNode.addChild(tanksLabel)
        
        // Next level message
        let nextLevelLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        nextLevelLabel.text = "Prepare for Level \(currentLevel + 1)..."
        nextLevelLabel.fontSize = 40
        nextLevelLabel.fontColor = SKColor(red: 1.0, green: 0.65, blue: 0.0, alpha: 1.0) // Orange
        nextLevelLabel.position = CGPoint(x: size.width/2, y: size.height * 0.4)
        levelCompleteNode.addChild(nextLevelLabel)
        
        // Continue label with blinking effect
        let continueLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        continueLabel.text = "Tap anywhere to continue"
        continueLabel.fontSize = 30
        continueLabel.fontColor = .yellow
        continueLabel.position = CGPoint(x: size.width/2, y: size.height * 0.3)
        continueLabel.name = "continueLabel"
        levelCompleteNode.addChild(continueLabel)
        
        // Add blinking effect to continue label
        let blinkAction = SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.5),
            SKAction.fadeIn(withDuration: 0.5)
        ])
        let blinkForeverAction = SKAction.repeatForever(blinkAction)
        continueLabel.run(blinkForeverAction)
        
        // Countdown label for the first 3 seconds
        let countdownLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        countdownLabel.text = "Next level in: 3..."
        countdownLabel.fontSize = 40
        countdownLabel.fontColor = .white
        countdownLabel.position = CGPoint(x: size.width/2, y: size.height * 0.2)
        countdownLabel.name = "countdownLabel"
        levelCompleteNode.addChild(countdownLabel)
        
        // Countdown action
        let wait1Sec = SKAction.wait(forDuration: 1.0)
        let countdown2Sec = SKAction.run { countdownLabel.text = "Next level in: 2..." }
        let countdown1Sec = SKAction.run { countdownLabel.text = "Next level in: 1..." }
        let hideCountdown = SKAction.run { countdownLabel.isHidden = true }
        let countdownSequence = SKAction.sequence([wait1Sec, countdown2Sec, wait1Sec, countdown1Sec, wait1Sec, hideCountdown])
        countdownLabel.run(countdownSequence)
    }
    
    private func showGameCompleteScreen() {
        let gameCompleteNode = SKNode()
        gameCompleteNode.zPosition = 200
        addChild(gameCompleteNode)
        
        // Semi-transparent overlay
        let overlay = SKSpriteNode(color: .black, size: size)
        overlay.alpha = 0.7
        overlay.position = CGPoint(x: size.width/2, y: size.height/2)
        gameCompleteNode.addChild(overlay)
        
        // Victory text
        let victoryLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        victoryLabel.text = "VICTORY!"
        victoryLabel.fontSize = 70
        victoryLabel.fontColor = .yellow
        victoryLabel.position = CGPoint(x: size.width/2, y: size.height * 0.75)
        gameCompleteNode.addChild(victoryLabel)
        
        let completeLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        completeLabel.text = "ALL LEVELS COMPLETE!"
        completeLabel.fontSize = 70
        completeLabel.fontColor = .yellow
        completeLabel.position = CGPoint(x: size.width/2, y: size.height * 0.65)
        gameCompleteNode.addChild(completeLabel)
        
        // Score display
        let scoreLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        scoreLabel.text = "Final Score: \(score)"
        scoreLabel.fontSize = 60
        scoreLabel.fontColor = .white
        scoreLabel.position = CGPoint(x: size.width/2, y: size.height * 0.55)
        gameCompleteNode.addChild(scoreLabel)
        
        // Buttons
        let playAgainButton = createButton(text: "PLAY AGAIN", position: CGPoint(x: size.width/2, y: size.height * 0.4))
        playAgainButton.name = "playAgainButton"
        gameCompleteNode.addChild(playAgainButton)
        
        let exitButton = createButton(text: "EXIT", position: CGPoint(x: size.width/2, y: size.height * 0.3))
        exitButton.name = "exitButton"
        gameCompleteNode.addChild(exitButton)
        
        // Add celebration effects
        addCelebrationEffects(to: gameCompleteNode)
    }
    
    private func addCelebrationEffects(to node: SKNode) {
        // Create particle effects for celebration
        let emitter = SKEmitterNode(fileNamed: "Fireworks")
        emitter?.position = CGPoint(x: size.width/2, y: size.height/2)
        emitter?.name = "celebrationEmitter"
        if let emitter = emitter {
            node.addChild(emitter)
        }
        
        // Add star effects
        for i in 0..<30 {
            let star = SKShapeNode(circleOfRadius: CGFloat.random(in: 5...10))
            
            // Cycle through colors
            let hue = CGFloat(i) * 30 / 360.0
            star.fillColor = SKColor(hue: hue, saturation: 0.8, brightness: 1.0, alpha: 1.0)
            star.strokeColor = star.fillColor
            
            // Random position around the screen
            star.position = CGPoint(
                x: CGFloat.random(in: size.width * 0.1...size.width * 0.9),
                y: CGFloat.random(in: size.height * 0.1...size.height * 0.9)
            )
            
            // Animation
            let scaleUp = SKAction.scale(to: 1.5, duration: CGFloat.random(in: 0.5...1.5))
            let scaleDown = SKAction.scale(to: 0.5, duration: CGFloat.random(in: 0.5...1.5))
            let pulse = SKAction.sequence([scaleUp, scaleDown])
            let pulseForever = SKAction.repeatForever(pulse)
            
            star.run(pulseForever)
            node.addChild(star)
        }
    }
    
    private func showRespawnMessage() {
        let messageNode = SKNode()
        messageNode.name = "respawnMessage"
        messageNode.zPosition = 150
        addChild(messageNode)
        
        // Labels
        let destroyedLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        destroyedLabel.text = "TANK DESTROYED!"
        destroyedLabel.fontSize = 50
        destroyedLabel.fontColor = .yellow
        destroyedLabel.position = CGPoint(x: size.width/2, y: size.height/2 + 50)
        destroyedLabel.zPosition = 151
        messageNode.addChild(destroyedLabel)
        
        let livesLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        livesLabel.text = "LIVES REMAINING: \(playerLives)"
        livesLabel.fontSize = 50
        livesLabel.fontColor = .yellow
        livesLabel.position = CGPoint(x: size.width/2, y: size.height/2)
        livesLabel.zPosition = 151
        messageNode.addChild(livesLabel)
        
        // Shadow labels for effect
        let destroyedShadow = SKLabelNode(fontNamed: "Arial-BoldMT")
        destroyedShadow.text = "TANK DESTROYED!"
        destroyedShadow.fontSize = 50
        destroyedShadow.fontColor = .black
        destroyedShadow.position = CGPoint(x: size.width/2 + 3, y: size.height/2 + 50 - 3)
        destroyedShadow.zPosition = 150.5
        messageNode.addChild(destroyedShadow)
        
        let livesShadow = SKLabelNode(fontNamed: "Arial-BoldMT")
        livesShadow.text = "LIVES REMAINING: \(playerLives)"
        livesShadow.fontSize = 50
        livesShadow.fontColor = .black
        livesShadow.position = CGPoint(x: size.width/2 + 3, y: size.height/2 - 3)
        livesShadow.zPosition = 150.5
        messageNode.addChild(livesShadow)
        
        // Auto-remove after 2 seconds
        let removeAction = SKAction.sequence([
            SKAction.wait(forDuration: 2.0),
            SKAction.fadeOut(withDuration: 0.5),
            SKAction.removeFromParent()
        ])
        messageNode.run(removeAction)
    }
    
    private func createButton(text: String, position: CGPoint) -> SKNode {
        let buttonNode = SKNode()
        let buttonWidth: CGFloat = 300
        let buttonHeight: CGFloat = 80
        
        // Button background
        let buttonBackground = SKSpriteNode(color: SKColor(red: 0.2, green: 0.2, blue: 0.8, alpha: 1.0), 
                                             size: CGSize(width: buttonWidth, height: buttonHeight))
        buttonBackground.position = position
        buttonNode.addChild(buttonBackground)
        
        // Button border
        let borderRect = CGRect(x: -buttonWidth/2, y: -buttonHeight/2, width: buttonWidth, height: buttonHeight)
        let buttonBorder = SKShapeNode(rect: borderRect, cornerRadius: 0)
        buttonBorder.strokeColor = .white
        buttonBorder.lineWidth = 4
        buttonBorder.position = position
        buttonNode.addChild(buttonBorder)
        
        // Button text
        let buttonLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        buttonLabel.text = text
        buttonLabel.fontSize = 40
        buttonLabel.fontColor = .white
        buttonLabel.position = CGPoint(x: position.x, y: position.y - 15) // Center vertically
        buttonLabel.verticalAlignmentMode = .center
        buttonLabel.horizontalAlignmentMode = .center
        buttonNode.addChild(buttonLabel)
        
        return buttonNode
    }
    
    // MARK: - Sound Methods
    
    func playHitSound() {
        soundManager?.playSound(.enemyHit)
    }
    
    func playPlayerHitSound() {
        soundManager?.playSound(.playerHit)
    }
    
    func playPowerUpCollectSound() {
        soundManager?.playSound(.powerUpCollect)
    }
    
    func playPowerUpActivationSound() {
        soundManager?.playSound(.powerUpActivate)
    }
    
    func playPowerUpExpireSound() {
        soundManager?.playSound(.powerUpExpire)
    }
    
    func playMissileFireSound() {
        soundManager?.playSound(.missileFire)
    }
    
    func playMissileImpactSound() {
        soundManager?.playSound(.missileImpact)
    }
    
    private func playMovementSound(tank: BaseTank, currentTime: TimeInterval) {
        if tank.isPlayer {
            // Player tank movement sound (throttled to avoid sound spam)
            if currentTime - lastPlayerMoveTime > moveSoundInterval {
                soundManager?.playSound(.playerMove)
                lastPlayerMoveTime = currentTime
            }
        } else if let enemyTank = tank as? EnemyTank {
            // Enemy tank movement sound (throttled to avoid sound spam)
            if currentTime - lastEnemyMoveTime > moveSoundInterval {
                if enemyTank.isBoss {
                    soundManager?.playSound(.bossTankMove)
                } else {
                    soundManager?.playSound(.enemyMove)
                }
                lastEnemyMoveTime = currentTime
            }
        }
    }
    
    // MARK: - Game Flow Control
    
    func proceedToNextLevel() {
        // Clear level complete screen
        childNode(withName: "levelCompleteScreen")?.removeFromParent()
        
        if currentLevel < maxLevel {
            currentLevel += 1
            
            // Update board number if needed
            if currentLevel % 3 == 1 {
                currentBoardNumber += 1
            }
            
            // Update level display
            levelLabel?.text = "LEVEL: \(currentLevel)"
            
            // Update background for the new level
            updateBackgroundForCurrentLevel()
        }
        
        // Play success sound for advancing
        soundManager?.playSound(.victory)
        
        // Reset level flags
        isLevelComplete = false
        
        // Setup the next level
        setupLevel()
    }
    
    func restartGame() {
        // Reset game state
        isGameOver = false
        isPlayerDestroyed = false
        isGameEnding = false
        isLevelComplete = false
        isGameComplete = false
        
        // Reset player lives
        playerLives = 3
        updateLivesDisplay()
        
        // Reset player (create a new tank with new position)
        playerTank?.removeFromParent()
        playerTank = BaseTank(position: CGPoint(x: size.width / 2, y: size.height * 0.2), direction: .up, health: 100, isPlayer: true)
        if let playerTank = playerTank {
            addChild(playerTank)
        }
        
        // Clear existing game objects
        for bullet in bullets {
            bullet.removeFromParent()
        }
        bullets.removeAll()
        
        for enemyTank in enemyTanks {
            enemyTank.removeFromParent()
        }
        enemyTanks.removeAll()
        
        for explosion in explosions {
            explosion.removeFromParent()
        }
        explosions.removeAll()
        
        for missile in missiles {
            missile.removeFromParent()
        }
        missiles.removeAll()
        
        // Reset score and tanks destroyed counter
        score = 0
        tanksDestroyed = 0
        updateScoreDisplay()
        
        // Reset power-up system
        powerUpManager?.reset()
        
        // Reset power-up status
        rapidFireActive = false
        damageBoostActive = false
        shieldActive = false
        missileAutoFireActive = false
        
        // Reset board number
        currentBoardNumber = 1
        
        // Reset to level 1
        currentLevel = 1
        levelLabel?.text = "LEVEL: \(currentLevel)"
        
        // Update battlefield reference for the new player tank
        battlefield?.updatePlayerTank(playerTank!)
        
        // Set up level with the current level
        setupLevel()
        
        // Resume game
        isRunning = true
    }
    
    func exitGame() {
        // This would normally exit to the main menu, but for now just restart
        restartGame()
    }
    
    // MARK: - Touch Handling
    
    private var touchStartPosition: CGPoint?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        // Record touch start position
        touchStartPosition = location
        
        // Check if we're touching any buttons on game over screen
        if isGameOver {
            handleGameOverScreenTouch(at: location)
            return
        }
        
        // Check if we're touching any buttons on game complete screen
        if isGameComplete {
            handleGameCompleteScreenTouch(at: location)
            return
        }
        
        // Check if level complete screen is active
        if isLevelComplete {
            let currentTime = CACurrentMediaTime()
            if currentTime - victoryStartTime >= levelCompletionDelay {
                proceedToNextLevel()
            }
            return
        }
        
        // Normal gameplay touch handling
        if !isPlayerDestroyed && !isGameEnding {
            handlePlayerFiring(at: location, currentTime: CACurrentMediaTime())
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        // Skip if in game over or level complete state
        if isGameOver || isLevelComplete || isPlayerDestroyed || isGameEnding { return }
        
        // Handle player movement
        handlePlayerMovement(to: location)
        
        // If we have rapid fire, also handle firing while moving
        if rapidFireActive {
            handlePlayerFiring(at: location, currentTime: CACurrentMediaTime())
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchStartPosition = nil
    }
    
    private func handleGameOverScreenTouch(at location: CGPoint) {
        if let restartButton = childNode(withName: "//restartButton") {
            if restartButton.contains(location) {
                restartGame()
            }
        }
        
        if let exitButton = childNode(withName: "//exitButton") {
            if exitButton.contains(location) {
                exitGame()
            }
        }
    }
    
    private func handleGameCompleteScreenTouch(at location: CGPoint) {
        if let playAgainButton = childNode(withName: "//playAgainButton") {
            if playAgainButton.contains(location) {
                restartGame()
            }
        }
        
        if let exitButton = childNode(withName: "//exitButton") {
            if exitButton.contains(location) {
                exitGame()
            }
        }
    }
    
    // MARK: - Helper Methods
    
    func createExplosion(at position: CGPoint) {
        let explosion = Explosion(position: position)
        addChild(explosion)
        explosions.append(explosion)
        soundManager?.playSound(.explosion)
    }
    
    // Add bullet to the game
    func addBullet(_ bullet: Bullet) {
        addChild(bullet)
        bullets.append(bullet)
    }
}
