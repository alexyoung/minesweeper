//
//  GameScene.swift
//  Minesweeper
//
//  Created by Alex Young on 24/01/2016.
//  Copyright (c) 2016 Alex Young. All rights reserved.
//

import SpriteKit

let aKey = 0, bKey = 11, upKey = 126, downKey = 125, leftKey = 123, rightKey = 124
// up up down down left right left right B A
let cheatCode = "\(upKey)\(upKey)\(downKey)\(downKey)\(leftKey)\(rightKey)\(leftKey)\(rightKey)\(bKey)\(aKey)"

class GameScene: SKScene {
    let scoreBarHeight = CGFloat(60)
    let scoreBoard = ScoreBoard.sharedInstance

    var cheatMode = false
    var lastCheatAttempt = ""
    var scoreBar: SKShapeNode! = nil
	var minefield: Minefield
    var keypresses = ""
    
    required init?(coder aDecoder: NSCoder) {
        minefield = Minefield(width: 10, height: 10, difficulty: 20, level: 1)
        super.init(coder: aDecoder)
        self.createGameUI()
        self.createBoard()
    }
    
    internal override func keyDown(theEvent: NSEvent) {
    }

    internal override func keyUp(theEvent: NSEvent) {
        handleKeyEvent(theEvent, keyDown: false)
    }

    internal func handleKeyEvent(event: NSEvent, keyDown: Bool) {
        let character = Int(event.keyCode)

        switch character {
        case aKey, bKey, upKey, downKey, leftKey, rightKey:
            lastCheatAttempt += String(character)
            if !cheatCode.containsString(lastCheatAttempt) {
                lastCheatAttempt = ""
            } else if (lastCheatAttempt == cheatCode) {
                cheatMode = true
                let action = SKAction.playSoundFileNamed("cheat", waitForCompletion: false)
                runAction(action, withKey: "sound")
                showHints()
                updateBoard()
            }
            break
        default:
            super.keyDown(event)
        }
    }
    
    func createGameUI() {
        let size = CGSize(width: CGFloat(self.frame.size.width), height: CGFloat(scoreBarHeight))
        scoreBar = SKShapeNode(rect: CGRect(origin: CGPoint(x: 0, y: 0), size: size))
        let label = SKLabelNode(fontNamed: "HelveticaNeue-Thin")
        
        label.position = CGPointMake(CGRectGetMidX(self.frame), 18)
        label.name = "label"
        scoreBar.zPosition = 2000
        scoreBar.fillColor = SKColor.blackColor()
        scoreBar.strokeColor = SKColor.blackColor()
        
        scoreBar.addChild(label)
        self.addChild(scoreBar)
    }
    
    func updateGameUI() {
        let label = scoreBar.childNodeWithName("label") as! SKLabelNode
        label.text = String(format: "SCORE: %05d, LEVEL: %d", minefield.score, minefield.level)
    }

	func createBoard() {
		let pieceWidth = Int(frame.width) / minefield.width
		let pieceHeight = Int(frame.height - scoreBarHeight) / minefield.height
		let offsetX = pieceWidth / 2
		let offsetY = (pieceHeight / 2) + Int(scoreBarHeight)
		
		for y in 0..<minefield.height {
			for x in 0..<minefield.width {
                // TODO: Make this a SKShapeNode instead
				let node = SKSpriteNode(color: SKColor.grayColor(), size: CGSize(width: pieceWidth - 4, height: pieceHeight - 4))
				let position = CGPoint(x: offsetX + (x * pieceWidth) + 2, y: offsetY + (y * pieceHeight) + 4)
				let label = SKLabelNode(fontNamed: "HelveticaNeue-Thin")
				
				node.position = position
				node.name = "\(x),\(y)"
				
				label.userInteractionEnabled = false
				label.name = "L: \(x),\(y)"
				label.text = ""

				if minefield.hasMineAt(x, y: y) {
					label.fontColor = SKColor.redColor()
				} else if minefield.hasHiddenAt(x, y: y) {
					label.fontColor = SKColor.greenColor()
				} else {
					label.fontColor = SKColor.grayColor()
				}
				
				node.addChild(label)
				self.addChild(node)
			}
		}

        showHints()
        updateGameUI()
	}
    
    func showHints() {
        let safePos = minefield.randomSafePosition()
        if let node = self.childNodeWithName("\(safePos.0),\(safePos.1)") as! SKSpriteNode? {
            if let label = node.childNodeWithName("L: \(safePos.0),\(safePos.1)") as! SKLabelNode? {
                label.text = "😜"
            }
        }
        
        if cheatMode {
            for y in 0..<minefield.height {
                for x in 0..<minefield.width {
                    if minefield.hasMineAt(x, y: y) {
                        if let node = childNodeWithName("\(x),\(y)") as? SKSpriteNode, let label = node.childNodeWithName("L: \(x),\(y)") as? SKLabelNode {
                            label.text = "💣"
                        }
                    }
                }
            }
        }
    }

	func updateBoard() {
		for y in 0..<minefield.height {
			for x in 0..<minefield.width {
                let node: SKSpriteNode = childNodeWithName("\(x),\(y)") as! SKSpriteNode

				if minefield.hasSafeAt(x, y: y) {
					node.color = SKColor.darkGrayColor()
					
					if let label = node.childNodeWithName("L: \(x),\(y)") as? SKLabelNode {
						let labelText = minefield.getLabelAt(x, y: y)
						if labelText > 0 {
							label.text = String(labelText)
						}
					}
                } else if minefield.gameState == .Lost && minefield.hasMineAt(x, y: y) {
                    node.color = SKColor.darkGrayColor()

                    if let label = node.childNodeWithName("L: \(x),\(y)") as? SKLabelNode {
                        label.text = "💣"
                    }
                }
			}
		}
        
        updateGameUI()
	}
    
