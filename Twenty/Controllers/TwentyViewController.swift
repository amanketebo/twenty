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
    private var viewHeightDividedByTwo: CGFloat = 0
    private let defaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        setImagesToOriginalAlpha()
    }

    override func viewDidLayoutSubviews() {
        viewHeightDividedByTwo = view.bounds.height / 2
    }

    override func viewDidDisappear(_ animated: Bool) {
        setImagesToOriginalAlpha()
    }

    @IBAction func segueToNewGameVC(_ sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: UIStoryboard.newGameVCSegue, sender: nil)
    }

    @IBAction func segueToStatisticsVC(_ sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: UIStoryboard.statisticsVCSegue, sender: nil)

    }

    private func setImagesToOriginalAlpha() {
        newGameImageView.alpha = imageAlpha
        statisticsImageView.alpha = imageAlpha
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let statsVC = segue.destination as? StatisticsViewController {
            statsVC.statsOrdering = StatsOrdering(rawValue: defaults.integer(forKey: UserDefaults.savedStatsOrderingKey))
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let firstTouch = touches.first

        if let firstTouchLocation = firstTouch?.location(in: view) {
            if firstTouchLocation.y < viewHeightDividedByTwo {
                newGameImageView.alpha = 0.8
            } else {
                statisticsImageView.alpha = 0.8
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        setImagesToOriginalAlpha()
    }
}
