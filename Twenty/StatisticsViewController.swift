//
//  StatisticsViewController.swift
//  Twenty
//
//  Created by Amanuel Ketebo on 3/10/17.
//  Copyright © 2017 Amanuel Ketebo. All rights reserved.
//

import UIKit

class StatisticsViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let defaults = UserDefaults.standard
    var noStats: UILabel?
    var averageStats = [AverageStats]() {
        didSet {
            if averageStats.count == 0 {
                createNoStatsLabelAndAddToView()
                navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Reset Stats", style: .plain, target: self, action: #selector(StatisticsViewController.resetStats(_:)))
                navigationItem.setRightBarButton(nil, animated: true)
            }
            else {
                noStats?.removeFromSuperview()
                noStats = nil
                navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Reset Stats", style: .plain, target: self, action: #selector(StatisticsViewController.resetStats(_:)))
            }
        }
    }
    let edgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationItem.title = "Statistics"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Reset", style: .plain, target: self, action: #selector(StatisticsViewController.resetStats(_:)))
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = UIColor.lightBlack
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        // print("Dipped out: StatisticsViewController")
    }
    
    func createNoStatsLabelAndAddToView() {
        noStats = UILabel()
        noStats?.text = "No saved statistics"
        noStats?.textAlignment = .center
        noStats?.font = UIFont.systemFont(ofSize: 21, weight: UIFontWeightSemibold)
        noStats?.textColor = UIColor(red: 28/255, green: 28/255, blue: 28/255, alpha: 1)
        noStats?.shadowOffset = CGSize(width: 1, height: 1)
        noStats?.shadowColor = UIColor(red: 46/255, green: 46/255, blue: 46/255, alpha: 1)
        noStats?.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(noStats!)
        noStats?.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        noStats?.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        noStats?.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        noStats?.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    func resetStats(_ barButton: UIBarButtonItem) {
        let alert = UIAlertController(title: "Are you sure?", message: nil, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let yes = UIAlertAction(title: "Yes, I'm Sure", style: .default) {
            (alert) in
            self.defaults.removeObject(forKey: "allStats")
            self.averageStats.removeAll()
            self.collectionView.reloadData()
        }
        alert.addAction(cancel)
        alert.addAction(yes)
        self.present(alert, animated: true, completion: nil)
    }
    
}

extension StatisticsViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return averageStats.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "statCell", for: indexPath) as! StatCollectionViewCell
        // Set up cell with information from average stats array
        cell.name.text = averageStats[indexPath.row].name
        cell.averagePoints.text = String(averageStats[indexPath.row].points)
        cell.averageFouls.text = String(averageStats[indexPath.row].fouls)
        cell.averageTechs.text = String(averageStats[indexPath.row].techs)
        cell.record.text =  "\(String(Int(averageStats[indexPath.row].gamesWon)))-\(String(Int(averageStats[indexPath.row].gamesLost)))"
        
        return cell
    }
    
}

extension StatisticsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = self.view.bounds.width - (edgeInsets.left * 2)
        
        return CGSize(width: availableWidth, height: 145)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return edgeInsets
    }
    
}
