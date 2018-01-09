//
//  Player.swift
//  Twenty
//
//  Created by Amanuel Ketebo on 2/22/17.
//  Copyright © 2017 Amanuel Ketebo. All rights reserved.
//

import Foundation

class Player {
    var name: String = ""
    var points: Int = 0
    var fouls: Int = 0
    var techs: Int = 0
    var totalPoints = 0
    var totalFouls = 0
    var totalTechs = 0
    var gamesWon: Int = 0
    var gamesLost: Int = 0
    var isOverGameLimit = false
}
