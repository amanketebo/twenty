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
            if let playerName = certainPlayerDict.keys.first {
                
                var totalPoints = certainPlayerDict[playerName]?["total points"]
                var totalFouls = certainPlayerDict[playerName]?["total fouls"]
                var totalTechs = certainPlayerDict[playerName]?["total techs"]
                var gamesWon = certainPlayerDict[playerName]?["games won"]
                var gamesLost = certainPlayerDict[playerName]?["games lost"]
                
                guard totalPoints != nil && totalFouls != nil && totalTechs != nil && gamesWon != nil && gamesLost != nil else {
                    return
                }
                
                // Add stats to the running total
                totalPoints = totalPoints! + (player[player.keys.first!]?["total points"]!)!
                totalFouls = totalFouls! + (player[player.keys.first!]?["total fouls"]!)!
                totalTechs = totalTechs! + (player[player.keys.first!]?["total techs"]!)!
                gamesWon = gamesWon! + (player[player.keys.first!]?["games won"]!)!
                gamesLost = gamesLost! + (player[player.keys.first!]?["games lost"]!)!
                
                certainPlayerDict[playerName]?["total points"] = totalPoints
                certainPlayerDict[playerName]?["total fouls"] = totalFouls
                certainPlayerDict[playerName]?["total techs"] = totalTechs
                certainPlayerDict[playerName]?["games won"] = gamesWon
                certainPlayerDict[playerName]?["games lost"] = gamesLost
                
                statsTable[foundPlayerIndex] = certainPlayerDict
                print("We are happy and we know it!")
            }
            
        }
    }
    
    func getStats() -> [AverageStats] {
        // Create an average stats array so StatisticsViewController doesn't need to do the calculations
        var averageStats = [AverageStats]()
        
        if let allStats = defaults.object(forKey: "allStats") as? [[String:[String:Double]]] {
            for playerStat in allStats {
                let averageStat = AverageStats()
                if let playerName = playerStat.keys.first {
                    let totalPoints = playerStat[playerName]?["total points"]
                    let totalFouls = playerStat[playerName]?["total fouls"]
                    let totalTechs = playerStat[playerName]?["total techs"]
                    let gamesWon = playerStat[playerName]?["games won"]
                    let gamesLost = playerStat[playerName]?["games lost"]
                    
                    guard totalPoints != nil && totalFouls != nil && totalTechs != nil && gamesWon != nil && gamesLost != nil else {
                        return []
                    }
                    
                    let gamesPlayed = (playerStat[playerName]?["games won"])! + (playerStat[playerName]?["games lost"])!
                    averageStat.name = playerName
                    
                    // Round points, fouls, and techs to the tenths place
                    averageStat.points = ((totalPoints)! / gamesPlayed).roundTo(places: 1)
                    averageStat.fouls = ((totalFouls)! / gamesPlayed).roundTo(places: 1)
                    averageStat.techs = ((totalTechs)! / gamesPlayed).roundTo(places: 1)
                    averageStat.gamesWon = Int((gamesWon)!)
                    averageStat.gamesLost = Int((gamesLost)!)
                    averageStats.append(averageStat)
                }
                else {
                    return []
                    
                }
            }
        }
        else {
            averageStats = [AverageStats]()
        }
        
        return averageStats
    }
    
}
