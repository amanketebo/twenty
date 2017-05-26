//
//  GameViewController.swift
//  Twenty
//
//  Created by Amanuel Ketebo on 2/19/17.
//  Copyright © 2017 Amanuel Ketebo. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var playerOnePoints: UILabel!
    @IBOutlet weak var playerOneFouls: UILabel!
    @IBOutlet weak var playerOneTechs: UILabel!
    @IBOutlet weak var playerTwoPoints: UILabel!
    @IBOutlet weak var playerTwoFouls: UILabel!
    @IBOutlet weak var playerTwoTechs: UILabel!
    @IBOutlet weak var seriesLimitLabel: UILabel!
    @IBOutlet weak var foulLimitLabel: UILabel!
    @IBOutlet weak var techLimitLabel: UILabel!
    @IBOutlet weak var playerOneGamesWon: UILabel!
    @IBOutlet weak var playerTwoGamesWon: UILabel!
    @IBOutlet weak var playerOneName: UILabel!
    @IBOutlet weak var playerTwoName: UILabel!
    @IBOutlet weak var timerLabel: UILabel! {
        didSet {
            // Couldn't give timerLabel a monpspaced font in storyboard so had to do it here.
            timerLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 60, weight: UIFontWeightLight)
        }
    }
    
    // MARK: - Properties
    
    let defaults = UserDefaults.standard
    var currentGame: Game!
    var firstTimeTimer: Timer?
    var firstTimeTimerLabel: UILabel?
    var currentlyDisplayingInformationalView = false
    var timer: Timer?
    var currentTime: Int {
        get {
            // firstTimeTimerLabel!.text since if the information view is being displayed
            //      the firstTimeTimerLabel! is not nil
            // timerLabel.text! since there will aways be a number in the text label
            var timerText = currentlyDisplayingInformationalView ? firstTimeTimerLabel!.text! : timerLabel.text!
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
            
            if currentlyDisplayingInformationalView {
                firstTimeTimerLabel?.text = number
            }
            else {
                timerLabel.text = number
            }
        }
    }
    
    // MARK: - Life Cycle Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupLabels()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let usedAppBefore = defaults.bool(forKey: "usedAppBefore")
        
        if !usedAppBefore {
            view.addSubview(instructionalView())
            currentlyDisplayingInformationalView = true
            navigationItem.rightBarButtonItem?.isEnabled = false
            defaults.set(true, forKey: "usedAppBefore")
        }
    }
    
    //MARK: - Setup Functions
    
    func setupNavigationBar() {
        navigationItem.title = "Game \(currentGame.gameNumber)"
        navigationItem.setHidesBackButton(true, animated: true)
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Exit",
            style: .plain,
            target: self,
            action: #selector(GameViewController.showLosingStatsAlert(_:)
            ))
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "End Game",
            style: .plain,
            target: self,
            action: #selector(GameViewController.showEndingGameAlert(_:)
            ))
        
        // Remove previous view controller aka the GameLimitsViewController from navigation controller
        if let navVc = self.parent as? UINavigationController {
            navVc.viewControllers.remove(at: 1)
        }
    }
    
    func setupLabels() {
        seriesLimitLabel.text = "SERIES: \(currentGame.seriesLimit)"
        foulLimitLabel.text = "FOULS: \(currentGame.foulLimit)"
        techLimitLabel.text = "TECHS: \(currentGame.techLimit)"
        playerOneName.text = currentGame.playerOne.name
        playerTwoName.text = currentGame.playerTwo.name
        playerOneGamesWon.text = String(currentGame.playerOne.gamesWonInSeries)
        playerTwoGamesWon.text = String(currentGame.playerTwo.gamesWonInSeries)
    }
    
    // MARK: - Action functions
    
    @IBAction func swippedStat(_ sender: UISwipeGestureRecognizer) {
        if let statsLabel = sender.view as? UILabel {
            stopTimer()
            // Check the direction of the swipe to increase/decrease the stat
            let swipeDirection = sender.direction
            // Tag on the label indicates the player and what type of stat was swiped
            let tagInfo = getTagInformation(tag: statsLabel.tag)
            
            switch swipeDirection {
            case UISwipeGestureRecognizerDirection.up:
                let newStat = Int(statsLabel.text!)! + 1
                
                statsLabel.text = String(newStat)
                currentGame.increaseStats(tagInfo: tagInfo)
                checkGameLimits(playerNumber: tagInfo.playerNumber)
            case UISwipeGestureRecognizerDirection.down:
                let newStat = Int(statsLabel.text!)! - 1
                guard newStat >= 0 else { return }
                
                statsLabel.text = String(newStat)
                currentGame.decreaseStats(tagInfo: tagInfo)
                checkGameLimits(playerNumber: tagInfo.playerNumber)
            default: break
            }
        }
    }
    
    @IBAction func swippedTimerLabel(_ sender: UISwipeGestureRecognizer) {
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
            
            if currentGame.isOvertime {
                if newTime >= currentGame.overtimeAllottedTime {
                    currentTime = currentGame.overtimeAllottedTime
                    return
                }
            }
            else {
                if newTime >= currentGame.regularAllottedTime {
                    currentTime = currentGame.regularAllottedTime
                    return
                }
            }
            
            currentTime = newTime
        default: break
        }
    }
    
    func pressedOkGotIt(_ button: UIButton) {
        navigationItem.rightBarButtonItem?.isEnabled = true
        if let top = button.superview as? UIImageView {
            firstTimeTimerLabel = nil
            top.removeFromSuperview()
            currentlyDisplayingInformationalView = false
        }
    }
    
    // MARK: - Timer functions
    
    @IBAction func tappedTimer(_ sender: UITapGestureRecognizer) {
        if currentlyDisplayingInformationalView {
            if firstTimeTimer == nil {
                startTimer()
            }
            else {
                stopTimer()
            }
        }
        else {
            if timer == nil {
                startTimer()
            }
            else {
                stopTimer()
            }
        }
    }
    
    private func startTimer() {
        if currentlyDisplayingInformationalView {
            guard firstTimeTimer == nil else { return }
            
            firstTimeTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(GameViewController.tickTimer(_:)), userInfo: nil, repeats: true)
            firstTimeTimerLabel?.backgroundColor = .fadedBrightRed
        }
        else {
            guard timer == nil else { return }
            
            timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(GameViewController.tickTimer(_:)), userInfo: nil, repeats: true)
            timerLabel.backgroundColor = .fadedBrightRed
        }
    }
    
    private func stopTimer() {
        if currentlyDisplayingInformationalView {
            guard firstTimeTimer != nil else { return }
            
            firstTimeTimerLabel?.backgroundColor = .fadedBrightGreen
            firstTimeTimer?.invalidate()
            firstTimeTimer = nil
        }
        else {
            guard timer != nil else { return }
            
            timerLabel.backgroundColor = .fadedBrightGreen
            timer?.invalidate()
            timer = nil
        }
    }
    
    func tickTimer(_ timer: Timer) {
        // If the timer is less than zero that means time has run out
        guard currentTime > 0 else {
            stopTimer()
            return
        }
        
        currentTime = currentTime - 1
    }
    
    // MARK: - Alert functions
    
    func showLosingStatsAlert(_ button: UIBarButtonItem) {
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
    
    func showEndingGameAlert(_ button: UIBarButtonItem) {
        let alert = UIAlertController(title: "Are you sure?", message: nil, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let yes = UIAlertAction(title: "Yes, I'm Sure", style: .default, handler: handleUserEndingGame(_:))
        alert.addAction(cancel)
        alert.addAction(yes)
        self.present(alert, animated: true, completion: nil)
    }
    
    func handleUserEndingGame(_ alert: UIAlertAction) {
        stopTimer()
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
                let endView = endOfGameView(typeOfEnding: Ending.series("\(currentGame.wonSeries)"))
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
                    self.playerOneGamesWon.text = String(self.currentGame.playerOne.gamesWonInSeries)
                    self.playerTwoGamesWon.text = String(self.currentGame.playerTwo.gamesWonInSeries)
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
    
    // MARK: - Helper functions
    
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
    
    // MARK: - View returning functions
    
    func blurredView() -> UIImageView {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: view.bounds.size.height))
        let imageSize = CGSize(width: view.bounds.size.width, height: view.bounds.size.height)
        let blurredView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        
        UIGraphicsBeginImageContext(imageSize)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        imageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        blurredView.frame = imageView.frame
        imageView.isUserInteractionEnabled = true
        imageView.addSubview(blurredView)
        
        return imageView
    }
    
    func instructionalPlayerStatsLabel() -> UILabel {
        let playerPointsFrameInView = playerOnePoints.convert(playerOnePoints.frame, to: view)
        let firstTimePlayerStatsLabel = UILabel()
        
        firstTimePlayerStatsLabel.text = "0"
        firstTimePlayerStatsLabel.font = UIFont.systemFont(ofSize: 50, weight: UIFontWeightMedium)
        firstTimePlayerStatsLabel.textColor = .white
        firstTimePlayerStatsLabel.textAlignment = .center
        firstTimePlayerStatsLabel.backgroundColor = .lightBlack
        firstTimePlayerStatsLabel.clipsToBounds = true
        firstTimePlayerStatsLabel.layer.borderWidth = 1
        firstTimePlayerStatsLabel.layer.borderColor = UIColor.white.cgColor
        firstTimePlayerStatsLabel.layer.cornerRadius = 10
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(swippedStat(_:)))
        swipeUp.direction = .up
        firstTimePlayerStatsLabel.addGestureRecognizer(swipeUp)
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(swippedStat(_:)))
        swipeDown.direction = .down
        firstTimePlayerStatsLabel.addGestureRecognizer(swipeDown)
        
        firstTimePlayerStatsLabel.isUserInteractionEnabled = true
        NSLayoutConstraint.activate([
            firstTimePlayerStatsLabel.widthAnchor.constraint(equalToConstant: playerPointsFrameInView.size.width),
            firstTimePlayerStatsLabel.heightAnchor.constraint(equalToConstant: playerPointsFrameInView.size.height)
            ])
        firstTimePlayerStatsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        return firstTimePlayerStatsLabel
    }
    
    func instructionalTimerLabel() -> UILabel {
        firstTimeTimerLabel = UILabel()
        firstTimeTimerLabel?.text = "20.0"
        firstTimeTimerLabel?.font = UIFont.monospacedDigitSystemFont(ofSize: 60.0, weight: UIFontWeightLight)
        firstTimeTimerLabel?.textColor = .white
        firstTimeTimerLabel?.textAlignment = .center
        firstTimeTimerLabel?.backgroundColor = .fadedBrightGreen
        firstTimeTimerLabel?.clipsToBounds = true
        firstTimeTimerLabel?.layer.borderColor = UIColor.white.cgColor
        firstTimeTimerLabel?.layer.borderWidth = 1
        firstTimeTimerLabel?.layer.cornerRadius = 10
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swippedTimerLabel(_:)))
        swipeLeft.direction = .left
        firstTimeTimerLabel?.addGestureRecognizer(swipeLeft)
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(swippedTimerLabel(_:)))
        swipeRight.direction = .right
        firstTimeTimerLabel?.addGestureRecognizer(swipeRight)
        firstTimeTimerLabel?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tappedTimer(_:))))
        
        firstTimeTimerLabel?.isUserInteractionEnabled = true
        firstTimeTimerLabel?.heightAnchor.constraint(equalToConstant: timerLabel.bounds.size.height).isActive = true
        firstTimeTimerLabel?.translatesAutoresizingMaskIntoConstraints = false
        
        return firstTimeTimerLabel!
    }
    
    
    func instructionalView() -> UIView {
        let entireView = blurredView()
        let playerStatsHowToLabel = instructionalPlayerStatsLabel()
        let firstTimeTimerLabel = instructionalTimerLabel()
        
        let swipeUpDownInstructionLabel = UILabel()
        swipeUpDownInstructionLabel.text = "Swipe up/down \n to change the stats"
        swipeUpDownInstructionLabel.font = UIFont.systemFont(ofSize: 20, weight: UIFontWeightThin)
        swipeUpDownInstructionLabel.textColor = .white
        swipeUpDownInstructionLabel.numberOfLines = 0
        swipeUpDownInstructionLabel.textAlignment = .center
        swipeUpDownInstructionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let swipeLeftRightInstructionLabel = UILabel()
        swipeLeftRightInstructionLabel.text = "Tap or swipe left/right \n to change game clock"
        swipeLeftRightInstructionLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 20, weight: UIFontWeightThin)
        swipeLeftRightInstructionLabel.textColor = .white
        swipeLeftRightInstructionLabel.numberOfLines = 0
        swipeLeftRightInstructionLabel.textAlignment = .center
        swipeLeftRightInstructionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let okGotItButton = UIButton()
        okGotItButton.setTitle("Ok, got it", for: .normal)
        okGotItButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: UIFontWeightBold)
        okGotItButton.titleLabel?.textColor = .white
        okGotItButton.layer.cornerRadius = 5
        okGotItButton.layer.borderWidth = 1
        okGotItButton.layer.borderColor = UIColor.white.cgColor
        okGotItButton.titleEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: -10)
        okGotItButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 30)
        okGotItButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: UIFontWeightBold)
        okGotItButton.addTarget(self, action: #selector(GameViewController.pressedOkGotIt(_:)), for: .touchUpInside)
        okGotItButton.translatesAutoresizingMaskIntoConstraints = false
        
        entireView.addSubview(playerStatsHowToLabel)
        entireView.addSubview(swipeUpDownInstructionLabel)
        entireView.addSubview(okGotItButton)
        entireView.addSubview(firstTimeTimerLabel)
        entireView.addSubview(swipeLeftRightInstructionLabel)
        
        
        NSLayoutConstraint.activate([
            playerStatsHowToLabel.leftAnchor.constraint(equalTo: entireView.leftAnchor, constant: 20),
            playerStatsHowToLabel.topAnchor.constraint(equalTo: entireView.topAnchor, constant: 30),
            swipeUpDownInstructionLabel.centerYAnchor.constraint(equalTo: playerStatsHowToLabel.centerYAnchor),
            swipeUpDownInstructionLabel.rightAnchor.constraint(equalTo: entireView.rightAnchor),
            swipeUpDownInstructionLabel.leftAnchor.constraint(equalTo: playerStatsHowToLabel.rightAnchor, constant: 10),
            okGotItButton.centerXAnchor.constraint(equalTo: entireView.centerXAnchor),
            okGotItButton.bottomAnchor.constraint(equalTo: entireView.bottomAnchor, constant: -20),
            firstTimeTimerLabel.centerYAnchor.constraint(equalTo: entireView.centerYAnchor, constant: 10),
            firstTimeTimerLabel.leftAnchor.constraint(equalTo: entireView.leftAnchor, constant: 20),
            firstTimeTimerLabel.rightAnchor.constraint(equalTo: entireView.rightAnchor, constant: -20),
            swipeLeftRightInstructionLabel.topAnchor.constraint(equalTo: firstTimeTimerLabel.bottomAnchor, constant: 20),
            swipeLeftRightInstructionLabel.leftAnchor.constraint(equalTo: entireView.leftAnchor),
            swipeLeftRightInstructionLabel.rightAnchor.constraint(equalTo: entireView.rightAnchor)
            ])
        
        return entireView
    }
    
    func endOfGameView(typeOfEnding: Ending) -> UIView {
        let entireView = blurredView()
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
