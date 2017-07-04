//
//  Player.swift
//  Twenty
//
//  Created by Amanuel Ketebo on 2/22/17.
//  Copyright © 2017 Amanuel Ketebo. All rights reserved.
//

import Foundation
import RealmSwift

class Player: Object {
    
    dynamic var name: String = ""
    dynamic var points: Int = 0
    dynamic var fouls: Int = 0
    dynamic var techs: Int = 0
    dynamic var totalPoints = 0
    dynamic var totalFouls = 0
    dynamic var totalTechs = 0
    dynamic var gamesWon: Int = 0
    dynamic var gamesLost: Int = 0
    dynamic var isOverGameLimit = false

    override static func ignoredProperties() -> [String] {
        return ["points", "fouls", "techs", "isOverGameLimit"]
    }
    
}
