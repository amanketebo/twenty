//
//  AverageStats.swift
//  Twenty
//
//  Created by Amanuel Ketebo on 3/15/17.
//  Copyright © 2017 Amanuel Ketebo. All rights reserved.
//

import Foundation

class AverageStats {
    var name = ""
    var points = 0.0
    var fouls = 0.0
    var techs = 0.0
    var gamesWon = 0
    var gamesLost = 0
    var winPercentage: Double {
        return (Double(gamesWon)/Double(gamesLost)).roundTo(places: 2)
    }
}
