//
//  AppDelegate.swift
//  Minesweeper
//
//  Created by Alex Young on 24/01/2016.
//  Copyright (c) 2016 Alex Young. All rights reserved.
//


import Cocoa
import SpriteKit

extension SKScene {
    static func sceneWithClassNamed(className: String, fileNamed fileName: String) -> SKScene? {
        guard let SceneClass = NSClassFromString("Minesweeper.\(className)") as? SKScene.Type,
            let scene = SceneClass.init(fileNamed: fileName) else { return nil }
        
        return scene
    }
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var skView: SKView!
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        if let scene = SKScene.sceneWithClassNamed("StartScene", fileNamed: "StartScene") {
            scene.scaleMode = .Fill
            
            self.skView!.presentScene(scene)
            self.skView!.ignoresSiblingOrder = true
        }
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication) -> Bool {
        return true
    }
    
    static func transitionToScene(scene: SKScene?, sceneName: String) {
        let transition = SKTransition.revealWithDirection(.Down, duration: 0.33)
        if let nextScene = SKScene.sceneWithClassNamed(sceneName, fileNamed: sceneName) {
            nextScene.scaleMode = .Fill
            
            if scene != nil {
                scene?.view!.ignoresSiblingOrder = true
                
                scene?.view?.presentScene(nextScene, transition: transition)
            }
        }
    }
}
