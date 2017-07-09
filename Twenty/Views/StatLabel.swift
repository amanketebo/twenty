//
//  StatLabel.swift
//  Twenty
//
//  Created by Amanuel Ketebo on 7/8/17.
//  Copyright © 2017 Amanuel Ketebo. All rights reserved.
//

import UIKit

protocol StatLabelDelegate
{
    func updatedPlayerStat(playerNumber: Int?, typeOfStat: Stat?, stat: Int)
}

class StatLabel: UILabel
{
    // Related to the label's tags in storyboard
    var playerNumber: Int?
    var statSection: Stat?
    var delegate: StatLabelDelegate?
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        setupProperties()
        addGestureRecognizers()
    }
    
    private func setupProperties()
    {
        let cellTag = String(tag).characters
        
        playerNumber = Int(String(describing: cellTag.first))
        statSection = Stat(rawValue: Int(String(describing: cellTag.last)) ?? 0)
    }
    
    @objc private func swippedStat(_ sender: UISwipeGestureRecognizer)
    {
        let direction = sender.direction
        switch direction
        {
        case UISwipeGestureRecognizerDirection.up:
            addStat()
        case UISwipeGestureRecognizerDirection.down:
            subtractStat()
        default: break
        }
        
        delegate?.updatedPlayerStat(playerNumber: playerNumber, typeOfStat: statSection, stat: Int(text!)!)
    }
    
    func addStat()
    {
        let currentStat = Int(text!)!
        let updatedStat = currentStat + 1
        
        text = String(updatedStat)
    }
    
    func subtractStat()
    {
        let currentStat = Int(text!)!
        
        if currentStat > 0
        {
            let updatedStat = currentStat - 1
            text = String(updatedStat)
        }
    }
    
    private func addGestureRecognizers()
    {
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(swippedStat(_:)))
        swipeUp.direction = .up
        self.addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(swippedStat(_:)))
        swipeDown.direction = .down
        self.addGestureRecognizer(swipeDown)
    }
}
