//
//  GameViewController.swift
//  Twenty
//
//  Created by Amanuel Ketebo on 2/19/17.
//  Copyright © 2017 Amanuel Ketebo. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {
    
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
            timerLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 60, weight: UIFontWeightLight)
        }
    }
    var timerHowToLabel: UILabel?

    let defaults = UserDefaults.standard
    var currentGame: Game!
    var timer: Timer?
    var currentTime: Int {
        get {
            // ! since there will aways be a number in the text label
            var labelText = timerHowToLabel?.text ?? timerLabel.text!
            var number = ""
            for character in labelText.characters {
                if character != "." {
                    number.append(String(character))
                }
            }
            return Int(number)!
        }
        set {
            var number = String(newValue)
            if newValue < 10 {
                number.insert("0", at: number.startIndex)
            }
            number.insert(".", at: number.index(before: number.endIndex))
            if timerHowToLabel != nil {
                timerHowToLabel?.text = number
                print("yuhhhhh")
            }
            else {
                timerLabel.text = number
            }
        }
    }
    
    enum Ending {
        case overtime
        case game(Int)
        case series(String)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // Set up navigation bar
        navigationItem.title = "Game \(currentGame.gameNumber)"
        navigationItem.setHidesBackButton(true, animated: true)
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Exit",
            style: .plain,
            target: self,
            action: #selector(GameViewController.alertUserAboutLosingStats(_:)
            ))
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "End Game",
            style: .plain,
            target: self,
            action: #selector(GameViewController.alertUserAboutEndingGame(_:)
            ))
        if let navVc = self.parent as? UINavigationController {
            navVc.viewControllers.remove(at: 1)
        }
        setupLabels()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        defaults.set(false, forKey: "firstTime")
        if !defaults.bool(forKey: "firstTime") {
            view.addSubview(swipeUpDownView())
            navigationItem.rightBarButtonItem?.isEnabled = false
            defaults.set(true, forKey: "firstTime")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        print("Dipped out: GameViewController")
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

    @IBAction func tappedTimer(_ sender: UITapGestureRecognizer) {
        if timer == nil {
            startTimer()
        }
        else {
            stopTimer()
        }
    }
    
    @IBAction func swippedStat(_ sender: UISwipeGestureRecognizer) {
        if let statLabel = sender.view as? UILabel {
            stopTimer()
            // Check the direction of the swipe to increase/decrease the stat
            if sender.direction == UISwipeGestureRecognizerDirection.up {
                let newStat = Int(statLabel.text!)! + 1
                statLabel.text = String(newStat)
            }
            else {
                let newStat = Int(statLabel.text!)! - 1
                guard newStat >= 0 else { return }
                statLabel.text = String(newStat)
            }
            
            let tagInfo = getTagInformation(tag: statLabel.tag)
            // Depending upon the direction you increase or decrease stats the player
            if sender.direction == UISwipeGestureRecognizerDirection.up {
                if tagInfo.playerNumber == 1 {
                    currentGame.increaseStats(player: &currentGame.playerOne, sectionNumber: tagInfo.sectionNumber)
                    checkPlayerLimits(player: currentGame.playerOne)
                }
                else if tagInfo.playerNumber == 2 {
                    currentGame.increaseStats(player: &currentGame.playerTwo, sectionNumber: tagInfo.sectionNumber)
                    checkPlayerLimits(player: currentGame.playerTwo)
                }
            }
            else {
                if tagInfo.playerNumber == 1 {
                    currentGame.decreaseStats(player: &currentGame.playerOne, sectionNumber: tagInfo.sectionNumber)
                    checkPlayerLimits(player: currentGame.playerOne)
                }
                else if tagInfo.playerNumber == 2 {
                    currentGame.decreaseStats(player: &currentGame.playerTwo, sectionNumber: tagInfo.sectionNumber)
                    checkPlayerLimits(player: currentGame.playerTwo)
                }
            }
        }
    }
    
    @IBAction func swippedTimerLabel(_ sender: UISwipeGestureRecognizer) {
        let swipeDirection = sender.direction
        switch swipeDirection {
        case UISwipeGestureRecognizerDirection.left:
            let newTime = currentTime - 10
            
            guard newTime > 0 else {
                currentTime = 0
                return
            }
            
            currentTime = newTime
        case UISwipeGestureRecognizerDirection.right:
            let newTime = currentTime + 10
            
            if currentGame.isOvertime {
                guard newTime <= 100 else {
                    currentTime = 100
                    return
                }
            }
            else {
                guard newTime <= 200 else {
                    currentTime = 200
                    return
                }
            }
            
            currentTime = newTime
        default: break
        }
    }
    
    private func startTimer() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(GameViewController.tickTimer(_:)), userInfo: nil, repeats: true)
        timerLabel.backgroundColor = .fadedBrightRed
    }
    
    private func stopTimer() {
        guard timer != nil else { return }
        timerLabel.backgroundColor = .fadedBrightGreen
        timer?.invalidate()
        timer = nil
    }
    
    func tickTimer(_ timer: Timer) {
        // If the timer isn't greater than zero that means time has run out
        guard currentTime > 0 else {
            stopTimer()
            return
        }
        
        currentTime = currentTime - 1
    }
    
    func alertUserAboutLosingStats(_ button: UIBarButtonItem) {
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
    
    func alertUserAboutEndingGame(_ button: UIBarButtonItem) {
        let alert = UIAlertController(title: "Are you sure?", message: nil, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let yes = UIAlertAction(title: "Yes, I'm Sure", style: .default, handler: handleUserEndingGame(_:))
        alert.addAction(cancel)
        alert.addAction(yes)
        self.present(alert, animated: true, completion: nil)
    }
    
    private func getTagInformation(tag: Int) -> (playerNumber: Int, sectionNumber: Int) {
        // The first element will be the player number so 1 or 2
        // The second element will be the section number so 1 - point, 2 - foul, 3 - tech
        let readableTag = String(tag)
        return (Int(String(readableTag[readableTag.startIndex]))!, Int(String(readableTag[readableTag.index(before: readableTag.endIndex)]))!)
    }
    
    private func checkPlayerLimits(player: Player) {
        if let infractionInfo = currentGame.checkPlayerLimits(player: player) {
            let alert = UIAlertController(title: "\(infractionInfo.name) has reached the \(infractionInfo.infraction) limit!", message: "Feel free to end the game.", preferredStyle: .alert)
            let okay = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okay)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func resetStatLabels() {
        playerOnePoints.text = "0"
        playerOneFouls.text = "0"
        playerOneTechs.text = "0"
        playerTwoPoints.text = "0"
        playerTwoFouls.text = "0"
        playerTwoTechs.text = "0"
        
        if currentGame.isOvertime {
            timerLabel.text = "10.0"
        }
        else {
            timerLabel.text = "20.0"
        }
        
        timerLabel.backgroundColor = .fadedBrightGreen
    }
    
    func handleUserEndingGame(_ alert: UIAlertAction) {
        stopTimer()
        currentGame.addTotals(for: currentGame.playerOne)
        currentGame.addTotals(for: currentGame.playerTwo)
        
        if currentGame.shouldGoToOvertime {
            currentGame.isOvertime = true
            // Show and animate overtime view
            let endView = endGameView(end: Ending.overtime)
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
                let endView = endGameView(end: Ending.series("\(currentGame.wonSeries)"))
                view.addSubview(endView)
                self.navigationItem.leftBarButtonItem = nil
                self.navigationItem.rightBarButtonItem = nil
                currentGame.isOvertime = false
                self.navigationItem.title = "Series Over"
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Leave", style: .plain, target: self, action: #selector(GameViewController.popViewController(_:)))
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
                let endView = endGameView(end: Ending.game(currentGame.gameNumber))
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
    
    func popViewController(_ button: UIBarButtonItem) {
        if let firstVc = navigationController?.viewControllers.first {
            let _ = navigationController?.popToViewController(firstVc, animated: true)
        }
    }
    
    func blurEffectView() -> UIImageView {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: view.bounds.size.height))
        let imageSize = CGSize(width: view.bounds.size.width, height: view.bounds.size.height)
        let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        imageView.isUserInteractionEnabled = true
        
        UIGraphicsBeginImageContext(imageSize)
        self.view.layer.render(in: UIGraphicsGetCurrentContext()!)
        imageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        blurEffectView.frame = self.view.bounds
        imageView.addSubview(blurEffectView)
        
        return imageView
    }
    
    func playerPointsLabel() -> UILabel {
        let playerPointsFrameInView = playerOnePoints.convert(playerOnePoints.frame, to: view)
        let playerPointsLabel = UILabel()
        
        playerPointsLabel.text = "0"
        playerPointsLabel.font = UIFont.systemFont(ofSize: 50, weight: UIFontWeightMedium)
        playerPointsLabel.textColor = .white
        playerPointsLabel.textAlignment = .center
        playerPointsLabel.backgroundColor = .lightBlack
        playerPointsLabel.clipsToBounds = true
        playerPointsLabel.layer.borderWidth = 1
        playerPointsLabel.layer.borderColor = UIColor.white.cgColor
        playerPointsLabel.layer.cornerRadius = 10
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(swippedStat(_:)))
        swipeUp.direction = .up
        playerPointsLabel.addGestureRecognizer(swipeUp)
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(swippedStat(_:)))
        swipeDown.direction = .down
        playerPointsLabel.addGestureRecognizer(swipeDown)
        
        playerPointsLabel.isUserInteractionEnabled = true
        playerPointsLabel.widthAnchor.constraint(equalToConstant: playerPointsFrameInView.size.width).isActive = true
        playerPointsLabel.heightAnchor.constraint(equalToConstant: playerPointsFrameInView.size.height).isActive = true
        playerPointsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        return playerPointsLabel
    }
    
    func timerInfoLabel() -> UILabel {
        
        timerHowToLabel = UILabel()
        timerHowToLabel?.text = "20.0"
        timerHowToLabel?.font = UIFont.monospacedDigitSystemFont(ofSize: 60.0, weight: UIFontWeightLight)
        timerHowToLabel?.textColor = .white
        timerHowToLabel?.textAlignment = .center
        timerHowToLabel?.backgroundColor = .fadedBrightGreen
        timerHowToLabel?.clipsToBounds = true
        timerHowToLabel?.layer.borderColor = UIColor.white.cgColor
        timerHowToLabel?.layer.borderWidth = 1
        timerHowToLabel?.layer.cornerRadius = 10
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swippedTimerLabel(_:)))
        swipeLeft.direction = .left
        timerHowToLabel?.addGestureRecognizer(swipeLeft)
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(swippedTimerLabel(_:)))
        swipeRight.direction = .right
        timerHowToLabel?.addGestureRecognizer(swipeRight)
        
        timerHowToLabel?.isUserInteractionEnabled = true
        timerHowToLabel?.heightAnchor.constraint(equalToConstant: timerLabel.bounds.size.height).isActive = true
        timerHowToLabel?.translatesAutoresizingMaskIntoConstraints = false
        
        return timerHowToLabel!
    }
    
    func swipeUpDownView() -> UIView {
        let entireView = blurEffectView()
        let playerPointsHowToLabel = playerPointsLabel()
        let timerHowToLabel = timerInfoLabel()
        
        let statsInfoLabel = UILabel()
        statsInfoLabel.text = "Swipe up and down \n to change stats"
        statsInfoLabel.font = UIFont.systemFont(ofSize: 20, weight: UIFontWeightThin)
        statsInfoLabel.textColor = .white
        statsInfoLabel.numberOfLines = 0
        statsInfoLabel.textAlignment = .center
        statsInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let timerInfo = UILabel()
        timerInfo.text = "Swipe left and right \n to change game clock"
        timerInfo.font = UIFont.monospacedDigitSystemFont(ofSize: 20, weight: UIFontWeightThin)
        timerInfo.textColor = .white
        timerInfo.numberOfLines = 0
        timerInfo.textAlignment = .center
        timerInfo.translatesAutoresizingMaskIntoConstraints = false
        
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
        
        entireView.addSubview(playerPointsHowToLabel)
        entireView.addSubview(statsInfoLabel)
        entireView.addSubview(okGotItButton)
        entireView.addSubview(timerHowToLabel)
        entireView.addSubview(timerInfo)
        
        playerPointsHowToLabel.leftAnchor.constraint(equalTo: entireView.leftAnchor, constant: 20).isActive = true
        playerPointsHowToLabel.topAnchor.constraint(equalTo: entireView.topAnchor, constant: 30).isActive = true
        statsInfoLabel.centerYAnchor.constraint(equalTo: playerPointsHowToLabel.centerYAnchor).isActive = true
        statsInfoLabel.rightAnchor.constraint(equalTo: entireView.rightAnchor).isActive = true
        statsInfoLabel.leftAnchor.constraint(equalTo: playerPointsHowToLabel.rightAnchor, constant: 10).isActive = true
        okGotItButton.centerXAnchor.constraint(equalTo: entireView.centerXAnchor).isActive = true
        okGotItButton.bottomAnchor.constraint(equalTo: entireView.bottomAnchor, constant: -20).isActive = true
        timerHowToLabel.centerYAnchor.constraint(equalTo: entireView.centerYAnchor, constant: 30).isActive = true
        timerHowToLabel.leftAnchor.constraint(equalTo: entireView.leftAnchor, constant: 20).isActive = true
        timerHowToLabel.rightAnchor.constraint(equalTo: entireView.rightAnchor, constant: -20).isActive = true
        timerInfo.topAnchor.constraint(equalTo: timerHowToLabel.bottomAnchor, constant: 20).isActive = true
        timerInfo.leftAnchor.constraint(equalTo: entireView.leftAnchor).isActive = true
        timerInfo.rightAnchor.constraint(equalTo: entireView.rightAnchor).isActive = true
        
        return entireView
    }
    
    func endGameView(end: Ending) -> UIView {
        let entireView = blurEffectView()
        entireView.alpha = 0
        
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 50, weight: UIFontWeightBold)
        label.textColor = .white
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        
        switch end {
        case .overtime: label.text = "OVERTIME"
        case .game(let game): label.text = "GAME \(game)"
        case .series(let name): label.text = "\(name) \n HAS WON!".uppercased()
        }
        
        entireView.addSubview(label)
        label.centerYAnchor.constraint(equalTo: entireView.centerYAnchor, constant: 0).isActive = true
        label.leftAnchor.constraint(equalTo: entireView.leftAnchor).isActive = true
        label.rightAnchor.constraint(equalTo: entireView.rightAnchor).isActive = true
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return entireView
    }
    
    func pressedOkGotIt(_ button: UIButton) {
        navigationItem.rightBarButtonItem?.isEnabled = true
        if let top = button.superview as? UIImageView {
            timerHowToLabel = nil
            top.removeFromSuperview()
        }
    }
}
