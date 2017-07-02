//
//  ViewController.swift
//  Twenty
//
//  Created by Amanuel Ketebo on 1/2/17.
//  Copyright © 2017 Amanuel Ketebo. All rights reserved.
//

import UIKit

class TwentyViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var newGame: UIImageView!
    @IBOutlet weak var statistics: UIImageView!
    
    // MARK: - Properties
    
    private let defaults = UserDefaults.standard
    private let imageAlpha: CGFloat = 0.40
    
    // MARK: - Life cycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.barTintColor = .darkBlack
        navigationController?.navigationBar.isTranslucent = false
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        
        newGame.alpha = imageAlpha
        statistics.alpha = imageAlpha
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Action methods
    
    @IBAction func segueToNewGameVc(_ sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: "New Game", sender: nil)
    }
    
    @IBAction func segueToStatisticsVc(_ sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: "Statistics", sender: nil)

    }
    
    // MARK: - Segue functions
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let statsVC = segue.destination as? StatisticsViewController {
            let statManager = StatsManager()
            statsVC.averageStats = statManager.getStats()
            statsVC.statsOrdering = StatsOrdering(rawValue: defaults.integer(forKey: "savedStatsOrdering"))
        }
    }
    
}

