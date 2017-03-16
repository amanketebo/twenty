//
//  StatisticsViewController.swift
//  Twenty
//
//  Created by Amanuel Ketebo on 3/10/17.
//  Copyright © 2017 Amanuel Ketebo. All rights reserved.
//

import UIKit

class StatisticsViewController: UIViewController, UICollectionViewDelegate {
    
    let defaults = UserDefaults.standard
    var averageStats = [AverageStats]()
    
    @IBOutlet weak var collectionView: UICollectionView!

    let itemsPerRow = 1
    let edgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationItem.title = "Statistics"
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = false
        print(averageStats)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        print("Dipped out: Non-EmptyStatisticsViewController")
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
        cell.name.text = averageStats[indexPath.row].name
        cell.averagePoints.text = String(averageStats[indexPath.row].points)
        cell.averageFouls.text = String(averageStats[indexPath.row].fouls)
        cell.averageTechs.text = String(averageStats[indexPath.row].techs)
        cell.record.text =  "11-25" /*"\(String(Int(averageStats[indexPath.row].gamesWon)))-\(String(Int(averageStats[indexPath.row].gamesLost)))"*/
        
        return cell
    }
}

extension StatisticsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = self.view.bounds.width - (edgeInsets.left * 2)
        
        return CGSize(width: availableWidth, height: 145)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return edgeInsets
    }
}
