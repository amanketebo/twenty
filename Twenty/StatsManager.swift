//
//  StatsManager.swift
//  Twenty
//
//  Created by Amanuel Ketebo on 3/13/17.
//  Copyright © 2017 Amanuel Ketebo. All rights reserved.
//

import Foundation

class StatsManager {
    
    let defaults = UserDefaults.standard
    var playerOneStats = [String:[String:Double]]()
    var playerTwoStats = [String:[String:Double]]()
    
    init() {
        
    }
    
    init(_ seriesStats: SeriesStats) {
        // Player one setup
        playerOneStats[seriesStats.playerOne.name] = [
            "total points": Double(seriesStats.playerOne.totalPoints),
            "total fouls": Double(seriesStats.playerOne.totalFouls),
            "total techs": Double(seriesStats.playerOne.totalTechs),
            "games won": Double(seriesStats.playerOne.gamesWon),
            "games lost": Double(seriesStats.playerOne.gamesLost)
        ]
        // Player two setup
        playerTwoStats[seriesStats.playerTwo.name] = [
            "total points": Double(seriesStats.playerTwo.totalPoints),
            "total fouls": Double(seriesStats.playerTwo.totalFouls),
            "total techs": Double(seriesStats.playerTwo.totalTechs),
            "games won": Double(seriesStats.playerTwo.gamesWon),
            "games lost": Double(seriesStats.playerTwo.gamesLost)
        ]
    }
    
    func saveStats() {
        if let allStats = defaults.object(forKey: "allStats") as? [[String:[String:Double]]] {
            // Create mutable version of "allStats"
            var mutableStats = allStats
            saveStatsForPlayer(playerOneStats, statsTable: &mutableStats)
            saveStatsForPlayer(playerTwoStats, statsTable: &mutableStats)
            defaults.set(mutableStats, forKey: "allStats")
        }
        else {
            // Since there aren't any save stats just create an array of player stats and place in defaults
            var arrayOfPlayers = [[String:[String:Double]]]()
            arrayOfPlayers.append(playerOneStats)
            arrayOfPlayers.append(playerTwoStats)
            defaults.set(arrayOfPlayers, forKey: "allStats")
            
        }
    }
    
    func saveStatsForPlayer (_ player: [String:[String:Double]], statsTable: inout [[String:[String:Double]]]) {
        var newPlayer = true
        var foundPlayerIndex = 0
        
        // Loop through player stats and see if player already has stats stored
        for (index, playerStats) in statsTable.enumerated() {
            if playerStats.keys.first! == player.keys.first! {
                newPlayer = false
                foundPlayerIndex = index
            }
        }
        
        if newPlayer {
            // Sinces it a new player just simply append it to the stats array
            statsTable.append(player)
        }
        else {
            // So many "!"'s, LIVING DANGEROUSLY!
            // Limitation of UserDefaults?
            // Get statDictionary from array of stats
            var certainPlayerDict = statsTable[foundPlayerIndex]
            var totalPoints = certainPlayerDict[certainPlayerDict.keys.first!]?["total points"]
            var totalFouls = certainPlayerDict[certainPlayerDict.keys.first!]?["total fouls"]
            var totalTechs = certainPlayerDict[certainPlayerDict.keys.first!]?["total techs"]
            var gamesWon = certainPlayerDict[certainPlayerDict.keys.first!]?["games won"]
            var gamesLost = certainPlayerDict[certainPlayerDict.keys.first!]?["games lost"]
            
            // Add stats to the running total
            totalPoints = totalPoints! + (player[player.keys.first!]?["total points"]!)!
            totalFouls = totalFouls! + (player[player.keys.first!]?["total fouls"]!)!
            totalTechs = totalTechs! + (player[player.keys.first!]?["total techs"]!)!
            gamesWon = gamesWon! + (player[player.keys.first!]?["games won"]!)!
            gamesLost = gamesLost! + (player[player.keys.first!]?["games lost"]!)!
            
            certainPlayerDict[certainPlayerDict.keys.first!]?["total points"] = totalPoints
            certainPlayerDict[certainPlayerDict.keys.first!]?["total fouls"] = totalFouls
            certainPlayerDict[certainPlayerDict.keys.first!]?["total techs"] = totalTechs
            certainPlayerDict[certainPlayerDict.keys.first!]?["games won"] = gamesWon
            certainPlayerDict[certainPlayerDict.keys.first!]?["games lost"] = gamesLost
            
            statsTable[foundPlayerIndex] = certainPlayerDict
        }
    }
    
    func getStats() -> [AverageStats] {
        // Create an average stats array so StatisticsViewController doesn't need to do the calculations
        var averageStats = [AverageStats]()
        
        if let allStats = defaults.object(forKey: "allStats") as? [[String:[String:Double]]] {
            for playerStat in allStats {
                let averageStat = AverageStats()
                let gamesPlayed = (playerStat[playerStat.keys.first!]?["games won"])! + (playerStat[playerStat.keys.first!]?["games lost"])!
                averageStat.name = playerStat.keys.first!
                // Round points, fouls, and techs to the tenths place
                averageStat.points = ((playerStat[playerStat.keys.first!]?["total points"])! / gamesPlayed).roundTo(places: 1)
                averageStat.fouls = ((playerStat[playerStat.keys.first!]?["total fouls"])! / gamesPlayed).roundTo(places: 1)
                averageStat.techs = ((playerStat[playerStat.keys.first!]?["total techs"])! / gamesPlayed).roundTo(places: 1)
                averageStat.gamesWon = Int((playerStat[playerStat.keys.first!]?["games won"])!)
                averageStat.gamesLost = Int((playerStat[playerStat.keys.first!]?["games lost"])!)
                averageStats.append(averageStat)
            }
        }
        else {
            averageStats = [AverageStats]()
        }
        
        return averageStats
    }
    
}
