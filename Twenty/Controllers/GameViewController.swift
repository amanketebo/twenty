//
//  GameViewController.swift
//  Twenty
//
//  Created by Amanuel Ketebo on 2/19/17.
//  Copyright © 2017 Amanuel Ketebo. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {
    @IBOutlet weak var playerOnePoints: StatView!
    @IBOutlet weak var playerOneFouls: StatView!
    @IBOutlet weak var playerOneTechs: StatView!
    @IBOutlet weak var playerTwoPoints: StatView!
    @IBOutlet weak var playerTwoFouls: StatView!
    @IBOutlet weak var playerTwoTechs: StatView!
    @IBOutlet weak var seriesLimitLabel: UILabel!
    @IBOutlet weak var foulLimitLabel: UILabel!
    @IBOutlet weak var techLimitLabel: UILabel!
    @IBOutlet weak var playerOneGamesWon: UILabel!
    @IBOutlet weak var playerTwoGamesWon: UILabel!
    @IBOutlet weak var playerOneName: UILabel!
    @IBOutlet weak var playerTwoName: UILabel!
    @IBOutlet weak var timerLabel: TimerLabel! {
        didSet {
            timerLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 60, weight: UIFont.Weight.light)
        }
    }

    var currentGame: Game!
    var playerOne: Player!
    var playerTwo: Player!

    private let defaults = UserDefaults.standard
    typealias InfrationInfo = (infraction: Infraction, description: String)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavbar()
        setupGameInformation()
        setDelegates()
    }

    override func viewDidAppear(_ animated: Bool) {
        let firstTimeUsingApp = defaults.bool(forKey: UserDefaults.firstTimeUsingAppKey)

        if firstTimeUsingApp {
            presentHowToView()
            defaults.set(false, forKey: UserDefaults.firstTimeUsingAppKey)
        }
    }

    func setupNavbar() {
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
    }

    func setupGameInformation() {
        playerOneName.text = currentGame.playerOne.name
        playerOneGamesWon.text = String(playerOne.seriesGamesWon)
        playerTwoName.text = currentGame.playerTwo.name
        playerTwoGamesWon.text = String(playerTwo.seriesGamesWon)
        seriesLimitLabel.text = "SERIES: \(currentGame.seriesLimit)"
        foulLimitLabel.text = "FOULS: \(currentGame.foulLimit)"
        techLimitLabel.text = "TECHS: \(currentGame.techLimit)"
    }

    func setDelegates() {
        timerLabel.delegate = self
        playerOnePoints.delegate = self
        playerOneFouls.delegate = self
        playerOneTechs.delegate = self
        playerTwoPoints.delegate = self
        playerTwoFouls.delegate = self
        playerTwoTechs.delegate = self
    }

    func presentHowToView() {
        guard let howToView = Bundle.main.loadNibNamed("HowToView", owner: nil, options: nil)?.first as? HowToView else { return }

        view.addSubview(howToView)
        howToView.fillSuperView()
    }

    private func checkGameLimits(playerNumber: Int) {
        let player = playerNumber == 1 ? currentGame.playerOne : currentGame.playerTwo

        if let infraction = currentGame.checkPlayerInfractions(player: player) {
            changeStatsLabelsToRed(for: player, with: infraction)

            switch infraction {
                case .foul(let info), .both(let info), .tech(let info):
                    Alert.showAlert(in: self, title: info, message: "Feel free to end the game.")
            }
        }
    }

    private func changeStatsLabelsToRed(for player: Player, with infraction: Infraction) {
        switch (player.name, infraction) {
        case (currentGame.playerOne.name, Infraction.foul):
            playerOneFouls.overLimit()
        case (currentGame.playerOne.name, Infraction.tech):
            playerOneTechs.overLimit()
        case (currentGame.playerOne.name, Infraction.both):
            playerOneFouls.overLimit()
            playerOneTechs.overLimit()
        case (currentGame.playerTwo.name, Infraction.foul):
            playerTwoFouls.overLimit()
        case (currentGame.playerTwo.name, Infraction.tech):
            playerTwoTechs.overLimit()
        case (currentGame.playerTwo.name, Infraction.both):
            playerTwoFouls.overLimit()
            playerTwoTechs.overLimit()
        default: break
        }
    }

    @objc func presentLosingStatsAlert(_ button: UIBarButtonItem) {
        let title = "Oh no, the stats!"
        let message = "You must finish the series for them to be saved."
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let exitAction = UIAlertAction(title: "Exit", style: .destructive, handler: { [weak self] (alert) in
            self?.currentGame.resetStats()
            self?.popToFirstVC()
        })

        Alert.showAlert(in: self, title: title, message: message, actions: [cancelAction, exitAction])
    }

    @objc func presentEndingGameAlert(_ button: UIBarButtonItem) {
        let title = "Are you sure?"
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let yesAction = UIAlertAction(title: "Yes, I'm Sure", style: .default, handler: handleEndOfGame(_:))

        Alert.showAlert(in: self, title: title, message: nil, actions: [cancelAction, yesAction])
    }

    func handleEndOfGame(_ alert: UIAlertAction) {
        guard let gameEnding = currentGame.decideEndOfGame() else { return }
        let animationDuration: TimeInterval = 0.5
        let animationDelay: TimeInterval = 1
        var endOfGameView: EndOfGameView!

        timerLabel.stopTimer()

        switch gameEnding {
        case .game(let gameNumber):
            currentGame.isOvertime = false
            endOfGameView = setupEndOfGameView(gameEnding: GameEnding.game(currentGame.gameNumber))
            view.addSubview(endOfGameView)
            endOfGameView.translatesAutoresizingMaskIntoConstraints = false
            endOfGameView.fillSuperView()
            endOfGameView.fadeIn(duration: animationDuration, delay: 0, completion: { (success) in
                self.navigationItem.title = "Game \(gameNumber)"
                self.playerOneGamesWon.text = String(self.currentGame.playerOne.seriesGamesWon)
                self.playerTwoGamesWon.text = String(self.currentGame.playerTwo.seriesGamesWon)
                self.currentGame.resetStats()
                self.resetStatViews()
                endOfGameView.fadeOut(duration: animationDuration, delay: animationDelay, completion: { (success) in
                    endOfGameView.removeFromSuperview()
                })
            })
        case .overtime:
            currentGame.isOvertime = true
            endOfGameView = setupEndOfGameView(gameEnding: GameEnding.overtime)
            view.addSubview(endOfGameView)
            endOfGameView.translatesAutoresizingMaskIntoConstraints = false
            endOfGameView.fillSuperView()
            endOfGameView.fadeIn(duration: animationDuration, delay: 0, completion: { (success) in
                self.navigationItem.title = "Game \(self.currentGame.gameNumber) OT"
                self.currentGame.resetStats()
                self.resetStatViews()
                endOfGameView.fadeOut(duration: animationDuration, delay: animationDelay, completion: { (success) in
                    endOfGameView.removeFromSuperview()
                })
            })
        case .series(let winnersName):
            currentGame.isOvertime = false
            currentGame.resetStats()
            endOfGameView = setupEndOfGameView(gameEnding: GameEnding.series("\(winnersName)"))
            view.addSubview(endOfGameView)
            endOfGameView.translatesAutoresizingMaskIntoConstraints = false
            endOfGameView.fillSuperView()
            navigationItem.leftBarButtonItem = nil
            navigationItem.rightBarButtonItem = nil
            navigationItem.title = "Series Over"
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Leave", style: .plain, target: self, action: #selector(popToFirstVC))
            endOfGameView.fadeIn(duration: animationDuration, delay: 0, completion: nil)
            // Save stats
            let statsManager = StatsManager.shared
            statsManager.savePlayerStats(for: playerOne, playerTwo)
        }
    }

    @objc func popToFirstVC() {
        guard let firstVC = navigationController?.viewControllers.first else { return }

        navigationController?.popToViewController(firstVC, animated: true)
    }

    private func setupEndOfGameView(gameEnding: GameEnding) -> EndOfGameView {
        let endOfGameView = Bundle.main.loadNibNamed("EndOfGameView", owner: nil, options: nil)?.first as! EndOfGameView
        var endOfGameDescription = ""

        switch gameEnding {
        case .overtime: endOfGameDescription = "overtime".uppercased()
        case .game(let game): endOfGameDescription = "game \(game)".uppercased()
        case .series(let name): endOfGameDescription = "\(name) \n has won!".uppercased()
        }

        endOfGameView.descriptionLabel.text = endOfGameDescription

        return endOfGameView
    }

    private func resetStatViews() {
        playerOnePoints.reset()
        playerOneFouls.reset()
        playerOneTechs.reset()
        playerTwoPoints.reset()
        playerTwoFouls.reset()
        playerTwoTechs.reset()

        if currentGame.isOvertime {
            timerLabel.text = "10.0"
        }
        else {
            timerLabel.text = "20.0"
        }

        timerLabel.backgroundColor = .brightGreen
    }
}

extension GameViewController: StatViewDelegate {
    func updatedPlayerStat(playerNumber: Int, statType: Int, stat: Int) {
        if let typeOfStat = Stat(rawValue: statType) {
            var player: Player!

            player = playerNumber == 1 ? playerOne : playerTwo

            switch typeOfStat {
            case .point: player.currentGamePoints = stat
            case .foul: player.currentGameFouls = stat
            case .tech: player.currentGameTechs = stat
            }
    
            checkGameLimits(playerNumber: playerNumber)
        }
    }
}

extension GameViewController: TimerLabelDelegate {
    func currentTimeLimit() -> Int {
        if currentGame.isOvertime {
            return Game.overtimeTimeLimit
        }
        else {
            return Game.regularTimeLimit
        }
    }
}