	override func mouseDown(theEvent: NSEvent) {
		let location = theEvent.locationInNode(self)
		let nodes = self.nodesAtPoint(location)
		
		for node in nodes {
			if node.name == nil { continue }

			let fieldInfo = node.name!.componentsSeparatedByString(",")
			
            if minefield.gameState == .Lost && node.name == "Button: Continue Game" {
                if scoreBoard.isHighScore(minefield.score) {
                    transitionToHighScoreScreen()
                } else {
                    transitionToStartScreen()
                }
                return
            } else if minefield.gameState == .Won && node.name == "Button: Next Level" {
                nextLevel()
                return
            } else if minefield.gameState == .Playing {
                if let x = Int(fieldInfo[0]), let y = Int(fieldInfo[1]) {
					if minefield.hasMineAt(x, y: y) {
                        animateNode(node)
                        minefield.gameState = .Lost
                        scoreBoard.registerHighScore(minefield.score)
                        showGameOver()
                        
                        let action = SKAction.playSoundFileNamed("explode", waitForCompletion: false)
                        runAction(action, withKey: "sound")
					} else if minefield.hasHiddenAt(x, y: y) {
						minefield.toggleTileAt(x, y: y)
                        animateNode(node)
					}
                    
                    if minefield.gameState == .Won {
                        showGameWon()
                    }
				}
            } else if minefield.gameState == .WonForever {
                if scoreBoard.isHighScore(minefield.score) {
                    scoreBoard.registerHighScore(minefield.score)
                    transitionToHighScoreScreen()
                } else {
                    transitionToStartScreen()
                }
            }
		}
        
        updateBoard()
	}
    
    func animateNode(node: SKNode) {
        let duration = NSTimeInterval(0.333)
        let action = SKAction.customActionWithDuration(duration, actionBlock: {
            (n, elapsedTime) in
            n.xScale = sin(CGFloat(M_PI / 2) * elapsedTime / CGFloat(duration))
        })
        
        node.runAction(action)
    }
    
    func lolAnimateNode(node: SKNode) {
        let duration = NSTimeInterval(100)
        let action = SKAction.customActionWithDuration(duration, actionBlock: {
            (n, elapsedTime) in
            n.xScale += 0.02
            n.yScale += 0.02
        })
        
        node.runAction(action)
    }
    
    func showGameOver() {
        let dimmerColor = SKColor.init(calibratedRed: 0.0, green: 0.0, blue: 0.0, alpha: 0.666)
        let dimmer = SKSpriteNode(color: dimmerColor, size: frame.size)
        let label = SKLabelNode(fontNamed: "HelveticaNeue-Thin")
        let button = SKShapeNode()
        
        dimmer.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))

        label.text = "🔥 Game over 🔥"
        label.fontColor = SKColor.whiteColor()
        label.position.y -= 10
        
        button.path = CGPathCreateWithRoundedRect(CGRectMake(-200, -22, 400, 44), 4, 4, nil)
        button.strokeColor = SKColor.grayColor()
        button.fillColor = SKColor.darkGrayColor()
        button.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        
        button.name = "Button: Continue Game"
        label.name = "Button: Continue Game"
        
        // zPosition
        dimmer.zPosition = 1000
        button.zPosition = 1001
        label.zPosition = 1002
        
        for node in children {
            if node != scoreBar {
                lolAnimateNode(node)
            }
        }
        
        self.addChild(dimmer)
        self.addChild(button)
        button.addChild(label)
    }
    
    func showGameWon() {
        let dimmerColor = SKColor.init(calibratedRed: 0.0, green: 0.0, blue: 0.0, alpha: 0.666)
        let dimmer = SKSpriteNode(color: dimmerColor, size: frame.size)
        let label = SKLabelNode(fontNamed: "HelveticaNeue-Thin")
        let button = SKShapeNode()
        
        dimmer.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        
        if minefield.gameState == .WonForever {
            label.text = "🚀 You won ALL GAMES! 👏"
        } else {
            label.text = "🚀 You won the game! 👏"
        }

        label.fontColor = SKColor.whiteColor()
        label.position.y -= 10
        
        button.path = CGPathCreateWithRoundedRect(CGRectMake(-200, -22, 400, 44), 4, 4, nil)
        button.strokeColor = SKColor.grayColor()
        button.fillColor = SKColor.darkGrayColor()
        button.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        
        dimmer.name = "Dimmer"
        button.name = "Button: Next Level"
        label.name = "Button: Next Level"
        
        // zPosition
        dimmer.zPosition = 1000
        button.zPosition = 1001
        label.zPosition = 1002
        
        self.addChild(dimmer)
        self.addChild(button)
        button.addChild(label)
    }

    func transitionToHighScoreScreen() {
        AppDelegate.transitionToScene(scene, sceneName: "HighScoreScene")
    }

    func transitionToStartScreen() {
        AppDelegate.transitionToScene(scene, sceneName: "StartScene")
    }
    
    func nextLevel() {
        self.minefield.nextLevel()
        
        if let dimmer = self.childNodeWithName("Dimmer") {
            dimmer.removeFromParent()
        }
        
        if let button = self.childNodeWithName("Button: Next Level") {
            button.removeFromParent()
        }
        
        for node in children {
            node.removeFromParent()
        }

        createBoard()
        createGameUI()
        updateBoard()
        
        if minefield.gameState == .WonForever {
            showGameWon()
        }
    }

    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
