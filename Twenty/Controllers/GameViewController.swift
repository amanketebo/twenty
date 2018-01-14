//
//  GameViewController.swift
//  Twenty
//
//  Created by Amanuel Ketebo on 2/19/17.
//  Copyright © 2017 Amanuel Ketebo. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {
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
        timerLabel.delegate = self
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
        playerOneGamesWon.text = String(playerOne.gamesWon)
        playerTwoName.text = currentGame.playerTwo.name
        playerTwoGamesWon.text = String(playerTwo.gamesWon)
        seriesLimitLabel.text = "SERIES: \(currentGame.seriesLimit)"
        foulLimitLabel.text = "FOULS: \(currentGame.foulLimit)"
        techLimitLabel.text = "TECHS: \(currentGame.techLimit)"
    }

    func presentHowToView() {
        guard let howToView = Bundle.main.loadNibNamed("HowToView", owner: nil, options: nil)?.first as? HowToView else { return }

        view.addSubview(howToView)
        howToView.fillSuperView()
    }

    private func checkGameLimits(playerNumber: Int) {
        let player = playerNumber == 1 ? currentGame.playerOne : currentGame.playerTwo

        if let infractionInfo = currentGame.checkPlayerInfractions(player: player) {
            changeStatsLabelsToRed(for: player, with: infractionInfo.infraction)

            let alert = UIAlertController(title: infractionInfo.description, message: "Feel free to end the game.", preferredStyle: .alert)
            let okay = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okay)
            self.present(alert, animated: true, completion: nil)
        }
    }

    private func changeStatsLabelsToRed(for player: Player, with infraction: Infraction) {
        switch (player.name, infraction) {
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

    @objc func presentLosingStatsAlert(_ button: UIBarButtonItem) {
        let alert = UIAlertController(title: "Oh no, the stats!", message: "You must finish the series for them to be saved.", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let exitAction = UIAlertAction(title: "Exit", style: .destructive, handler: { [weak self] (alert) in
            self?.popToFirstVC()
        })

        alert.addAction(cancelAction)
        alert.addAction(exitAction)
        present(alert, animated: true, completion: nil)
    }

    @objc func presentEndingGameAlert(_ button: UIBarButtonItem) {
        let alert = UIAlertController(title: "Are you sure?", message: nil, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let yesAction = UIAlertAction(title: "Yes, I'm Sure", style: .default, handler: handleEndOfGame(_:))

        alert.addAction(cancelAction)
        alert.addAction(yesAction)
        self.present(alert, animated: true, completion: nil)
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
                self.playerOneGamesWon.text = String(self.currentGame.playerOne.gamesWon)
                self.playerTwoGamesWon.text = String(self.currentGame.playerTwo.gamesWon)
                self.currentGame.resetStats()
                self.resetStatLabels()
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
                self.resetStatLabels()
                endOfGameView.fadeOut(duration: animationDuration, delay: animationDelay, completion: { (success) in
                    endOfGameView.removeFromSuperview()
                })
            })
        case .series(let winnersName):
            currentGame.isOvertime = false
            endOfGameView = setupEndOfGameView(gameEnding: GameEnding.series("\(winnersName)"))
            view.addSubview(endOfGameView)
            endOfGameView.translatesAutoresizingMaskIntoConstraints = false
            endOfGameView.fillSuperView()
            navigationItem.leftBarButtonItem = nil
            navigationItem.rightBarButtonItem = nil
            navigationItem.title = "Series Over"
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Leave", style: .plain, target: self, action: #selector(popToFirstVC))
            endOfGameView.fadeIn(duration: 1, delay: 0, completion: nil)
            // Save stats
            let seriesStats = SeriesStats(game: currentGame)
            let statsManager = StatsManager(seriesStats)

            statsManager.saveStats()
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
}

extension GameViewController: StatLabelDelegate {
    func updatedPlayerStat(playerNumber: Int, statType: Int, stat: Int) {
        if let typeOfStat = Stat(rawValue: statType) {
            var player: Player!

            player = playerNumber == 1 ? playerOne : playerTwo

            switch typeOfStat {
            case .point: player.points = stat
            case .foul: player.fouls = stat
            case .tech: player.techs = stat
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
