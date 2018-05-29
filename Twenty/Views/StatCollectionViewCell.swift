//
//  StatCollectionViewCell.swift
//  Twenty
//
//  Created by Amanuel Ketebo on 3/15/17.
//  Copyright © 2017 Amanuel Ketebo. All rights reserved.
//

import UIKit

class StatCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var averagePoints: UILabel!
    @IBOutlet weak var averageFouls: UILabel!
    @IBOutlet weak var averageTechs: UILabel!
    @IBOutlet weak var record: UILabel!

    static let identifier = "statCell"

    func configureCell(with playerStats: PlayerStats) {
        name.text = playerStats.name
        averagePoints.text = String(playerStats.averagePoints)
        averageFouls.text = String(playerStats.averageFouls)
        averageTechs.text = String(playerStats.averageTechs)
        record.text = "\(String(playerStats.totalGamesWon))-\(String(playerStats.totalGamesLost))"
    }
}
