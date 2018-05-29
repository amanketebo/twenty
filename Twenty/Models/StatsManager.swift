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

    func fetchAllPlayers() -> [Player] {
        let request: NSFetchRequest<Player> = Player.fetchRequest()

        if let foundPlayers = try? context.fetch(request) {
            return foundPlayers
        } else {
            return []
        }
    }

    func deleteAllPlayers() {
        let request: NSFetchRequest<Player> = Player.fetchRequest()

        if let foundPlayers = try? context.fetch(request) {
            for player in foundPlayers {
                context.delete(player)
            }
        }

        saveContext()
    }

    func fetchPlayer(matching name: String) -> Player {
        let request: NSFetchRequest<Player> = Player.fetchRequest()
        let predicate = NSPredicate(format: "name = %@", name)

        request.predicate = predicate

        if let foundMatchingPlayers = try? context.fetch(request) {
            if foundMatchingPlayers.count > 0 {
                return foundMatchingPlayers.first!
            } else {
                return Player(context: context)
            }
        } else {
            return Player(context: context)
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
