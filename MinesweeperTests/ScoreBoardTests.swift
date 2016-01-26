//
//  ScoreBoardTests.swift
//  Minesweeper
//
//  Created by Alex Young on 26/01/2016.
//  Copyright © 2016 Alex Young. All rights reserved.
//

import Foundation
import XCTest

@testable import Minesweeper

class ScoreBoardTests: XCTestCase {
    let scoreBoard = ScoreBoard.sharedInstance

    override func setUp() {
        super.setUp()
        scoreBoard.clear()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testAddScore() {
        var scoresSeen = 0

        scoreBoard.add("Alex", score: 1000)
        
        for score in scoreBoard {
            assert(score.name == "Alex")
            scoresSeen++
        }
        
        assert(scoresSeen > 0, "I should have seen some scores!")
    }
    
    func testSortScore() {
        var scoresSeen = 0
        var minScore = 0
        
        scoreBoard.add("A", score: 1000)
        scoreBoard.add("B", score: 1100)
        scoreBoard.add("C", score: 1200)
        
        for score in scoreBoard {
            assert(score.score > minScore)
            minScore = score.score
            scoresSeen++
        }
        
        assert(scoresSeen > 0, "I should have seen some scores!")
    }
    
    func testOnlyStores10() {
        for _ in 0...scoreBoard.max + 1 {
            scoreBoard.add("A", score: random() % 10000)
        }
        
        assert(scoreBoard.scores.count == scoreBoard.max)
    }
}