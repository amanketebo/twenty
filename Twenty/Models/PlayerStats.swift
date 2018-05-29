//
//  PlayerStats+CoreDataClass.swift
//  Twenty
//
//  Created by Amanuel Ketebo on 5/29/18.
//  Copyright © 2018 Amanuel Ketebo. All rights reserved.
//
//

import Foundation
import CoreData


public class PlayerStats: NSManagedObject {
    @NSManaged public var name: String?
    @NSManaged public var totalPoints: Int16
    @NSManaged public var totalFouls: Int16
    @NSManaged public var totalTechs: Int16
    @NSManaged public var totalGamesLost: Int16
    @NSManaged public var totalGamesWon: Int16

    var averagePoints: Double {
        return Double(totalPoints / (totalGamesWon + totalGamesLost))
    }

    var averageFouls: Double {
        return Double(totalFouls / (totalGamesWon + totalGamesLost))
    }

    var averageTechs: Double {
        return Double(totalTechs / (totalGamesWon + totalGamesLost))
    }

    var winPercentage: Double {
        return Double(totalGamesWon / totalGamesLost)
    }

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PlayerStats> {
        return NSFetchRequest<PlayerStats>(entityName: "PlayerStats")
    }
}
