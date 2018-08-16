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
    case foul
    case tech
    case both

    func message(for player: Player) -> String {
        switch self {
        case .both: return "\(player.name) has reached the foul and tech limit!"
        case .foul: return "\(player.name) has reached the foul limit!"
        case .tech: return "\(player.name) has reached the tech limit!"
        }
    }
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

    var winnersName: String? {
        var winnerName: String?

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

    func checkPlayerInfractions(player: Player) -> Infraction? {
        var infraction: Infraction?

        if player.currentGameFouls >= foulLimit && player.currentGameTechs >= techLimit {
            player.isOverGameLimit = true
            infraction = Infraction.both
        }
        else if player.currentGameFouls >= foulLimit {
            player.isOverGameLimit = true
            infraction = Infraction.foul
        }
        else if player.currentGameTechs >= techLimit {
            player.isOverGameLimit = true
            infraction = Infraction.tech
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
            if let winnersName = winnersName {
                return GameEnding.series("\(winnersName)")
            }

            return nil
        } else {
            gameNumber += 1
            return GameEnding.game(gameNumber)
        }
    }

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
