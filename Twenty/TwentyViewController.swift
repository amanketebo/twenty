
//
//  ViewController.swift
//  Twenty
//
//  Created by Amanuel Ketebo on 1/2/17.
//  Copyright © 2017 Amanuel Ketebo. All rights reserved.
//

import UIKit

class TwentyViewController: UIViewController {
    
    let defaults = UserDefaults.standard
    private let imageAlpha: CGFloat = 0.40
    
    @IBOutlet weak var newGame: UIImageView! {
        didSet {
            newGame.addGestureRecognizer(UITapGestureRecognizer(
                target: self,
                action: #selector(TwentyViewController.segueToNewGameVc(_:))
            ))
        }
    }
    @IBOutlet weak var statistics: UIImageView! {
        didSet {
            statistics.addGestureRecognizer(UITapGestureRecognizer(
                target: self,
                action: #selector(TwentyViewController.segueToStatisticsVc(_:)
                )
            ))
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.barTintColor = .darkBlack
        navigationController?.navigationBar.isTranslucent = false
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        newGame.alpha = imageAlpha
        statistics.alpha = imageAlpha
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        print("Dipped out: TwentyViewController.")
    }
    
    func segueToNewGameVc (_ recognizer: UITapGestureRecognizer) {
        performSegue(withIdentifier: "New Game", sender: nil)
    }
    
    func segueToStatisticsVc(_ recognizer: UITapGestureRecognizer) {
        performSegue(withIdentifier: "Statistics", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let statsVC = segue.destination as? StatisticsViewController {
            let statManager = StatsManager()
            statsVC.averageStats = statManager.getStats()
        }
    }
    
}

