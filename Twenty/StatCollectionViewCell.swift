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
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layer.borderColor = UIColor(red: 0.29, green: 0.29, blue: 0.29, alpha: 1.0).cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 5
        backgroundColor = .lightBlack20
        clipsToBounds = true
    }
    
}
