//
//  ViewController.swift
//  Twenty
//
//  Created by Amanuel Ketebo on 1/2/17.
//  Copyright © 2017 Amanuel Ketebo. All rights reserved.
//

import UIKit

class TwentyViewController: UIViewController {
    @IBOutlet weak var newGameImageView: UIImageView!
    @IBOutlet weak var statisticsImageView: UIImageView!

    private let imageAlpha: CGFloat = 0.40
    private let defaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        newGameImageView.alpha = imageAlpha
        statisticsImageView.alpha = imageAlpha
    }

    @IBAction func segueToNewGameVC(_ sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: UIStoryboard.newGameVCSegue, sender: nil)
    }

    @IBAction func segueToStatisticsVC(_ sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: UIStoryboard.statisticsVCSegue, sender: nil)

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let statsVC = segue.destination as? StatisticsViewController {
            statsVC.statsOrdering = StatsOrdering(rawValue: defaults.integer(forKey: UserDefaults.savedStatsOrderingKey))
        }
    }
}
