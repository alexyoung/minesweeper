//
//  ScoreBoard.swift
//  Minesweeper
//
//  Created by Alex Young on 26/01/2016.
//  Copyright © 2016 Alex Young. All rights reserved.
//

import Foundation

struct Score {
    let name: String
    let score: Int
}

class ScoreBoard : SequenceType {
    let max = 10
    let names = ["XZZ", "AAA", "BUB",  "BOB", "MTJ", "NSO"]
    var scores = [Score]()
    var lastHighScore = 0
    
    static let sharedInstance = ScoreBoard()
    
    private init() {
        loadScores()
    }
    
    private func loadScores() {
        if scores.count == 0 {
            for _ in 0..<max {
                add(randomName(), score: 100 + random() % 10000)
            }
        }
    }
    
    func registerHighScore(score: Int) {
        lastHighScore = score
    }
    
    func add(name: String) {
        add(name, score: lastHighScore)
    }

    func add(name: String, score: Int) {
        let s = Score(name: name, score: score)
        scores.append(s)
        scores.sortInPlace({ $0.score < $1.score })
        while scores.count > max {
            scores.removeFirst()
        }
    }
    
    // TODO
    func isHighScore(score: Int) -> Bool {
        return true
    }
    
    func clear() {
        scores.removeAll()
    }
    
    func generate() -> AnyGenerator<Score> {
        var nextIndex = scores.count - 1
        return anyGenerator {
            if nextIndex < 0 {
                return nil
            }

            return self.scores[nextIndex--]
        }
    }
    
    private func randomName() -> String {
        return names[random() % names.count]
    }
}