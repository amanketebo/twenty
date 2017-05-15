//
//  Game.swift
//  Twenty
//
//  Created by Amanuel Ketebo on 2/25/17.
//  Copyright © 2017 Amanuel Ketebo. All rights reserved.
//

import Foundation

enum Infraction: String {
    case foul = "foul"
    case tech = "tech"
    case both = "foul and tech"
}

class Game {
    
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
        
        if playerOne.gamesWonInSeries == winsNeeded || playerTwo.gamesWonInSeries == winsNeeded {
            decision = true
        }
        
        return decision
    }
    var wonSeries: String {
        var winnerName = ""
        
        if playerOne.gamesWonInSeries == winsNeeded {
            winnerName = playerOne.name
        }
        else if playerTwo.gamesWonInSeries == winsNeeded {
            winnerName = playerTwo.name
        }
        
        return winnerName
    }
    
    enum Stat: Int {
        case point = 1
        case foul
        case tech
    }
    
    init(playerOne: Player, playerTwo: Player) {
        self.playerOne = playerOne
        self.playerTwo = playerTwo
    }
    
    func increaseStats(player: Player, sectionNumber: Int) {
        // sectionNumber is the section in the storyboard that was tapped by user
        // section 1 is for points, section 2 is for fouls, section 3 is for techs
        if let statType = Stat(rawValue: sectionNumber) {
            switch statType {
            case .point: player.points += 1
            case .foul: player.fouls += 1
            case .tech: player.techs += 1
            }
        }
    }
    
    func decreaseStats(player: Player, sectionNumber: Int) {
        // sectionNumber is the section in the storyboard that was tapped by user
        // section 1 is for points, section 2 is for fouls, section 3 is for techs
        if let statType = Stat(rawValue: sectionNumber) {
            switch statType {
            case .point: player.points -= 1
            case .foul: player.fouls -= 1
            case .tech: player.techs -= 1
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
                playerOne.gamesWonInSeries += 1
                playerTwo.gamesLostInSeries += 1
            }
            else {
                playerTwo.gamesWonInSeries += 1
                playerOne.gamesLostInSeries += 1
            }
        }
        else if playerOne.isOverGameLimit {
            playerTwo.gamesWonInSeries += 1
            playerOne.gamesLostInSeries += 1
        }
        else if playerTwo.isOverGameLimit {
            playerOne.gamesWonInSeries += 1
            playerTwo.gamesLostInSeries += 1
        }
        else if playerOne.points > playerTwo.points {
            playerOne.gamesWonInSeries += 1
            playerTwo.gamesLostInSeries += 1
        }
        else if playerOne.points < playerTwo.points {
            playerTwo.gamesWonInSeries += 1
            playerOne.gamesLostInSeries += 1
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
    
    func printPlayer(_ player: Player) {
        print("Player : \(player.name)")
        print("   Points: \(player.points)")
        print("   Fouls: \(player.fouls)")
        print("   Techs: \(player.techs)")
        print("   Is Over Game Limit: \(player.isOverGameLimit)")
        print("   Games Won In Series: \(player.gamesWonInSeries)")
        print("   Games Lost In Series: \(player.gamesLostInSeries)")
        print("   Total Points: \(player.totalPoints)")
        print("   Total Fouls: \(player.totalFouls)")
        print("   Total Techs: \(player.totalTechs)")
    }
    
}
