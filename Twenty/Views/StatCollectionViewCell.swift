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

    func configureCell(with player: Player) {
        name.text = player.name
        averagePoints.text = String(player.averagePoints)
        averageFouls.text = String(player.averageFouls)
        averageTechs.text = String(player.averageTechs)
        record.text = "\(String(player.totalGamesWon))-\(String(player.totalGamesLost))"
    }
}
