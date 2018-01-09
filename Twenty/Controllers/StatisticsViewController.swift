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
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Properties
    
    var averageStats = [AverageStats]() {
        didSet {
            if averageStats.isEmpty {
                createNoStatsLabelAndAddToView()
                navigationItem.rightBarButtonItems?.removeAll()
            }
            else {
                noStats?.removeFromSuperview()
                navigationItem.rightBarButtonItems = [resetStatsBarButton, sortBarButton]
            }
        }
    }
    var statsOrdering: StatsOrdering?
    private var showingStatsOrderingOptions = false
    private let defaults = UserDefaults.standard
    fileprivate let edgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
    
    // MARK: - Views
    
    private var noStats: UILabel?
    private lazy var sortBarButton: UIBarButtonItem = {
        return UIBarButtonItem(
            image: UIImage(named: "sort"),
            style: .plain,
            target: self,
            action: #selector(presentOrderingOptions(_:)))
    }()
    private lazy var resetStatsBarButton: UIBarButtonItem = {
        return UIBarButtonItem(
            image: UIImage(named: "reset"),
            style: .plain,
            target: self,
            action: #selector(resetStats(_:)))
    }()
    private lazy var statsOrderingOptionsView: UIView = {
        let optionsView = UIView()
        optionsView.backgroundColor = .darkBlack
        optionsView.layer.cornerRadius = 10
        optionsView.clipsToBounds = true
        optionsView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(optionsView)
        
        NSLayoutConstraint.activate([
            optionsView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            optionsView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            optionsView.heightAnchor.constraint(equalToConstant: 300),
            optionsView.widthAnchor.constraint(equalToConstant: 200)
            ])
        
        let firstButton = self.orderingOptionsButton(title: "Points: Least to greatest", ordering: StatsOrdering.pointsLeastToGreatest)
        let secondButon = self.orderingOptionsButton(title: "Points: Greatest to least", ordering:  StatsOrdering.pointsGreatestToLeast)
        let thirdButton = self.orderingOptionsButton(title: "Fouls: Least to greatest", ordering: StatsOrdering.foulsLeastToGreatest)
        let fourthButton = self.orderingOptionsButton(title: "Fouls: Greatest to least", ordering: StatsOrdering.foulsGreatestToLeast)
        let fifthButton = self.orderingOptionsButton(title: "Techs: Least to greatest", ordering: StatsOrdering.techsLeastToGreatest)
        let sixthButton = self.orderingOptionsButton(title: "Techs: Greatest to least", ordering:StatsOrdering.techsGreatestToLeast)
        let buttonStackView = UIStackView(arrangedSubviews: [firstButton, secondButon, thirdButton, fourthButton, fifthButton, sixthButton])
        
        buttonStackView.axis = .vertical
        buttonStackView.distribution = .fillEqually
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        optionsView.addSubview(buttonStackView)
        
        NSLayoutConstraint.activate([
            buttonStackView.leftAnchor.constraint(equalTo: optionsView.leftAnchor),
            buttonStackView.rightAnchor.constraint(equalTo: optionsView.rightAnchor),
            buttonStackView.topAnchor.constraint(equalTo: optionsView.topAnchor),
            buttonStackView.bottomAnchor.constraint(equalTo: optionsView.bottomAnchor)
            ])
        
        return optionsView
    }()
    private var currentlySelectedStatsOrderingButton: UIButton?
    private lazy var seeThroughLayer: CALayer = {
        let seeThrough = CALayer()
        seeThrough.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height)
        seeThrough.backgroundColor = UIColor(red:0.16, green:0.16, blue:0.16, alpha:0.8).cgColor
        
        return seeThrough
    }()
    var cellsViewed = [Int : Bool]()
    
    // MARK: - Life cycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Statistics"
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = UIColor.lightBlack
        sortStats()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if let setOrdering = statsOrdering {
            defaults.set(setOrdering.rawValue, forKey: "savedStatsOrdering")
        }
    }
    
    // MARK: - Action methods
    
    @objc private func resetStats(_ barButton: UIBarButtonItem) {
        let alert = UIAlertController(title: "Are you sure you want to reset all the stats?", message: nil, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let yes = UIAlertAction(title: "Yes, I'm Sure", style: .default) { (alert) in
            self.defaults.removeObject(forKey: "allStats")
            self.averageStats.removeAll()
            self.collectionView.reloadData()
        }
        alert.addAction(cancel)
        alert.addAction(yes)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func tappedView(_ sender: UITapGestureRecognizer) {
        if showingStatsOrderingOptions {
            statsOrderingOptionsView.isHidden = true
            showingStatsOrderingOptions = false
            seeThroughLayer.removeFromSuperlayer()
        }
    }
    
    @objc private func presentOrderingOptions(_ barButton: UIBarButtonItem) {
        if showingStatsOrderingOptions {
            statsOrderingOptionsView.isHidden = true
            showingStatsOrderingOptions = false
            seeThroughLayer.removeFromSuperlayer()
        }
        else {
            view.layer.addSublayer(seeThroughLayer)
            view.addSubview(statsOrderingOptionsView)
            statsOrderingOptionsView.isHidden = false
            showingStatsOrderingOptions = true
        }
    }
    
    @objc private func changeStatsOrdering(_ button: UIButton) {
        if currentlySelectedStatsOrderingButton != button {
            button.backgroundColor = .darkBlue
            currentlySelectedStatsOrderingButton?.backgroundColor = nil
            currentlySelectedStatsOrderingButton = button
            statsOrdering = StatsOrdering(rawValue: button.tag)
            sortStats()
            collectionView.reloadData()
        }
    }
    
    // MARK: - Helper methods
    
    // TODO: Is there a more efficent way to do this?
    private func sortStats() {
        if let ordering = statsOrdering {
            switch ordering {
            case .pointsLeastToGreatest:
                averageStats.sort(by: { (firstStat, secondStat) -> Bool in
                    if firstStat.points < secondStat.points {
                        return true
                    }
                    else {
                        return false
                    }
                })
            case .pointsGreatestToLeast:
                averageStats.sort(by: { (firstStat, secondStat) -> Bool in
                    if firstStat.points > secondStat.points {
                        return true
                    }
                    else {
                        return false
                    }
                })
            case .foulsLeastToGreatest:
                averageStats.sort(by: { (firstStat, secondStat) -> Bool in
                    if firstStat.fouls < secondStat.fouls {
                        return true
                    }
                    else {
                        return false
                    }
                })
            case .foulsGreatestToLeast:
                averageStats.sort(by: { (firstStat, secondStat) -> Bool in
                    if firstStat.fouls > secondStat.fouls {
                        return true
                    }
                    else {
                        return false
                    }
                })
            case .techsLeastToGreatest:
                averageStats.sort(by: { (firstStat, secondStat) -> Bool in
                    if firstStat.techs < secondStat.techs {
                        return true
                    }
                    else {
                        return false
                    }
                })
            case .techsGreatestToLeast:
                averageStats.sort(by: { (firstStat, secondStat) -> Bool in
                    if firstStat.techs > secondStat.techs {
                        return true
                    }
                    else {
                        return false
                    }
                })
            case .recordLeastToGreatest:
                averageStats.sort(by: { (firstStat, secondStat) -> Bool in
                    if firstStat.winPercentage < secondStat.winPercentage {
                        return true
                    }
                    else {
                        return false
                    }
                })
            case .recordGreatestToLeast:
                averageStats.sort(by: { (firstStat, secondStat) -> Bool in
                    if firstStat.winPercentage > secondStat.winPercentage {
                        return true
                    }
                    else {
                        return false
                    }
                })
            }
            
            collectionView.reloadData()
        }
    }
    
    // MARK: - View related methods
    
    private func createNoStatsLabelAndAddToView() {
        noStats = UILabel()
        noStats?.text = "No saved statistics"
        noStats?.textAlignment = .center
        noStats?.font = UIFont.systemFont(ofSize: 21, weight: UIFont.Weight.semibold)
        noStats?.textColor = UIColor(red: 28/255, green: 28/255, blue: 28/255, alpha: 1)
        noStats?.shadowOffset = CGSize(width: 1, height: 1)
        noStats?.shadowColor = UIColor(red: 48/255, green: 48/255, blue: 48/255, alpha: 1)
        noStats?.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(noStats!)
        noStats?.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        noStats?.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        noStats?.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        noStats?.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    private func orderingOptionsButton(title: String, ordering: StatsOrdering) -> UIButton {
        let orderingButton = UIButton(type: .system)
        orderingButton.setTitle(title, for: .normal)
        orderingButton.setTitleColor(.white, for: .normal)
        orderingButton.tag = ordering.rawValue
        
        if let setOrdering = statsOrdering {
            if setOrdering == ordering {
                orderingButton.backgroundColor = .darkBlue
                currentlySelectedStatsOrderingButton = orderingButton
            }
        }
        
        orderingButton.addTarget(self, action: #selector(changeStatsOrdering(_:)), for: .touchUpInside)
        
        return orderingButton
    }
}

// MARK: - Datasource & delegate methods

extension StatisticsViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return averageStats.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "statCell", for: indexPath) as! StatCollectionViewCell
        cell.configureCell(with: averageStats[indexPath.row])
        
        guard cellsViewed[indexPath.row] != nil else {
            cell.alpha = 0.5
            let endingFrame = cell.frame
            cell.frame = CGRect(x: endingFrame.minX, y: endingFrame.minY + 15, width: endingFrame.size.width, height: endingFrame.size.height)
            let timeOfAnimation = (Double(indexPath.row) * 0.10) + 0.2
            UIView.animate(withDuration: timeOfAnimation, animations: { [weak cell] in
                cell?.alpha = 1
                cell?.frame = endingFrame
                }, completion: nil)
            cellsViewed[indexPath.row] = true
            return cell
        }
        
        
        
//        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panLeftRight(_:)))
//        cell.addGestureRecognizer(panGesture)
        
        return cell
    }
    
}

extension StatisticsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = self.view.bounds.width - (edgeInsets.left * 2)
        
        return CGSize(width: availableWidth, height: 145)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return edgeInsets
    }
    
}
