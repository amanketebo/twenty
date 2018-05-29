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

public class Player {
    // Variables for current series
    var name = ""
    var currentGamePoints: Int = 0
    var currentGameFouls: Int = 0
    var currentGameTechs: Int = 0
    var seriesGamesWon = 0
    var seriesGamesLost = 0
    var seriesTotalPoints = 0
    var seriesTotalFouls = 0
    var seriesTotalTechs = 0
    var isOverGameLimit = false
}
