//
//  StartScene.swift
//  Minesweeper
//
//  Created by Alex Young on 25/01/2016.
//  Copyright © 2016 Alex Young. All rights reserved.
//

import SpriteKit

class HighScoreScene: SKScene {
    var highScoreName: String! = nil
    var label = SKLabelNode(fontNamed: "Courier New")
    var lastIndex = 0
    
    override func didMoveToView(view: SKView) {
        label.text = "???"
        label.fontColor = SKColor.greenColor()
        label.position.x = CGRectGetMidX(self.frame)
        label.position.y = 100
        
        let titleLabel = SKLabelNode(fontNamed: "HelveticaNeue-Thin")
        titleLabel.text = "You got a high score! Enter name"
        titleLabel.position.x = CGRectGetMidX(self.frame)
        titleLabel.position.y = 160
        
        backgroundColor = SKColor.blackColor()

        addChild(label)
        addChild(titleLabel)
    }
    
    internal override func keyUp(theEvent: NSEvent) {
        handleKeyEvent(theEvent, keyDown: false)
    }
    
    private func isAcceptableCharacter(character: Character) -> Bool {
        if (character >= "a" && character <= "z") || (character >= "A" && character <= "Z") {
            return true
        } else if character >= "0" && character <= "9" {
            return true
        }
        
        return false
    }
    
    internal func handleKeyEvent(event: NSEvent, keyDown: Bool) {
        if let characters = event.characters {
            for character in characters.characters {
                if isAcceptableCharacter(character) {
                    if var text = label.text {
                        let startIndex = text.startIndex.advancedBy(lastIndex)
                        let endIndex = startIndex.advancedBy(1)
                        let range = Range(start: startIndex, end: endIndex)
                        text.replaceRange(range, with: String(character).uppercaseString) //String(character).uppercaseString
                        label.text = text
                        lastIndex++
                        lastIndex = lastIndex % 3
                    }
                } else if (character == "\r") {
                    let scoreBoard = ScoreBoard.sharedInstance
                    scoreBoard.add(label.text ?? "???")
                    AppDelegate.transitionToScene(scene, sceneName: "StartScene")
                }
            }
        }
    }

    override func mouseDown(theEvent: NSEvent) {
    }
    
    override func mouseUp(theEvent: NSEvent) {
    }
}