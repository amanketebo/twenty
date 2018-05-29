//
//  Player+CoreDataClass.swift
//  Twenty
//
//  Created by Amanuel Ketebo on 5/26/18.
//  Copyright © 2018 Amanuel Ketebo. All rights reserved.
//
//

import Foundation
import CoreData

public class Player: NSManagedObject {
    var points: Int = 0
    var fouls: Int = 0
    var techs: Int = 0
    var seriesGamesWon = 0
    var seriesGamesLost = 0
    var isOverGameLimit = false

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
}

extension Player {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Player> {
        return NSFetchRequest<Player>(entityName: "Player")
    }

    @NSManaged public var name: String
    @NSManaged public var totalPoints: Int16
    @NSManaged public var totalFouls: Int16
    @NSManaged public var totalTechs: Int16
    @NSManaged public var totalGamesWon: Int16
    @NSManaged public var totalGamesLost: Int16

    func print() {
        let multiLineString = """
                              Total Points: \(self.totalPoints)
                              Total Fouls: \(self.totalFouls)
                              Total Techs: \(self.totalTechs)
                              Total Games Won: \(self.totalGamesWon)
                              Total Games Lost: \(self.totalGamesLost)
                              """

        Swift.print(multiLineString)
    }
}
