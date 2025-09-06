//
//  SoundManager.swift
//  IOS_TankieTankz
//
//  Created by Joseph Mark Orimoloye on 4/24/25.
//

import AVFoundation
import SpriteKit

enum SoundType {
    case playerShoot
    case enemyShoot
    case playerMove
    case enemyMove
    case explosion
    case victory
    case finalVictory
    case powerUpCollect
    case powerUpActivate
    case powerUpExpire
    case missileFire
    case missileImpact
    case enemyHit
    case playerHit
    case bossTankMove
}

class SoundManager {
    private var audioPlayers: [SoundType: AVAudioPlayer] = [:]
    private var soundEffects: [SoundType: SystemSoundID] = [:]
    private var lastPlayedTime: [SoundType: TimeInterval] = [:]
    private let minTimeBetweenSounds: TimeInterval = 0.1 // 100ms between identical sounds
    
    init() {
        setupSounds()
    }
    
    private func setupSounds() {
        // For OGG files from the original game, we would need to convert them
        // or use a 3rd party library. For now, we'll use system sounds or create
        // simple AVAudioPlayer instances with CAF/MP3 files.
        
        // MARK: - TODO: Convert OGG files to CAF or MP3
        
        // Create tone-based fallback sounds for development
        createToneBasedSounds()
    }
    
    private func createToneBasedSounds() {
        // Load actual audio files from the bundle
        loadAudioFile(.playerShoot, fileName: "player_shoot", fileExtension: "caf")
        loadAudioFile(.enemyShoot, fileName: "enemy_shoot", fileExtension: "caf")
        loadAudioFile(.playerMove, fileName: "player_move", fileExtension: "caf")
        loadAudioFile(.enemyMove, fileName: "enemy_move", fileExtension: "caf")
        loadAudioFile(.explosion, fileName: "explosion", fileExtension: "caf")
        loadAudioFile(.enemyHit, fileName: "enemy_hit", fileExtension: "caf")
        loadAudioFile(.playerHit, fileName: "player_hit", fileExtension: "caf")
        loadAudioFile(.bossTankMove, fileName: "boss_tank_move", fileExtension: "caf")
        
        // Victory sounds - use system sound fallbacks since iOS doesn't support OGG natively
        setupSystemSoundFallback(for: .victory)
        setupSystemSoundFallback(for: .finalVictory)
        
        // Use default system sounds for missing audio
        setupSystemSoundFallbacks()
    }
    
    private func loadAudioFile(_ soundType: SoundType, fileName: String, fileExtension: String) {
        if let path = Bundle.main.path(forResource: fileName, ofType: fileExtension) {
            let url = URL(fileURLWithPath: path)
            do {
                let player = try AVAudioPlayer(contentsOf: url)
                player.prepareToPlay()
                player.volume = 0.7 // Set reasonable volume
                audioPlayers[soundType] = player
                print("✅ Loaded audio: \(fileName).\(fileExtension)")
            } catch {
                print("❌ Error loading audio file \(fileName).\(fileExtension): \(error)")
                setupSystemSoundFallback(for: soundType)
            }
        } else {
            print("❌ Audio file not found: \(fileName).\(fileExtension)")
            setupSystemSoundFallback(for: soundType)
        }
    }
    
    private func setupSystemSoundFallbacks() {
        // Set up system sound fallbacks for any missing audio
        for soundType in [SoundType.powerUpCollect, .powerUpActivate, .powerUpExpire, .missileFire, .missileImpact] {
            if audioPlayers[soundType] == nil {
                setupSystemSoundFallback(for: soundType)
            }
        }
    }
    
    private func setupSystemSoundFallback(for soundType: SoundType) {
        let systemSoundId: SystemSoundID = switch soundType {
        case .playerShoot, .enemyShoot: 1103 // Tock sound
        case .explosion, .enemyHit, .playerHit: 1005 // New mail sound
        case .powerUpCollect, .powerUpActivate: 1000 // Click sound
        case .victory, .finalVictory: 1016 // Horn sound
        default: 1103 // Default tock sound
        }
        soundEffects[soundType] = systemSoundId
    }
    
