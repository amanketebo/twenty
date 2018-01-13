//
//  StatLabel.swift
//  Twenty
//
//  Created by Amanuel Ketebo on 7/8/17.
//  Copyright © 2017 Amanuel Ketebo. All rights reserved.
//

import UIKit

@objc protocol StatLabelDelegate
{
    func updatedPlayerStat(playerNumber: Int, statType: Int, stat: Int)
}

class StatLabel: UILabel
{
    @IBOutlet var delegate: StatLabelDelegate?
    
    var playerNumber: Int?
    var statSection: Int?
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        setProperties()
        addGestureRecognizers()
    }
    
    private func setProperties()
    {
        let statLabelTag = String(tag)
        
        playerNumber = Int(String(describing: statLabelTag.first ?? "0"))
        statSection = Int(String(describing: statLabelTag.last ?? "0"))
    }
    
    private func addGestureRecognizers()
    {
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(swippedStat(_:)))
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(swippedStat(_:)))
        
        swipeUp.direction = .up
        swipeDown.direction = .down
        
        self.addGestureRecognizer(swipeUp)
        self.addGestureRecognizer(swipeDown)
    }
    
    @objc private func swippedStat(_ sender: UISwipeGestureRecognizer)
    {
        switch sender.direction
        {
        case UISwipeGestureRecognizerDirection.up: addStat()
        case UISwipeGestureRecognizerDirection.down: subtractStat()
        default: break
        }
        
        if let playerNumber = playerNumber,
            let statSection = statSection,
            let statLabelText = text,
            let stat = Int(statLabelText) {
            delegate?.updatedPlayerStat(playerNumber: playerNumber, statType: statSection, stat: stat)
        }
    }
    
    func addStat()
    {
        guard let statLabelText = text else { return }
        guard let currentStat = Int(statLabelText) else { return }
        
        text = String(currentStat + 1)
    }
    
    func subtractStat()
    {
        guard let statLabelText = text else { return }
        guard let currentStat = Int(statLabelText) else { return }
        
        if currentStat > 0
        {
            text = String(currentStat - 1)
        }
    }
}
