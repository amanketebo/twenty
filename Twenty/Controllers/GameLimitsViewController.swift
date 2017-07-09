//
//  GameLimitsViewController.swift
//  Twenty
//
//  Created by Amanuel Ketebo on 1/19/17.
//  Copyright © 2017 Amanuel Ketebo. All rights reserved.
//

import UIKit

class GameLimitsViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var gameLimitsHolder: UIView! {
        didSet {
            gameLimitsHolder.layer.cornerRadius = 10
        }
    }
    @IBOutlet weak var currentFoul: RoundedButton!
    @IBOutlet weak var currentTech: RoundedButton!
    @IBOutlet weak var currentSeries: RoundedButton! {
        didSet {
            winsNeeded = Int(currentSeries.currentTitle!)!/2 + 1
        }
    }
    
    // MARK: - Properties
    
    private var winsNeeded = 0
    
    // MARK: - Action functions
    
    @IBAction func touchedLimit(_ sender: RoundedButton) {
        // The buttons tag corresponds to the section its in
        // Fouls = Section 1, Techs = Section 2, Series = Section 3
        let section = sender.tag
        switch section {
        case 1:
            if sender != currentFoul {
                sender.backgroundColor = UIColor.lightRed
                currentFoul.backgroundColor = UIColor.lightBlack
                currentFoul = sender
            }
        case 2:
            if sender != currentTech {
                sender.backgroundColor = UIColor.lightGreen
                currentTech.backgroundColor = UIColor.lightBlack
                currentTech = sender
            }
        case 3:
            if sender != currentSeries {
                sender.backgroundColor = UIColor.lightPurple
                currentSeries.backgroundColor = UIColor.lightBlack
                currentSeries = sender
            }
        default: break
        }
    }
    
    @IBAction func touchedStartGame() {
        // Check to make sure the game can be started first by making sure both player names have been entered
        if let pageManager = self.parent as? PageManagerViewController {
            if let playerNameVc = pageManager.pageVcs.first as? PlayerNamesViewController {
                
                // Make sure all players have entered their names or else show an alert
                if playerNameVc.playerOneTextField.text == "" || playerNameVc.playerTwoTextField.text == "" {
                    let alert = UIAlertController(title: "Not Enough Players!", message: "Please enter both player names." , preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                }
                // Make sure the player names are not the same or else show an alert
                else if playerNameVc.playerOneTextField.text == playerNameVc.playerTwoTextField.text {
                    let alert = UIAlertController(title: "Same Names!", message: "Please make sure the players have different names." , preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                }
                    // Since both names were entered the page view controller can segue
                    // Set up the model then segue from pagevc
                else {
                    if let gameLimitsVc = pageManager.pageVcs.last as? GameLimitsViewController {
                        let playerOne = Player()
                        let playerTwo = Player()
                        let setupGame = Game(playerOne: playerOne, playerTwo: playerTwo)
                        // ! since text fields definetly have names in them and buttons have numbers
                        playerOne.name = playerNameVc.playerOneTextField.text!
                        playerTwo.name = playerNameVc.playerTwoTextField.text!
                        setupGame.foulLimit = Int(gameLimitsVc.currentFoul.currentTitle!)!
                        setupGame.techLimit = Int(gameLimitsVc.currentTech.currentTitle!)!
                        setupGame.seriesLimit = Int(gameLimitsVc.currentSeries.currentTitle!)!
                        setupGame.playerOne = playerOne
                        setupGame.playerTwo = playerTwo
                        setupGame.winsNeeded = winsNeeded
                        pageManager.segueToGameVc(game: setupGame)
                    }
                }
            }
        }
    }
    
}
