//
//  Game.swift
//  Twenty
//
//  Created by Amanuel Ketebo on 2/25/17.
//  Copyright © 2017 Amanuel Ketebo. All rights reserved.
//

import Foundation

enum Stat: Int {
    case point = 1
    case foul
    case tech
}

enum Infraction {
    case foul(String)
    case tech(String)
    case both(String)
}

enum GameEnding {
    case overtime
    case game(Int)
    case series(String)
}

class Game {
    static let regularTimeLimit = 200
    static let overtimeTimeLimit = 100
    var playerOne: Player
    var playerTwo: Player
    var gameNumber = 1
    var foulLimit = 0
    var techLimit = 0
    var seriesLimit = 0
    var winsNeeded = 0
    var isOvertime = false
    var players: [Player] {
        return [playerOne, playerTwo]
    }

    var shouldGoToOvertime: Bool {
        var decision = false

        if playerOne.currentGamePoints == playerTwo.currentGamePoints  && playerOne.isOverGameLimit == false && playerTwo.isOverGameLimit == false {
            decision = true
        }
        else if playerOne.currentGamePoints == playerTwo.currentGamePoints && playerOne.isOverGameLimit == true && playerTwo.isOverGameLimit == true {
            decision = true
        }

        return decision
    }

    var shouldEndSeries: Bool {
        var decision = false

        if playerOne.seriesGamesWon == winsNeeded || playerTwo.seriesGamesWon == winsNeeded {
            decision = true
        }

        return decision
    }

    // TODO: Return an optional string in cases where winner can't be determined
    var winnersName: String {
        var winnerName = ""

        if playerOne.seriesGamesWon == winsNeeded {
            winnerName = playerOne.name
        }
        else if playerTwo.seriesGamesWon == winsNeeded {
            winnerName = playerTwo.name
        }

        return winnerName
    }

    init(playerOne: Player, playerTwo: Player) {
        self.playerOne = playerOne
        self.playerTwo = playerTwo
    }

    // TODO: Brainstorm some ways to clean up increasing and decreasing of stats
    //       and making it easier to test
    func increaseStats(tagInfo: (playerNumber: Int, sectionNumber: Int)) {
        // sectionNumber is the section in the storyboard that was tapped by user
        // section 1 is for points, section 2 is for fouls, section 3 is for techs
        if tagInfo.playerNumber == 1 {
            if let statType = Stat(rawValue: tagInfo.sectionNumber) {
                switch statType {
                case .point: playerOne.currentGamePoints += 1
                case .foul: playerOne.currentGameFouls += 1
                case .tech: playerOne.currentGameTechs += 1
                }
            }
        }
        else if tagInfo.playerNumber == 2 {
            if let statType = Stat(rawValue: tagInfo.sectionNumber) {
                switch statType {
                case .point: playerTwo.currentGamePoints += 1
                case .foul: playerTwo.currentGameFouls += 1
                case .tech: playerTwo.currentGameTechs += 1
                }
            }
        }
    }

    func decreaseStats(tagInfo: (playerNumber: Int, sectionNumber: Int)) {
        // sectionNumber is the section in the storyboard that was tapped by user
        // section 1 is for points, section 2 is for fouls, section 3 is for techs
        if tagInfo.playerNumber == 1 {
            if let statType = Stat(rawValue: tagInfo.sectionNumber) {
                switch statType {
                case .point: playerOne.currentGamePoints -= 1
                case .foul: playerOne.currentGameFouls -= 1
                case .tech: playerOne.currentGameTechs -= 1
                }
            }
        }
        else if tagInfo.playerNumber == 2 {
            if let statType = Stat(rawValue: tagInfo.sectionNumber) {
                switch statType {
                case .point: playerTwo.currentGamePoints -= 1
                case .foul: playerTwo.currentGameFouls -= 1
                case .tech: playerTwo.currentGameTechs -= 1
                }
            }
        }
    }

    // TODO: Remove string from Infraction type for better testing
    //       Create function that creates the infraction messages
    func checkPlayerInfractions(player: Player) -> Infraction? {
        var infraction: Infraction?

        if player.currentGameFouls >= foulLimit && player.currentGameTechs >= techLimit {
            player.isOverGameLimit = true
            infraction = Infraction.both("\(player.name) has reached the foul and tech limit!")
        }
        else if player.currentGameFouls >= foulLimit {
            player.isOverGameLimit = true
            infraction = Infraction.foul("\(player.name) has reached the foul limit!")
        }
        else if player.currentGameTechs >= techLimit {
            player.isOverGameLimit = true
            infraction = Infraction.tech("\(player.name) has reached the tech limit!")
        }
        else {
            player.isOverGameLimit = false
        }

        return infraction
    }

    func decideEndOfGame() -> GameEnding? {
        decideGameWinner()

        if shouldGoToOvertime {
            return GameEnding.overtime
        } else if shouldEndSeries {
            return GameEnding.series("\(winnersName)")
        } else {
            gameNumber += 1
            return GameEnding.game(gameNumber)
        }
    }

    // TODO: Fix issue where both players are tied and both are
    //       either over or under the game limits
    func decideGameWinner() {
        addCurrentGameTotalToSeriesTotals()

        if playerOne.isOverGameLimit && playerTwo.isOverGameLimit {
            if playerOne.currentGamePoints > playerTwo.currentGamePoints {
                playerOne.seriesGamesWon += 1
                playerTwo.seriesGamesLost += 1
            }
            else {
                playerTwo.seriesGamesWon += 1
                playerOne.seriesGamesLost += 1
            }
        }
        else if playerOne.isOverGameLimit {
            playerTwo.seriesGamesWon += 1
            playerOne.seriesGamesLost += 1
        }
        else if playerTwo.isOverGameLimit {
            playerOne.seriesGamesWon += 1
            playerTwo.seriesGamesLost += 1
        }
        else if playerOne.currentGamePoints > playerTwo.currentGamePoints {
            playerOne.seriesGamesWon += 1
            playerTwo.seriesGamesLost += 1
        }
        else if playerOne.currentGamePoints < playerTwo.currentGamePoints {
            playerTwo.seriesGamesWon += 1
            playerOne.seriesGamesLost += 1
        }
    }

    func addCurrentGameTotalToSeriesTotals() {
        for player in players {
            player.seriesTotalPoints += player.currentGamePoints
            player.seriesTotalFouls += player.currentGameFouls
            player.seriesTotalTechs += player.currentGameTechs
        }
    }

    func resetStats() {
        for player in players {
            player.currentGamePoints = 0
            player.currentGameFouls = 0
            player.currentGameTechs = 0
            player.isOverGameLimit = false
        }
    }
}
