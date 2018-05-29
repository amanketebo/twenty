//
//  StatsManager.swift
//  Twenty
//
//  Created by Amanuel Ketebo on 3/13/17.
//  Copyright © 2017 Amanuel Ketebo. All rights reserved.
//

import Foundation
import CoreData

class StatsManager {
    static let shared = StatsManager()

    lazy var context = persistentContainer.viewContext

    init() {}

    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Twenty")

        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })

        return container
    }()

    func savePlayerStats(for players: Player...) {
        for player in players {
            var playerStats: PlayerStats!

            if let foundPlayerStats = fetchPlayerStats(matching: player.name) {
                playerStats = foundPlayerStats
            } else {
                let newPlayerStats = PlayerStats(context: context)
                newPlayerStats.name = player.name
                playerStats = newPlayerStats
            }

            playerStats.totalPoints += Int16(player.seriesTotalPoints)
            playerStats.totalFouls += Int16(player.seriesTotalFouls)
            playerStats.totalTechs += Int16(player.seriesTotalTechs)
            playerStats.totalGamesWon += Int16(player.seriesGamesWon)
            playerStats.totalGamesLost += Int16(player.seriesGamesLost)
        }

        saveContext()
    }

    func fetchAllPlayersStats() -> [PlayerStats] {
        let request: NSFetchRequest<PlayerStats> = PlayerStats.fetchRequest()

        if let foundPlayersStats = try? context.fetch(request) {
            return foundPlayersStats
        } else {
            return []
        }
    }

    func deleteAllPlayers() {
        let request: NSFetchRequest<PlayerStats> = PlayerStats.fetchRequest()

        if let foundPlayersStats = try? context.fetch(request) {
            for playerStats in foundPlayersStats {
                context.delete(playerStats)
            }
        }

        saveContext()
    }

    func fetchPlayerStats(matching name: String) -> PlayerStats? {
        let request: NSFetchRequest<PlayerStats> = PlayerStats.fetchRequest()
        let predicate = NSPredicate(format: "name = %@", name)

        request.predicate = predicate

        if let foundMatchingPlayers = try? context.fetch(request) {
            if foundMatchingPlayers.count > 0 {
                return foundMatchingPlayers.first!
            } else {
                return nil
            }
        } else {
            return nil
        }
    }

    // MARK: - Core Data Saving support
    func saveContext() {
        let context = persistentContainer.viewContext

        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
