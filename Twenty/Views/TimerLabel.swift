//
//  TimerLabel.swift
//  Twenty
//
//  Created by Amanuel Ketebo on 7/8/17.
//  Copyright © 2017 Amanuel Ketebo. All rights reserved.
//

import UIKit

protocol TimerLabelDelegate
{
    func currentTimeLimit() -> Int
}

class TimerLabel: UILabel
{
    private var timer: Timer?
    private var currentTime: Int
    {
        get
        {
            // Remove the "."
            var time = text!
            time.removeSubrange((time.range(of: ".")!))
            
            return Int(time)!
        }
        set
        {
            // Add a 0 if below 10 and add the "." back
            var newTime = String(newValue)
            if newValue < 10 {
                newTime.insert("0", at: newTime.startIndex)
            }
            
            newTime.insert(".", at: newTime.index(before: newTime.endIndex))
            text = newTime
        }
    }
    var delegate: TimerLabelDelegate?
    
    override func awakeFromNib()
    {
        addGestureRecognizers()
    }
    
    @objc private func tappedTimer()
    {
        if (timer == nil)
        {
            createTimer()
            startTimer()
        }
        else
        {
            stopTimer()
        }
    }
    
    @objc private func swippedTimer(_ sender: UISwipeGestureRecognizer)
    {
        let direction = sender.direction
        switch direction
        {
        case UISwipeGestureRecognizerDirection.right: addSecond()
        case UISwipeGestureRecognizerDirection.left: subtractSecond()
        default: break
        }
    }
    
    func createTimer()
    {
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(tickTimer), userInfo: nil, repeats: true)
    }
    
    func startTimer()
    {
        guard timer != nil else { return }
        
        backgroundColor = .fadedBrightRed
    }
    
    func tickTimer()
    {
        guard currentTime > 0 else
        {
            stopTimer()
            return
        }
        currentTime = currentTime - 1
    }
    
    func stopTimer()
    {
        guard timer != nil else { return }
        
        backgroundColor = .fadedBrightGreen
        timer?.invalidate()
        timer = nil
    }
    
    func addSecond()
    {
        let newTime = currentTime + 10
        
        if let timeLimit = delegate?.currentTimeLimit()
        {
            currentTime = (newTime > timeLimit) ? timeLimit : newTime
        }
        else
        {
            currentTime = newTime
        }
    }
    
    func subtractSecond()
    {
        currentTime = currentTime >= 1 ? currentTime - 10 : 0
    }
    
    func addGestureRecognizers()
    {
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tappedTimer)))
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swippedTimer(_:)))
        swipeLeft.direction = .left
        self.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(swippedTimer(_:)))
        self.addGestureRecognizer(swipeRight)
    }
}
