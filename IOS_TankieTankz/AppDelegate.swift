//
//  AppDelegate.swift
//  IOS_TankieTankz
//
//  Created by Joseph Mark Orimoloye on 4/24/25.
//

import UIKit
import AVFoundation

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Set up audio session for game sounds
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error.localizedDescription)")
        }
        
        // System appearance customization
        UINavigationBar.appearance().barStyle = .black
        
        // Prevent device from sleeping during gameplay
        UIApplication.shared.isIdleTimerDisabled = true
        
        return true
    }
    
    // MARK: UISceneSession Lifecycle (opt-out)
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Return minimal configuration for scene support requirement
        let config = UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
        config.delegateClass = nil // No scene delegate
        return config
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Pause the game when interrupted (e.g., phone call)
        NotificationCenter.default.post(name: NSNotification.Name("GameShouldPause"), object: nil)
        
        // Allow device to sleep when app is inactive
        UIApplication.shared.isIdleTimerDisabled = false
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Save game state if needed
        NotificationCenter.default.post(name: NSNotification.Name("GameShouldSaveState"), object: nil)
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Prepare to resume the game
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Resume the game
        NotificationCenter.default.post(name: NSNotification.Name("GameShouldResume"), object: nil)
        
        // Prevent device from sleeping during gameplay
        UIApplication.shared.isIdleTimerDisabled = true
    }
}

