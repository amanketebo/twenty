//
//  StatisticsViewController.swift
//  Twenty
//
//  Created by Amanuel Ketebo on 3/10/17.
//  Copyright © 2017 Amanuel Ketebo. All rights reserved.
//

import UIKit

enum StatsOrdering: Int {
    case pointsLeastToGreatest = 1
    case pointsGreatestToLeast
    case techsLeastToGreatest
    case techsGreatestToLeast
    case foulsLeastToGreatest
    case foulsGreatestToLeast
    case recordLeastToGreatest
    case recordGreatestToLeast
}

class StatisticsViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var noStatsLabel: UILabel!

    var allPlayers = [Player]() {
        didSet {
            if allPlayers.isEmpty {
                if noStatsLabel != nil {
                    noStatsLabel.isHidden = false
                }

                navigationItem.rightBarButtonItems?.removeAll()
            }
            else {
                if noStatsLabel != nil {
                    noStatsLabel.isHidden = true
                }

                navigationItem.rightBarButtonItems = [resetStatsBarButton, sortBarButton]
            }
        }
    }
    var statsOrdering: StatsOrdering? {
        didSet {
            sortStats()
        }
    }
    var cellsViewed: [Int: Bool] = [:]

    private let cellsPerRow = 1
    private let edgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
    var statsOrderingView = Bundle.main.loadNibNamed(Bundle.statsOrderingView) as! StatsOrderingView
    private lazy var sortBarButton: UIBarButtonItem = {
        return UIBarButtonItem(
            image: #imageLiteral(resourceName: "sort"),
            style: .plain,
            target: self,
            action: #selector(presentStatsOrderingView(_:)))
    }()
    private lazy var resetStatsBarButton: UIBarButtonItem = {
        return UIBarButtonItem(
            image: #imageLiteral(resourceName: "reset"),
            style: .plain,
            target: self,
            action: #selector(resetStats(_:)))
    }()

    private let statsManager = StatsManager.shared
    private let defaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        sortStats()
        let players = statsManager.fetchAllPlayers()
        self.allPlayers = players
    }

    override func viewDidAppear(_ animated: Bool) {
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        guard let statsOrdering = statsOrdering else { return }

        defaults.set(statsOrdering.rawValue, forKey: UserDefaults.savedStatsOrderingKey)
    }

    private func setupViews() {
        navigationItem.title = "Statistics"

        view.addSubview(statsOrderingView)
        statsOrderingView.fillSuperView()
        statsOrderingView.isHidden = true
        statsOrderingView.delegate = self

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .lightBlack

        sortStats()

        if allPlayers.isEmpty {
            noStatsLabel.isHidden = false
        } else {
            noStatsLabel.isHidden = true
        }
    }

    @objc private func resetStats(_ barButton: UIBarButtonItem) {
        let alert = UIAlertController(title: "Are you sure you want to reset all the stats?", message: nil, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let yes = UIAlertAction(title: "Yes, I'm Sure", style: .default) { [weak self] (alert) in
            self?.statsManager.deleteAllPlayers()
            self?.allPlayers.removeAll()
            self?.collectionView.reloadData()
        }

        alert.addAction(cancel)
        alert.addAction(yes)
        present(alert, animated: true, completion: nil)
    }

    @objc private func presentStatsOrderingView(_ barButton: UIBarButtonItem) {
        statsOrderingView.isHidden = false
    }

    private func sortStats() {
        guard let statsOrdering = statsOrdering else { return }
        guard let _ = collectionView else { return }

        switch statsOrdering {
        case .pointsLeastToGreatest: allPlayers.sort(by: { $0.averagePoints < $1.averagePoints })
        case .pointsGreatestToLeast: allPlayers.sort(by: { $0.averagePoints > $1.averagePoints })
        case .foulsLeastToGreatest: allPlayers.sort(by: { $0.averageFouls < $1.averageFouls })
        case .foulsGreatestToLeast: allPlayers.sort(by: { $0.averageFouls > $1.averageFouls })
        case .techsLeastToGreatest: allPlayers.sort(by: { $0.averageTechs < $1.averageTechs })
        case .techsGreatestToLeast: allPlayers.sort(by: { $0.averageTechs > $1.averageTechs })
        case .recordLeastToGreatest: allPlayers.sort(by: { $0.winPercentage < $1.winPercentage })
        case .recordGreatestToLeast: allPlayers.sort(by: { $0.winPercentage > $1.winPercentage })
        }

        collectionView.reloadData()
    }
}

extension StatisticsViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allPlayers.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StatCollectionViewCell.identifier, for: indexPath) as! StatCollectionViewCell
        cell.configureCell(with: allPlayers[indexPath.row])

        if cellsViewed[indexPath.row] == nil {
            let animationEndingFrame = cell.frame
            let animationDuration = Double(indexPath.row) * 0.10 + 0.2

            cell.alpha = 0.5
            cell.frame = CGRect(x: animationEndingFrame.minX, y: animationEndingFrame.minY + 15, width: animationEndingFrame.size.width, height: animationEndingFrame.size.height)
            UIView.animate(withDuration: animationDuration, animations: { [weak cell] in
                cell?.alpha = 1
                cell?.frame = animationEndingFrame
                }, completion: nil)
            cellsViewed[indexPath.row] = true

            return cell
        } else {
            return cell
        }
    }
}

extension StatisticsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let spaces = CGFloat(cellsPerRow + 1)
        let availableWidth = self.view.bounds.width - (edgeInsets.left * spaces)

        return CGSize(width: availableWidth, height: 145)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return edgeInsets
    }
}

extension StatisticsViewController: StatsOrderingDelegate {
    func didSelectStatsOrdering(position: Int) {
        guard let newStatsOrdering = StatsOrdering(rawValue: position) else { return }

        statsOrderingView.statsOrdering = newStatsOrdering
        statsOrdering = newStatsOrdering
    }
}
