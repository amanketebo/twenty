//
//  GameViewController.swift
//  Twenty
//
//  Created by Amanuel Ketebo on 2/19/17.
//  Copyright © 2017 Amanuel Ketebo. All rights reserved.
//

import UIKit

class GameViewController: UIViewController, StatLabelDelegate, TimerLabelDelegate
{
    @IBOutlet weak var playerOnePoints: StatLabel!
    @IBOutlet weak var playerOneFouls: StatLabel!
    @IBOutlet weak var playerOneTechs: StatLabel!
    @IBOutlet weak var playerTwoPoints: StatLabel!
    @IBOutlet weak var playerTwoFouls: StatLabel!
    @IBOutlet weak var playerTwoTechs: StatLabel!
    @IBOutlet weak var seriesLimitLabel: StatLabel!
    @IBOutlet weak var foulLimitLabel: StatLabel!
    @IBOutlet weak var techLimitLabel: StatLabel!
    @IBOutlet weak var playerOneGamesWon: StatLabel!
    @IBOutlet weak var playerTwoGamesWon: StatLabel!
    @IBOutlet weak var playerOneName: StatLabel!
    @IBOutlet weak var playerTwoName: StatLabel!
    @IBOutlet weak var timerLabel: TimerLabel!
        {
        didSet
        {
            timerLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 60, weight: UIFontWeightLight)
        }
    }
    
    let defaults = UserDefaults.standard
    var currentGame: Game!
    var playerOne: Player!
    var playerTwo: Player!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavBar()
        setupGameInformation()
        timerLabel.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        defaults.set(true, forKey: "firstTimeUsingApp")
        let firstTimeUsingApp = defaults.bool(forKey: "firstTimeUsingApp")
        
        if firstTimeUsingApp
        {
            presentHowToView()
            defaults.set(false, forKey: "firstTimeUsingApp")
        }
    }
    
    // MARK: - Setup methods

    func setupNavBar()
    {
        navigationItem.setHidesBackButton(true, animated: true)
        navigationItem.title = "Game \(currentGame.gameNumber)"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Exit",
            style: .plain,
            target: self,
            action: #selector(GameViewController.presentLosingStatsAlert(_:)
            ))
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Next Game",
            style: .plain,
            target: self,
            action: #selector(GameViewController.presentEndingGameAlert(_:)
            ))
        
        if let navVc = self.parent as? UINavigationController
        {
            navVc.viewControllers.remove(at: 1)
        }
    }
    
    func setupGameInformation()
    {
        playerOneName.text = currentGame.playerOne.name
        playerTwoName.text = currentGame.playerTwo.name
        seriesLimitLabel.text = "SERIES: \(currentGame.seriesLimit)"
        foulLimitLabel.text = "FOULS: \(currentGame.foulLimit)"
        techLimitLabel.text = "TECHS: \(currentGame.techLimit)"
        playerOneGamesWon.text = String(playerOne.gamesWon)
        playerTwoGamesWon.text = String(playerTwo.gamesWon)
    }
    
    func presentHowToView()
    {
        if let howToView = Bundle.main.loadNibNamed("HowToView", owner: nil, options: nil)?.first as? HowToView
        {
            view.addSubview(howToView)
            howToView.fillSuperView()
        }
    }
    
    // MARK: - Protocol methods
    
    func currentTimeLimit() -> Int
    {
        if currentGame.isOvertime
        {
            return Game.overtimeTimeLimit
        }
        else
        {
            return Game.regularTimeLimit
        }
    }
    
    func updatedPlayerStat(playerNumber: Int, typeOfStat: Int, stat: Int) {
        if let typeOfStat = Stat(rawValue: typeOfStat)
        {
            var player: Player!
            
            player = playerNumber == 1 ? playerOne : playerTwo
            
            switch typeOfStat
            {
            case .point: player.points = stat
            case .foul: player.fouls = stat
            case .tech: player.techs = stat
            }
            
            checkGameLimits(playerNumber: playerNumber)
        }
    }

    
    // MARK: - Alert methods
    
    func presentLosingStatsAlert(_ button: UIBarButtonItem) {
        // Alert the user their data won't be saved if they continue
        let alert = UIAlertController(title: "Oh no, the stats!", message: "You must finish the series for them to be saved.", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let continueAction = UIAlertAction(title: "Exit", style: .destructive, handler: { (alert) in
            // If the user presses continue the game view controller leaves the navigationvc
            if let navVc = self.parent as? UINavigationController {
                if let twentyVc = navVc.viewControllers.first as? TwentyViewController {
                    navVc.popToViewController(twentyVc, animated: true)
                }
            }
        })
        alert.addAction(cancelAction)
        alert.addAction(continueAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func presentEndingGameAlert(_ button: UIBarButtonItem) {
        let alert = UIAlertController(title: "Are you sure?", message: nil, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let yes = UIAlertAction(title: "Yes, I'm Sure", style: .default, handler: handleUserEndingGame(_:))
        alert.addAction(cancel)
        alert.addAction(yes)
        self.present(alert, animated: true, completion: nil)
    }
    
    func handleUserEndingGame(_ alert: UIAlertAction) {
        timerLabel.stopTimer()
        currentGame.addTotals(for: currentGame.playerOne)
        currentGame.addTotals(for: currentGame.playerTwo)
        
        if currentGame.shouldGoToOvertime {
            currentGame.isOvertime = true
            // Show and animate overtime view
            let endView = endOfGameView(typeOfEnding: Ending.overtime)
            view.addSubview(endView)
            UIView.animate(withDuration: 1, animations: { endView.alpha = 1 }, completion: { (bool) in
                self.navigationItem.title = "Game \(self.currentGame.gameNumber) OT"
                self.currentGame.resetStats()
                self.resetStatLabels()
                UIView.animate(withDuration: 1, delay: 1, options: UIViewAnimationOptions.curveLinear, animations: { endView.alpha = 0 }, completion: { (bool) in
                    endView.removeFromSuperview()
                })
            })
        }
        else {
            currentGame.decideWinner()
            if currentGame.shouldEndSeries {
                // Show and animate "Joe Mendiola Has Won The Series!"
                let endView = endOfGameView(typeOfEnding: Ending.series("\(currentGame.winnersName)"))
                view.addSubview(endView)
                self.navigationItem.leftBarButtonItem = nil
                self.navigationItem.rightBarButtonItem = nil
                currentGame.isOvertime = false
                self.navigationItem.title = "Series Over"
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Leave", style: .plain, target: self, action: #selector(GameViewController.leaveSeriesAfterWin(_:)))
                UIView.animate(withDuration: 1, animations: { endView.alpha = 1 }, completion: nil)
                // initialize data manager with stats array
                // have data manager store stats in userdefaults
                let seriesStats = SeriesStats(game: currentGame)
                let statsManager = StatsManager(seriesStats)
                statsManager.saveStats()
                
            }
            else {
                // Show and an image "Game \(Whatever the next game is)"
                currentGame.gameNumber += 1
                currentGame.isOvertime = false
                let endView = endOfGameView(typeOfEnding: Ending.game(currentGame.gameNumber))
                view.addSubview(endView)
                UIView.animate(withDuration: 1, animations: { endView.alpha = 1 }, completion: { (bool) in
                    self.navigationItem.title = "Game \(self.currentGame.gameNumber)"
                    self.playerOneGamesWon.text = String(self.currentGame.playerOne.gamesWon)
                    self.playerTwoGamesWon.text = String(self.currentGame.playerTwo.gamesWon)
                    self.currentGame.resetStats()
                    self.resetStatLabels()
                    UIView.animate(withDuration: 1, delay: 1, options: UIViewAnimationOptions.curveLinear, animations: { endView.alpha = 0 }, completion: { (bool) in
                        endView.removeFromSuperview()
                    })
                })
            }
        }
    }
    
    func leaveSeriesAfterWin(_ button: UIBarButtonItem) {
        if let firstVc = navigationController?.viewControllers.first {
            let _ = navigationController?.popToViewController(firstVc, animated: true)
        }
    }
    
    // MARK: - Helper methods
    
    private func getTagInformation(tag: Int) -> (playerNumber: Int, sectionNumber: Int) {
        // The first element will be the player number so 1 or 2
        // The second element will be the section number so 1 - point, 2 - foul, 3 - tech
        let readableTag = String(tag)
        
        return (Int(String(readableTag[readableTag.startIndex]))!, Int(String(readableTag[readableTag.index(before: readableTag.endIndex)]))!)
    }
    
    private func checkGameLimits(playerNumber: Int) {
        let player = playerNumber == 1 ? currentGame.playerOne : currentGame.playerTwo
        
        if let infractionInfo = currentGame.checkPlayerInfractions(player: player) {
            changeInfractionStatsLabelsToRed(for: player, with: infractionInfo)
            
            let alert = UIAlertController(title: infractionInfo.title, message: "Feel free to end the game.", preferredStyle: .alert)
            let okay = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okay)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func changeInfractionStatsLabelsToRed(for player: Player, with infractionInfo: (infraction: Infraction, title: String)) {
        switch (player.name, infractionInfo.infraction) {
        case (currentGame.playerOne.name, Infraction.foul):
            playerOneFouls.textColor = UIColor.warningRed
        case (currentGame.playerOne.name, Infraction.tech):
            playerOneTechs.textColor = UIColor.warningRed
        case (currentGame.playerOne.name, Infraction.both):
            playerOneFouls.textColor = UIColor.warningRed
            playerOneTechs.textColor = UIColor.warningRed
        case (currentGame.playerTwo.name, Infraction.foul):
            playerTwoFouls.textColor = UIColor.warningRed
        case (currentGame.playerTwo.name, Infraction.tech):
            playerTwoTechs.textColor = UIColor.warningRed
        case (currentGame.playerTwo.name, Infraction.both):
            playerTwoFouls.textColor = UIColor.warningRed
            playerTwoTechs.textColor = UIColor.warningRed
        default: break
        }
    }
    
    private func resetStatLabels() {
        playerOnePoints.text = "0"
        playerOneFouls.text = "0"
        playerOneTechs.text = "0"
        playerTwoPoints.text = "0"
        playerTwoFouls.text = "0"
        playerTwoTechs.text = "0"
        
        playerOneFouls.textColor = UIColor.white
        playerOneTechs.textColor = UIColor.white
        playerTwoFouls.textColor = UIColor.white
        playerTwoTechs.textColor = UIColor.white
        
        if currentGame.isOvertime {
            timerLabel.text = "10.0"
        }
        else {
            timerLabel.text = "20.0"
        }
        
        timerLabel.backgroundColor = .fadedBrightGreen
    }
    
    // MARK: - View returning methods
    
    
    func endOfGameView(typeOfEnding: Ending) -> UIView {
        let entireView = UIView()
        entireView.alpha = 0
        
        let endingDescription = UILabel()
        endingDescription.textAlignment = .center
        endingDescription.font = UIFont.systemFont(ofSize: 50, weight: UIFontWeightBold)
        endingDescription.textColor = .white
        endingDescription.numberOfLines = 0
        endingDescription.translatesAutoresizingMaskIntoConstraints = false
        
        switch typeOfEnding {
        case .overtime: endingDescription.text = "OVERTIME"
        case .game(let game): endingDescription.text = "GAME \(game)"
        case .series(let name): endingDescription.text = "\(name) \n HAS WON!".uppercased()
        }
        
        entireView.addSubview(endingDescription)
        NSLayoutConstraint.activate([
            endingDescription.centerYAnchor.constraint(equalTo: entireView.centerYAnchor, constant: 0),
            endingDescription.leftAnchor.constraint(equalTo: entireView.leftAnchor),
            endingDescription.rightAnchor.constraint(equalTo: entireView.rightAnchor)
            ])
        endingDescription.translatesAutoresizingMaskIntoConstraints = false
        
        return entireView
    }
}
