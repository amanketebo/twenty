//
//  StatView.swift
//  Twenty
//
//  Created by Amanuel Ketebo on 6/26/18.
//  Copyright © 2018 Amanuel Ketebo. All rights reserved.
//

import UIKit

enum PanDirection {
    case up
    case down

    static func movement(_ velocity: CGPoint) -> PanDirection {
        return velocity.y <= 0 ? self.up : self.down
    }
}

enum StatLabelPosition {
    case previous
    case current
    case next
}

@objc protocol StatViewDelegate {
    func updatedPlayerStat(playerNumber: Int, statType: Int, stat: Int)
}

class StatView: UIView {
    weak var delegate: StatViewDelegate?

    var previousStatLabel: UILabel!
    var currentStatLabel: UILabel!
    var nextStatLabel: UILabel!

    var playerNumber: Int!
    var statSection: Int!
    var movingStatLabel: UILabel?

    var statLabel: UILabel {
        let label = UILabel()

        Theme.shared.styleStatLabel(label)

        return label
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setProperties()
    }

    override func draw(_ rect: CGRect) {
        clipsToBounds = true
        addGestureRecognizers()
        setStatLabels(with: 0)
    }

    // MARK: Public methods

    func reset() {
        setStatLabels(with: 0)
    }

    func overLimit() {
        currentStatLabel.backgroundColor = .warningRed
    }

    // MARK: Private methods

    private func setProperties() {
        let statLabelTag = String(tag)

        playerNumber = Int(String(describing: statLabelTag.first ?? "0"))
        statSection = Int(String(describing: statLabelTag.last ?? "0"))
    }

    private func addGestureRecognizers() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))

        addGestureRecognizer(pan)
    }

    @objc private func handlePan(_ sender: UIPanGestureRecognizer) {
        if sender.state == .began {
            let velocity = sender.velocity(in: self)
            movingStatLabel = findMovingStatLabel(velocity)
        } else if sender.state == .changed {
            let translation = sender.translation(in: self)
            moveStatLabel(translation)
        } else if sender.state == .ended {
            let velocity = sender.velocity(in: self)
            moveStatLabelToFinalPosition(velocity)
        }
    }

    private func setStatLabels(with currentNumber: Int) {
        subviews.forEach { $0.removeFromSuperview() }
        previousStatLabel = nil
        currentStatLabel = nil
        nextStatLabel = nil

        if currentNumber != 0 {
            previousStatLabel = label(for: .previous, number: currentNumber - 1)
        }
        currentStatLabel = label(for: .current, number: currentNumber)
        nextStatLabel = label(for: .next, number: currentNumber + 1)

        addSubview(currentStatLabel)
        if previousStatLabel != nil {
            addSubview(previousStatLabel)
        }
        addSubview(nextStatLabel)
    }

    // MARK: Helper methods

    private func label(for position: StatLabelPosition, number: Int) -> UILabel {
        let label = statLabel

        label.text = "\(number)"
        label.backgroundColor = .darkBlack
        label.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)

        switch position {
        case .previous: label.frame.origin.y = -bounds.height
        case .current: label.frame.origin.y = 0
        case .next: label.frame.origin.y = bounds.height
        }

        return label
    }

    private func findMovingStatLabel(_ velocity: CGPoint) -> UILabel? {
        switch PanDirection.movement(velocity) {
        case .up: return nextStatLabel
        case .down: return previousStatLabel
        }
    }

    private func moveStatLabel(_ translation: CGPoint) {
        var originalPoint = CGPoint(x: 0, y: 0)

        originalPoint.y = movingStatLabel == previousStatLabel ? -bounds.height : bounds.height
        movingStatLabel?.frame.origin.y = originalPoint.y + translation.y
    }

    private func moveStatLabelToFinalPosition(_ velocity: CGPoint) {
        guard let movingStatLabel = movingStatLabel else { return }
        guard let statLabelNumber = Int(movingStatLabel.text!) else { return }

        if movingStatLabel == previousStatLabel {
            switch PanDirection.movement(velocity) {
            case .up:
                movingStatLabel.frame.origin.y = -bounds.height
            case .down:
                movingStatLabel.frame.origin.y = 0
                setStatLabels(with: statLabelNumber)
                delegate?.updatedPlayerStat(playerNumber: playerNumber, statType: statSection, stat: statLabelNumber)
            }
        } else {
            switch PanDirection.movement(velocity) {
            case .up:
                movingStatLabel.frame.origin.y = 0
                setStatLabels(with: statLabelNumber)
                delegate?.updatedPlayerStat(playerNumber: playerNumber, statType: statSection, stat: statLabelNumber)
            case .down:
                movingStatLabel.frame.origin.y = bounds.height
            }
        }
    }
}
