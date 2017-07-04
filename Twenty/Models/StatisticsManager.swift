//
//  StatisticsSaver.swift
//  Twenty
//
//  Created by Amanuel Ketebo on 7/2/17.
//  Copyright © 2017 Amanuel Ketebo. All rights reserved.
//

import Foundation
import RealmSwift

class StatisticsManager {
    
    var realm: Realm?
    static let shared = StatisticsManager()
    
    init() {
        
        if let realm = try? Realm() {
            self.realm = realm
        } else {
            realm = nil
        }
        
    }
    
    func saveStats(for player: Player) {
        if let realm = realm {
            do {
                let playersName = player.name
                let predicate = NSPredicate(format: "name = %a", playersName)
                let playersPreviouslySavedStats = realm.objects(Player.self).filter(predicate)
                if playersPreviouslySavedStats.count != 0 {
                    let savedPlayerStats = playersPreviouslySavedStats.first
                    savedPlayerStats?.totalPoints += player.totalPoints
                    savedPlayerStats?.totalFouls += player.totalFouls
                    savedPlayerStats?.totalTechs += player.totalTechs
                    
                } else {
                    try realm.write {
                        realm.add(player)
                    }
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func saveStats(for players: [Player]) {
        if let realm = realm  {
            do {
                for player in players {
                    try realm.write {
                        realm.add(player)
                    }
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        
        
    }
    
    func fetchStats() {
        if let realm = realm {
            let players = realm.objects(Player.self)
            print(players.count)
        }
    }
    
}