    func playSound(_ type: SoundType) {
        let currentTime = CACurrentMediaTime()
        
        // Rate limiting to prevent sound spam
        if let lastPlayed = lastPlayedTime[type], currentTime - lastPlayed < minTimeBetweenSounds {
            return
        }
        
        // Record time of play
        lastPlayedTime[type] = currentTime
        
        // Try to play with AVAudioPlayer first
        if let player = audioPlayers[type] {
            if !player.isPlaying {
                player.currentTime = 0
                player.play()
            } else {
                // Create a duplicate player for overlapping sounds
                if let url = player.url {
                    do {
                        let newPlayer = try AVAudioPlayer(contentsOf: url)
                        newPlayer.volume = player.volume
                        newPlayer.play()
                    } catch {
                        print("Error creating duplicate audio player: \(error)")
                    }
                }
            }
            return
        }
        
        // Fall back to system sound if available
        if let soundID = soundEffects[type] {
            AudioServicesPlaySystemSound(soundID)
            return
        }
        
        // As a last resort, use SKAction for sounds
        playFallbackSound(type)
    }
    
    private func playFallbackSound(_ type: SoundType) {
        // Create basic sound actions as a fallback when audio files aren't available
        // This is just a development placeholder and would be replaced with real sounds
        
        // For the ported game, we would use SKAudioNode or SKAction.playSoundFileNamed
        // with properly converted audio files
        
        let soundAction: SKAction
        
        switch type {
        case .playerShoot:
            soundAction = SKAction.playSoundFileNamed("player_shoot.caf", waitForCompletion: false)
        case .enemyShoot:
            soundAction = SKAction.playSoundFileNamed("enemy_shoot.caf", waitForCompletion: false)
        case .playerMove:
            soundAction = SKAction.playSoundFileNamed("player_move.caf", waitForCompletion: false)
        case .enemyMove:
            soundAction = SKAction.playSoundFileNamed("enemy_move.caf", waitForCompletion: false)
        case .explosion:
            soundAction = SKAction.playSoundFileNamed("explosion.caf", waitForCompletion: false)
        case .victory:
            soundAction = SKAction.playSoundFileNamed("victory.caf", waitForCompletion: false)
        case .finalVictory:
            soundAction = SKAction.playSoundFileNamed("final_victory.caf", waitForCompletion: false)
        case .powerUpCollect:
            soundAction = SKAction.playSoundFileNamed("power_up_collect.caf", waitForCompletion: false)
        case .powerUpActivate:
            soundAction = SKAction.playSoundFileNamed("power_up_activate.caf", waitForCompletion: false)
        case .powerUpExpire:
            soundAction = SKAction.playSoundFileNamed("power_up_expire.caf", waitForCompletion: false)
        case .missileFire:
            soundAction = SKAction.playSoundFileNamed("missile_fire.caf", waitForCompletion: false)
        case .missileImpact:
            soundAction = SKAction.playSoundFileNamed("missile_impact.caf", waitForCompletion: false)
        case .enemyHit:
            soundAction = SKAction.playSoundFileNamed("enemy_hit.caf", waitForCompletion: false)
        case .playerHit:
            soundAction = SKAction.playSoundFileNamed("player_hit.caf", waitForCompletion: false)
        case .bossTankMove:
            soundAction = SKAction.playSoundFileNamed("boss_tank_move.caf", waitForCompletion: false)
        }
        
        // Create a dummy node to play the sound
        // In a real implementation, these sounds would be played through the GameScene
        let dummyNode = SKNode()
        dummyNode.run(SKAction.sequence([soundAction, SKAction.removeFromParent()]))
        
        // Since we're not in a scene context here, we can't actually play the sound
        // This would need to be handled by playing sounds through the GameScene
        // This is just a placeholder implementation
    }
    
    func preloadSounds() {
        // In a full implementation, we would preload all sounds here
        // to ensure they're ready to play with minimal latency
        
        // For AVAudioPlayer instances:
        for player in audioPlayers.values {
            player.prepareToPlay()
        }
    }
    
    func stopAllSounds() {
        // Stop all currently playing sounds
        for player in audioPlayers.values {
            if player.isPlaying {
                player.stop()
            }
        }
    }
}