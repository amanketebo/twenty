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
    @IBOutlet weak var newGameImageView: UIImageView!
    @IBOutlet weak var statisticsImageView: UIImageView!
    
    // MARK: - Properties
    private let imageAlpha: CGFloat = 0.40
    private let defaults = UserDefaults.standard
    
    // MARK: - Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        newGameImageView.alpha = imageAlpha
        statisticsImageView.alpha = imageAlpha
    }
    
    // MARK: - Action methods
    @IBAction func segueToNewGameVC(_ sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: UIStoryboard.newGameVCSegue, sender: nil)
    }
    
    @IBAction func segueToStatisticsVC(_ sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: UIStoryboard.statisticsVCSegue, sender: nil)

    }
    
    // MARK: - Segue functions
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let statsVC = segue.destination as? StatisticsViewController {
            let statManager = StatsManager()
            
            statsVC.averageStats = statManager.getStats()
            statsVC.statsOrdering = StatsOrdering(rawValue: defaults.integer(forKey: UserDefaults.savedStatsOrderingKey))
        }
    }
}
