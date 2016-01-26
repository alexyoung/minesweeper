//
//  Minefield.swift
//  MineSweeper
//
//  Created by Alex Young on 23/01/2016.
//  Copyright (c) 2016 Alex Young. All rights reserved.
//

import Foundation

enum Floor {
	case Hidden
	case Safe
	case Mine
}

enum GameState {
    case Playing
    case Won
    case Lost
    case WonForever
}

class Minefield {
	var board: [[Floor]]
	var labels: [[Int]]
    var neighboursSeen = 0
	var mineCount = 0
    var gameState: GameState = .Playing
    var score = 0
    var level = 1
	var difficulty: Int

	let width: Int
	let height: Int
    let scoreMultiplier = 100
	
    init(width: Int, height: Int, difficulty: Int, level: Int) {
		board = [[Floor]](count: height, repeatedValue: [Floor](count: width, repeatedValue: Floor.Hidden))
		labels = [[Int]](count: height, repeatedValue: [Int](count: width, repeatedValue: 0))
		self.width = width
		self.height = height
		self.difficulty = difficulty
        self.level = level
		
		layMines()
	}
	
	func layMines() {
		for y in (0..<height) {
			for x in (0..<width) {
				if random() % 100 < difficulty {
					board[y][x] = Floor.Mine
					mineCount++
					setLabels(x, mineY: y)
				}
			}
		}
        
        if mineCount == width * height {
            gameState = .WonForever
        }
	}
	
	func setLabels(mineX: Int, mineY: Int) {
		for px in -1..<2 {
			for py in -1..<2 {
				if 0 == px && 0 == py {
					labels[mineY][mineX] = mineCount
				} else if between(mineX + px, a: 0, b: width - 1) && between(mineY + py, a: 0, b: height - 1) {
					labels[mineY + py][mineX + px]++
				}
			}
		}
	}

	func getLabelAt(x: Int, y: Int) -> Int {
		return labels[y][x]
	}
	
	func hasMineAt(x: Int, y: Int) -> Bool {
		return board[y][x] == Floor.Mine
	}
	
	func hasHiddenAt(x: Int, y: Int) -> Bool {
		return board[y][x] == Floor.Hidden
	}
	
	func hasSafeAt(x: Int, y: Int) -> Bool {
		return board[y][x] == Floor.Safe
	}
	
	func between(v: Int, a: Int, b: Int) -> Bool {
		return v >= a && v <= b
	}
	
    func checkWin() {
        if gameState != .Playing {
            return
        }
        
        for y in (0..<height) {
            for x in (0..<width) {
                if board[y][x] == .Hidden {
                    return
                }
            }
        }
        
        gameState = .Won
    }
    
    func nextLevel() {
        mineCount = 0
        difficulty += 5
        level++
        score += 1000
        board = [[Floor]](count: height, repeatedValue: [Floor](count: width, repeatedValue: Floor.Hidden))
        labels = [[Int]](count: height, repeatedValue: [Int](count: width, repeatedValue: 0))
        gameState = .Playing
        layMines()
    }
    
    func randomSafePosition() -> (Int, Int) {
        var safeCoords = [(Int, Int)]()
        
        for y in (0..<height) {
            for x in (0..<width) {
                if board[y][x] != .Mine {
                    safeCoords.append((x, y))
                }
            }
        }
        
        if safeCoords.count == 0 {
            return (0, 0)
        } else {
            return safeCoords[random() % safeCoords.count]
        }
    }
    
    func toggleTileAt(x: Int, y: Int) {
        neighboursSeen--
        
        neighbourLoop: for px in -1..<2 {
            for py in -1..<2 {
                if between(x + px, a: 0, b: width - 1) && between(y + py, a: 0, b: height - 1) && board[y + py][x + px] == Floor.Hidden {
                    board[y + py][x + px] = Floor.Safe
                    score += scoreMultiplier
                    neighboursSeen++

                    if labels[y + py][x + px] == 0 {
                        toggleTileAt(x + px, y: y + py)
                    }
                }
            }
        }

        checkWin()
    }
}