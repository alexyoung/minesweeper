//
//  StartScene.swift
//  Minesweeper
//
//  Created by Alex Young on 25/01/2016.
//  Copyright © 2016 Alex Young. All rights reserved.
//

import SpriteKit

class StartScene: SKScene {
    var label: SKLabelNode! = nil
    var button: SKShapeNode! = nil
    var scoreBoard = ScoreBoard.sharedInstance
    
    override func didMoveToView(view: SKView) {
        label = SKLabelNode(fontNamed: "HelveticaNeue-Thin")
        label.text = "Let's sweep some mines 💣"
        label.fontColor = SKColor.whiteColor()
        label.position.y -= 10

        button = SKShapeNode()
        button.path = CGPathCreateWithRoundedRect(CGRectMake(-200, -22, 400, 44), 4, 4, nil)
        button.strokeColor = SKColor.grayColor()
        button.fillColor = SKColor.darkGrayColor()
        button.position = CGPoint(x: CGRectGetMidX(self.frame), y: 60)
        
        button.name = "Button: Start Game"
        label.name = "Button: Start Game"
        
        let title = SKLabelNode(fontNamed: "HelveticaNeue-Thin")
        title.text = "Mine Sweeper 🤔"
        title.fontColor = SKColor.blackColor()
        title.fontSize = 90
        title.position = CGPoint(x: CGRectGetMidX(self.frame), y: self.frame.height - 120)
        
        let background = SKSpriteNode(imageNamed: "minefield")
        background.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        background.size = frame.size
        
        // zPositions
        title.zPosition = 1
        background.zPosition = 0
        button.zPosition = 1
        label.zPosition = 2

        self.addChild(background)
        self.addChild(title)
        self.addChild(button)
        button.addChild(label)
        
        renderScoreBoard()
    }
    
    override func keyDown(theEvent: NSEvent) {
        if (theEvent.keyCode == 36) {
            showNextScene()
        }
    }
    
    func renderScoreBoard() {
        let height = self.frame.height
        let size = CGSize(width: CGFloat(frame.width), height: CGFloat(height))
        let scoreBox = SKShapeNode(rect: CGRect(origin: CGPoint(x: CGRectGetMidX(frame), y: CGRectGetMidY(frame)), size: size))
        var yOffset = CGFloat(500)
        
        for (i, score) in scoreBoard.enumerate() {
            let scoreLabel = SKLabelNode(fontNamed: "Courier New")
            scoreLabel.text = String(format: "%d. %@ %05d", i + 1, score.name, score.score)
            scoreLabel.fontColor = SKColor.greenColor()
            scoreLabel.zPosition = 1000
            scoreLabel.position.x = CGRectGetMidX(self.frame)
            scoreLabel.position.y = yOffset
            yOffset -= CGFloat(30)
            scoreBox.addChild(scoreLabel)
        }
        
        addChild(scoreBox)
    }
    
    override func mouseDown(theEvent: NSEvent) {
        let location = theEvent.locationInNode(self)
        let node = self.nodeAtPoint(location)
        
        if node.name == "Button: Start Game" {
            button.strokeColor = SKColor.grayColor()
            button.fillColor = SKColor.grayColor()
            label.fontColor = SKColor.darkGrayColor()
        }
    }
    
    override func mouseUp(theEvent: NSEvent) {
        let location = theEvent.locationInNode(self)
        let node = self.nodeAtPoint(location)
        
        if node.name == "Button: Start Game" {
            button.strokeColor = SKColor.grayColor()
            button.fillColor = SKColor.darkGrayColor()
            label.fontColor = SKColor.whiteColor()
            
            showNextScene()
        }
    }
    
    func showNextScene() {
        //AppDelegate.transitionToScene(scene, sceneName: "HighScoreScene")
        AppDelegate.transitionToScene(scene, sceneName: "GameScene")
    }
}