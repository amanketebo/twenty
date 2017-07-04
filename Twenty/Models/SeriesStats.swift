//
//  Stats.swift
//  Twenty
//
//  Created by Amanuel Ketebo on 3/8/17.
//  Copyright © 2017 Amanuel Ketebo. All rights reserved.
//

import Foundation

struct SeriesStats {
    
    struct PlayerStats {
        var name = ""
        var totalPoints = 0
        var totalFouls = 0
        var totalTechs = 0
        var gamesWon = 0
        var gamesLost = 0
    }
    
    var playerOne = PlayerStats()
    var playerTwo = PlayerStats()
    
    init(game: Game) {
        // Player one setup
        self.playerOne.name = game.playerOne.name
        self.playerOne.totalPoints = game.playerOne.totalPoints
        self.playerOne.totalFouls = game.playerOne.totalFouls
        self.playerOne.totalTechs = game.playerOne.totalTechs
        self.playerOne.gamesWon = game.playerOne.gamesWon
        self.playerOne.gamesLost = game.playerOne.gamesLost
        // Player two setup
        self.playerTwo.name = game.playerTwo.name
        self.playerTwo.totalPoints = game.playerTwo.totalPoints
        self.playerTwo.totalFouls = game.playerTwo.totalFouls
        self.playerTwo.totalTechs = game.playerTwo.totalTechs
        self.playerTwo.gamesWon = game.playerTwo.gamesWon
        self.playerTwo.gamesLost = game.playerTwo.gamesLost
    }
    
}
