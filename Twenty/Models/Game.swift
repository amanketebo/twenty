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

enum Infraction: String {
    case foul = "foul"
    case tech = "tech"
    case both = "foul and tech"
}

enum Ending {
    case overtime
    case game(Int)
    case series(String)
}

class Game {
    
    static let regularTimeLimit = 200
    static let overtimeTimeLimit = 100
    var playerOne = Player()
    var playerTwo = Player()
    var gameNumber = 1
    var foulLimit = 0
    var techLimit = 0
    var seriesLimit = 0
    var winsNeeded = 0
    var isOvertime = false
    
    var shouldGoToOvertime: Bool {
        var decision = false
        
        if playerOne.points == playerTwo.points  && playerOne.isOverGameLimit == false && playerTwo.isOverGameLimit == false {
            decision = true
        }
        else if playerOne.points == playerTwo.points && playerOne.isOverGameLimit == true && playerTwo.isOverGameLimit == true {
            decision = true
        }
        else if playerOne.isOverGameLimit == true && playerTwo.isOverGameLimit == true  {
            decision = true
        }
        
        return decision
    }
    
    var shouldEndSeries: Bool {
        var decision = false
        
        if playerOne.gamesWon == winsNeeded || playerTwo.gamesWon == winsNeeded {
            decision = true
        }
        
        return decision
    }
    
    var winnersName: String {
        var winnerName = ""
        
        if playerOne.gamesWon == winsNeeded {
            winnerName = playerOne.name
        }
        else if playerTwo.gamesWon == winsNeeded {
            winnerName = playerTwo.name
        }
        
        return winnerName
    }
    
    init(playerOne: Player, playerTwo: Player) {
        self.playerOne = playerOne
        self.playerTwo = playerTwo
    }
    
    func increaseStats(tagInfo: (playerNumber: Int, sectionNumber: Int)) {
        // sectionNumber is the section in the storyboard that was tapped by user
        // section 1 is for points, section 2 is for fouls, section 3 is for techs
        if tagInfo.playerNumber == 1 {
            if let statType = Stat(rawValue: tagInfo.sectionNumber) {
                switch statType {
                case .point: playerOne.points += 1
                case .foul: playerOne.fouls += 1
                case .tech: playerOne.techs += 1
                }
            }
        }
        else if tagInfo.playerNumber == 2 {
            if let statType = Stat(rawValue: tagInfo.sectionNumber) {
                switch statType {
                case .point: playerTwo.points += 1
                case .foul: playerTwo.fouls += 1
                case .tech: playerTwo.techs += 1
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
                case .point: playerOne.points -= 1
                case .foul: playerOne.fouls -= 1
                case .tech: playerOne.techs -= 1
                }
            }
        }
        else if tagInfo.playerNumber == 2 {
            if let statType = Stat(rawValue: tagInfo.sectionNumber) {
                switch statType {
                case .point: playerTwo.points -= 1
                case .foul: playerTwo.fouls -= 1
                case .tech: playerTwo.techs -= 1
                }
            }
        }
        
    }
    
    func checkPlayerInfractions(player: Player) -> (infraction: Infraction, title: String)? {
        var infractionInfo: (infraction: Infraction, title: String)?
        
        if player.fouls >= foulLimit && player.techs >= techLimit {
            player.isOverGameLimit = true
            infractionInfo = (Infraction.both, "\(player.name) has reached the \(Infraction.both.rawValue) limit!")
        }
        else if player.fouls >= foulLimit {
            player.isOverGameLimit = true
            infractionInfo = (Infraction.foul, "\(player.name) has reached the \(Infraction.foul.rawValue) limit!")
        }
        else if player.techs >= techLimit {
            player.isOverGameLimit = true
            infractionInfo = (Infraction.tech, "\(player.name) has reached the \(Infraction.tech.rawValue) limit!")
        }
        else {
            player.isOverGameLimit = false
        }
        
        return infractionInfo
    }
    
    func addTotals(for player: Player) {
        player.totalPoints += player.points
        player.totalFouls += player.fouls
        player.totalTechs += player.techs
    }
    
    func decideWinner() {
        if playerOne.isOverGameLimit && playerTwo.isOverGameLimit {
            if playerOne.points > playerTwo.points {
                playerOne.gamesWon += 1
                playerTwo.gamesLost += 1
            }
            else {
                playerTwo.gamesWon += 1
                playerOne.gamesLost += 1
            }
        }
        else if playerOne.isOverGameLimit {
            playerTwo.gamesWon += 1
            playerOne.gamesLost += 1
        }
        else if playerTwo.isOverGameLimit {
            playerOne.gamesWon += 1
            playerTwo.gamesLost += 1
        }
        else if playerOne.points > playerTwo.points {
            playerOne.gamesWon += 1
            playerTwo.gamesLost += 1
        }
        else if playerOne.points < playerTwo.points {
            playerTwo.gamesWon += 1
            playerOne.gamesLost += 1
        }
    }
    
    func resetStats() {
        playerOne.points = 0
        playerOne.fouls = 0
        playerOne.techs = 0
        playerOne.isOverGameLimit = false
        
        playerTwo.points = 0
        playerTwo.fouls = 0
        playerTwo.techs = 0
        playerTwo.isOverGameLimit = false
    }
    
    func printPlayers() {
        print("Player : \(playerOne.name)")
        print("   Points: \(playerOne.points)")
        print("   Fouls: \(playerOne.fouls)")
        print("   Techs: \(playerOne.techs)")
        print("   Is Over Game Limit: \(playerOne.isOverGameLimit)")
        print("   Games Won In Series: \(playerOne.gamesWon)")
        print("   Games Lost In Series: \(playerOne.gamesLost)")
        print("   Total Points: \(playerOne.totalPoints)")
        print("   Total Fouls: \(playerOne.totalFouls)")
        print("   Total Techs: \(playerOne.totalTechs)")
        print("Player : \(playerTwo.name)")
        print("   Points: \(playerTwo.points)")
        print("   Fouls: \(playerTwo.fouls)")
        print("   Techs: \(playerTwo.techs)")
        print("   Is Over Game Limit: \(playerTwo.isOverGameLimit)")
        print("   Games Won In Series: \(playerTwo.gamesWon)")
        print("   Games Lost In Series: \(playerTwo.gamesLost)")
        print("   Total Points: \(playerTwo.totalPoints)")
        print("   Total Fouls: \(playerTwo.totalFouls)")
        print("   Total Techs: \(playerTwo.totalTechs)")
    }
    
}
