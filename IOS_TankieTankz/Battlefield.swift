//
//  Battlefield.swift
//  IOS_TankieTankz
//
//  Created by Joseph Mark Orimoloye on 4/24/25.
//

import SpriteKit

class Battlefield {
    // Reference to the game scene
    private weak var scene: GameScene?
    
    // Game objects
    private var playerTank: BaseTank
    private var bullets: [Bullet]
    private var enemyTanks: [EnemyTank]
    
    // Collision handling
    private var lastBulletHitCheckTime: TimeInterval = 0
    private let bulletHitCheckInterval: TimeInterval = 0.05 // 50ms between checks
    
    init(scene: GameScene, playerTank: BaseTank, bullets: [Bullet], enemyTanks: [EnemyTank]) {
        self.scene = scene
        self.playerTank = playerTank
        self.bullets = bullets
        self.enemyTanks = enemyTanks
    }
    
    func updatePlayerTank(_ tank: BaseTank) {
        self.playerTank = tank
    }
    
    func checkCollisions() {
        let currentTime = CACurrentMediaTime()
        
        // Only check collisions periodically to improve performance
        if currentTime - lastBulletHitCheckTime < bulletHitCheckInterval {
            return
        }
        
        lastBulletHitCheckTime = currentTime
        
        // Check bullet collisions with tanks
        checkBulletTankCollisions()
    }
    
    private func checkBulletTankCollisions() {
        guard let scene = scene else { return }
        
        // Check if player is already destroyed or invulnerable
        let playerIsDestroyed = scene.getPlayerDestroyedState()
        let playerIsInvulnerable = scene.isPlayerInvulnerable()
        
        var bulletsToRemove: [Bullet] = []
        
        for bullet in bullets {
            // Check for collision with player tank
            if bullet.isEnemy && !playerIsDestroyed && !playerIsInvulnerable {
                if checkBulletCollision(bullet: bullet, tankPosition: playerTank.position, tankSize: 50) {
                    // Handle player hit
                    handlePlayerHit(bullet: bullet)
                    bulletsToRemove.append(bullet)
                    continue
                }
            }
            
            // Check for collision with enemy tanks
            if !bullet.isEnemy {
                var hitTank = false
                
                for enemyTank in enemyTanks {
                    if enemyTank.isDestroyed { continue }
                    
                    // Use a larger hit box for boss tanks
                    let tankSize: CGFloat = enemyTank.isBoss ? 75 : 50
                    
                    if checkBulletCollision(bullet: bullet, tankPosition: enemyTank.position, tankSize: tankSize) {
                        // Handle enemy hit
                        handleEnemyHit(bullet: bullet, enemyTank: enemyTank)
                        bulletsToRemove.append(bullet)
                        hitTank = true
                        break
                    }
                }
                
                if hitTank { continue }
            }
        }
        
        // Remove all bullets that hit targets
        for bullet in bulletsToRemove {
            if let index = bullets.firstIndex(of: bullet) {
                bullets.remove(at: index)
            }
            bullet.removeFromParent()
        }
    }
    
    private func checkBulletCollision(bullet: Bullet, tankPosition: CGPoint, tankSize: CGFloat) -> Bool {
        // Simple rectangular collision check
        let bulletSize = bullet.bulletSize
        
        let bulletRect = CGRect(
            x: bullet.position.x - bulletSize/2,
            y: bullet.position.y - bulletSize/2,
            width: bulletSize,
            height: bulletSize
        )
        
        let tankRect = CGRect(
            x: tankPosition.x - tankSize/2,
            y: tankPosition.y - tankSize/2,
            width: tankSize,
            height: tankSize
        )
        
        return bulletRect.intersects(tankRect)
    }
    
    private func handlePlayerHit(bullet: Bullet) {
        guard let scene = scene else { return }
        
        // Calculate damage based on bullet type
        let damage = bullet.fromBoss ? 20 : 10
        
        // Apply damage to player tank
        playerTank.health -= damage
        
        // Set hit effect
        playerTank.isHit = true
        playerTank.hitFlashStartTime = CACurrentMediaTime()
        
        // Play hit sound
        scene.playPlayerHitSound()
        
        // Create impact explosion
        scene.createExplosion(at: bullet.position)
    }
    
    private func handleEnemyHit(bullet: Bullet, enemyTank: EnemyTank) {
        guard let scene = scene else { return }
        
        // Calculate damage based on bullet type and power-ups
        var damage = 10
        
        // Apply damage boost if active
        if scene.isDamageBoostActive() {
            damage *= 2
        }
        
        // Apply damage to enemy tank
        enemyTank.health -= damage
        
        // Set hit effect
        enemyTank.isHit = true
        enemyTank.hitFlashStartTime = CACurrentMediaTime()
        
        // Play hit sound
        scene.playHitSound()
        
        // Create impact explosion if tank is not destroyed
        if enemyTank.health > 0 {
            scene.createExplosion(at: bullet.position)
        } else {
            // Mark tank as destroyed
            enemyTank.isDestroyed = true
            
            // Create bigger explosion at tank center
            scene.createExplosion(at: enemyTank.position)
        }
    }
}