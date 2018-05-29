//
//  GameLimitsViewController.swift
//  Twenty
//
//  Created by Amanuel Ketebo on 1/19/17.
//  Copyright © 2017 Amanuel Ketebo. All rights reserved.
//

import UIKit

class GameLimitsViewController: UIViewController {
    @IBOutlet weak var gameLimitsHolder: UIView!
    @IBOutlet weak var currentFoul: UIButton!
    @IBOutlet weak var currentTech: UIButton!
    @IBOutlet weak var currentSeries: UIButton! {
        didSet {
            guard let currentTitle = currentSeries.currentTitle else { return }
            guard let currentTitleNumber = Int(currentTitle) else { return }

            winsNeeded = currentTitleNumber/2 + 1
        }
    }

    private var winsNeeded = 0
    private var pageManager: PageManagerViewController? {
        return self.parent as? PageManagerViewController
    }
    private var playerNameVC: PlayerNamesViewController? {
        return pageManager?.pageVcs.first as? PlayerNamesViewController
    }
    private let statsManager = StatsManager.shared

    @IBAction func touchedLimit(_ sender: UIButton) {
        // The buttons tag corresponds to the section its in
        // Fouls = Section 1, Techs = Section 2, Series = Section 3
        let section = sender.tag
        switch section {
        case 1:
            if sender != currentFoul {
                sender.backgroundColor = .lightRed
                currentFoul.backgroundColor = .lightBlack
                currentFoul = sender
            }
        case 2:
            if sender != currentTech {
                sender.backgroundColor = .lightGreen
                currentTech.backgroundColor = .lightBlack
                currentTech = sender
            }
        case 3:
            if sender != currentSeries {
                sender.backgroundColor = .lightPurple
                currentSeries.backgroundColor = .lightBlack
                currentSeries = sender
            }
        default: break
        }
    }

    @IBAction func touchedStartGame() {
        guard let pageManager = pageManager else { return }
        guard let playerNameVC = playerNameVC else { return }

        if playerNameEmpty() {
            let alert = UIAlertController(title: "Not Enough Players!", message: "Please enter both player names." , preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)

            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
        else if playerHaveSameNames() {
            let alert = UIAlertController(title: "Same Names!", message: "Please make sure the players have different names." , preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)

            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
        else {
            let playerOne = Player()
            let playerTwo = Player()
            let game = Game(playerOne: playerOne, playerTwo: playerTwo)

            // ! since text fields definetly have names in them and buttons have numbers
            playerOne.name = playerNameVC.playerOneTextField.text ?? ""
            playerTwo.name = playerNameVC.playerTwoTextField.text ?? ""
            game.foulLimit = Int(currentFoul.currentTitle!)!
            game.techLimit = Int(currentTech.currentTitle!)!
            game.seriesLimit = Int(currentSeries.currentTitle!)!
            game.playerOne = playerOne
            game.playerTwo = playerTwo
            game.winsNeeded = winsNeeded
            pageManager.segueToGameVc(game: game)
        }
    }

    private func playerNameEmpty() -> Bool {
        guard let playerNameVC = playerNameVC else { return false }

        return playerNameVC.playerOneTextField.text == "" || playerNameVC.playerTwoTextField.text == ""
    }

    private func playerHaveSameNames() -> Bool {
        guard let playerNameVC = playerNameVC else { return false }

        let playerOneName = playerNameVC.playerOneTextField.text
        let playerTwoName = playerNameVC.playerTwoTextField.text

        return playerOneName?.trimmingCharacters(in: .whitespaces) == playerTwoName?.trimmingCharacters(in: .whitespaces)
    }
}
