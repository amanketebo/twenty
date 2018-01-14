//
//  StatsOrderingView.swift
//  Twenty
//
//  Created by Amanuel Ketebo on 1/9/18.
//  Copyright © 2018 Amanuel Ketebo. All rights reserved.
//

import UIKit

protocol StatsOrderingDelegate: NSObjectProtocol {
    func didSelectStatsOrdering(position: Int)
}

class StatsOrderingView: UIView {
    @IBOutlet weak var statsOrderingsStackView: UIStackView!
    @IBOutlet weak var pointsLeastToGreatestButton: UIButton!
    @IBOutlet weak var pointsGreatestToLeastButton: UIButton!
    @IBOutlet weak var foulsLeastToGreatestButton: UIButton!
    @IBOutlet weak var foulsGreatestToLeastButton: UIButton!
    @IBOutlet weak var techsLeastToGreatestButton: UIButton!
    @IBOutlet weak var techsGreatestToLeastButton: UIButton!

    var statsOrdering: StatsOrdering? {
        willSet {
            previousStatsOrdering = statsOrdering
        }
        didSet {
            setBackgroundColor(.darkBlue)
        }
    }
    private var previousStatsOrdering: StatsOrdering? {
        didSet {
            setBackgroundColor(.clear)
        }
    }
    weak var delegate: StatsOrderingDelegate?

    private func setBackgroundColor(_ color: UIColor) {
        guard let statsOrdering = statsOrdering else { return }

        switch statsOrdering {
        case .pointsLeastToGreatest: pointsLeastToGreatestButton.backgroundColor = color
        case .pointsGreatestToLeast: pointsGreatestToLeastButton.backgroundColor = color
        case .techsLeastToGreatest: techsLeastToGreatestButton.backgroundColor = color
        case .techsGreatestToLeast: techsGreatestToLeastButton.backgroundColor = color
        case .foulsLeastToGreatest: foulsLeastToGreatestButton.backgroundColor = color
        case .foulsGreatestToLeast: foulsGreatestToLeastButton.backgroundColor = color
        default: break
        }
    }

    @IBAction func tappedButton(_ sender: UIButton) {
        delegate?.didSelectStatsOrdering(position: sender.tag)
    }

    @IBAction func tappedView(_ sender: UITapGestureRecognizer) {
        isHidden = true
    }
}
