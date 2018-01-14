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
    var playerOneStats = [String: [String: Double]]()
    var playerTwoStats = [String: [String: Double]]()

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

    init() { }

    func saveStats() {
        // Definitely want to use CoreData instead later down the line

        if let allStats = defaults.object(forKey: "allStats") as? [[String:[String:Double]]] {
            // Create mutable version of "allStats"
            var mutableStats = allStats
            // Save each players stats individually
            saveStatsForPlayer(playerOneStats, savedStats: &mutableStats)
            saveStatsForPlayer(playerTwoStats, savedStats: &mutableStats)
            defaults.set(mutableStats, forKey: "allStats")
        }
        else {
            // Since there aren't any save stats just create an array of player stats and place in defaults
            var arrayOfPlayers = [[String: [String: Double]]]()
            arrayOfPlayers.append(playerOneStats)
            arrayOfPlayers.append(playerTwoStats)
            defaults.set(arrayOfPlayers, forKey: "allStats")
        }
    }

    func saveStatsForPlayer (_ newPlayerStats: [String:[String:Double]], savedStats: inout [[String:[String:Double]]]) {
        var newPlayer = true
        var foundPlayerIndex = 0
        // Loop through stats and see if player already has stats stored
        for (index, playerStats) in savedStats.enumerated() {
            if playerStats.keys.first! == newPlayerStats.keys.first! {
                newPlayer = false
                foundPlayerIndex = index
            }
        }

        if newPlayer {
            // Sinces it a new player just simply append it to the stats array
            savedStats.append(newPlayerStats)
        }
        else {
            // Add newPlayerStats to the saved stats
            var savedPlayerStats = savedStats[foundPlayerIndex]
            if let playerName = savedPlayerStats.keys.first {

                var savedTotalPoints = savedPlayerStats[playerName]?["total points"]
                var savedTotalFouls = savedPlayerStats[playerName]?["total fouls"]
                var savedTotalTechs = savedPlayerStats[playerName]?["total techs"]
                var savedGamesWon = savedPlayerStats[playerName]?["games won"]
                var savedGamesLost = savedPlayerStats[playerName]?["games lost"]
                let newTotalPoints = newPlayerStats[playerName]?["total points"]
                let newTotalFouls = newPlayerStats[playerName]?["total fouls"]
                let newTotalTechs = newPlayerStats[playerName]?["total techs"]
                let newGamesWon = newPlayerStats[playerName]?["games won"]
                let newGamesLost = newPlayerStats[playerName]?["games lost"]

                guard savedTotalPoints != nil && savedTotalFouls != nil && savedTotalTechs != nil && savedGamesWon != nil && savedGamesLost != nil && newTotalPoints != nil && newTotalFouls != nil && newTotalTechs != nil && newGamesWon != nil && newGamesLost != nil else {
                    return
                }

                // Add stats to the running total
                savedTotalPoints = savedTotalPoints! + newTotalPoints!
                savedTotalFouls = savedTotalFouls! + newTotalFouls!
                savedTotalTechs = savedTotalTechs! + newTotalTechs!
                savedGamesWon = savedGamesWon! + newGamesWon!
                savedGamesLost = savedGamesLost! + newGamesLost!

                savedPlayerStats[playerName]?["total points"] = savedTotalPoints
                savedPlayerStats[playerName]?["total fouls"] = savedTotalFouls
                savedPlayerStats[playerName]?["total techs"] = savedTotalTechs
                savedPlayerStats[playerName]?["games won"] = savedGamesWon
                savedPlayerStats[playerName]?["games lost"] = savedGamesLost

                savedStats[foundPlayerIndex] = savedPlayerStats
            }

        }
    }

    func getStats() -> [AverageStats] {
        // TODO:
        // - Figure out a way to use less "!" w/o having to use the pyramid of doom

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
