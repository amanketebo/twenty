//
//  HowToView.swift
//  Twenty
//
//  Created by Amanuel Ketebo on 7/3/17.
//  Copyright © 2017 Amanuel Ketebo. All rights reserved.
//

import UIKit

class HowToView: UIView {
    
    var timer: Timer?
    var currentTime: Int {
        get {
            // firstTimeTimerLabel!.text since if the information view is being displayed
            //      the firstTimeTimerLabel! is not nil
            // timerLabel.text! since there will always be a number in the text label
            var timerText = timerLabel.text!
            var time = ""
            
            // Remove the "." so currentTime can be read as an Int
            for character in timerText.characters {
                if character != "." {
                    time.append(String(character))
                }
            }
            
            return Int(time)!
        }
        set {
            var number = String(newValue)
            
            if newValue < 10 {
                number.insert("0", at: number.startIndex)
            }
            number.insert(".", at: number.index(before: number.endIndex))
            
            timerLabel.text = number
        }
    }
    @IBOutlet weak var statLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var statsLabelMessage: UILabel!
    @IBOutlet weak var timerLabelMessage: UILabel!
    @IBOutlet weak var okGotIt: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = UIColor.clear
    }
    
    func configureView() {
        statsLabelMessage.text = "Swipe up/down \n to change the stats"
        timerLabelMessage.text = "Tap or swipe left/right \n to change game clock"
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(swippedStat(_:)))
        swipeUp.direction = .up
        statLabel.addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(swippedStat(_:)))
        swipeDown.direction = .down
        
        statLabel.addGestureRecognizer(swipeDown)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swippedTimerLabel(_:)))
        swipeLeft.direction = .left
        
        timerLabel.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(swippedTimerLabel(_:)))
        swipeRight.direction = .right
        
        timerLabel.addGestureRecognizer(swipeRight)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tappedTimer(_:)))
        
        timerLabel.addGestureRecognizer(tap)
        
        let tapOkGotIt = UITapGestureRecognizer(target: self, action: #selector(tappedOkGotIt(_:)))
        
        okGotIt.addGestureRecognizer(tapOkGotIt)
    }
    
    @objc private func swippedStat(_ sender: UISwipeGestureRecognizer) {
        if let statsLabel = sender.view as? UILabel {
            // Check the direction of the swipe to increase/decrease the stat
            let swipeDirection = sender.direction
            // Tag on the label indicates the player and what type of stat was swiped
            switch swipeDirection {
            case UISwipeGestureRecognizerDirection.up:
                let newStat = Int(statsLabel.text!)! + 1
                
                statsLabel.text = String(newStat)
            case UISwipeGestureRecognizerDirection.down:
                let newStat = Int(statsLabel.text!)! - 1
                guard newStat >= 0 else { return }
                
                statsLabel.text = String(newStat)
            default: break
            }
        }
    }
    
    func swippedTimerLabel(_ sender: UISwipeGestureRecognizer) {
        // Check the direction of the swipe to increase/decrease the time
        let swipeDirection = sender.direction
        
        switch swipeDirection {
        case UISwipeGestureRecognizerDirection.left:
            let newTime = currentTime - 10
            
            if newTime < 0 {
                currentTime = 0
                return
            }
            
            currentTime = newTime
        case UISwipeGestureRecognizerDirection.right:
            let newTime = currentTime + 10
            
            if newTime >= Game.regularTimeLimit {
                currentTime = Game.regularTimeLimit
                return
            }
            
            currentTime = newTime
        default: break
        }
    }
    
    @objc private func tappedTimer(_ sender: UITapGestureRecognizer) {
        if timer == nil {
            startTimer()
        }
        else {
            stopTimer()
        }
    }
    
    private func startTimer() {
        guard timer == nil else { return }
        
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(tickTimer(_:)), userInfo: nil, repeats: true)
        timerLabel.backgroundColor = .fadedBrightRed
    }
    
    @objc private func tickTimer(_ timer: Timer) {
        // If the timer is less than zero that means time has run out
        guard currentTime > 0 else {
            stopTimer()
            return
        }
        
        currentTime = currentTime - 1
    }
    
    private func stopTimer() {
        guard timer != nil else { return }
        
        timerLabel.backgroundColor = .fadedBrightGreen
        timer?.invalidate()
        timer = nil
    }
    
    @objc private func tappedOkGotIt(_ sender: UITapGestureRecognizer) {
        self.removeFromSuperview()
    }
    
}

