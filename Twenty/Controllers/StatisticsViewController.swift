//
//  StatisticsViewController.swift
//  Twenty
//
//  Created by Amanuel Ketebo on 3/10/17.
//  Copyright © 2017 Amanuel Ketebo. All rights reserved.
//

import UIKit

class StatisticsViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Properties
    
    let defaults = UserDefaults.standard
    var noStats: UILabel?
    var averageStats = [AverageStats]() {
        didSet {
            if averageStats.isEmpty {
                createNoStatsLabelAndAddToView()
                navigationItem.setRightBarButton(nil, animated: true)
            }
            else {
                noStats?.removeFromSuperview()
                navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Reset Stats", style: .plain, target: self, action: #selector(self.resetStats(_:)))
            }
        }
    }
    let edgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
    
    // MARK: - Life cycle Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationItem.title = "Statistics"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Reset",
            style: .plain,
            target: self,
            action: #selector(self.resetStats(_:))
        )
        
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
    
    // MARK: - Action functions
    
    func resetStats(_ barButton: UIBarButtonItem) {
        let alert = UIAlertController(title: "Are you sure?", message: nil, preferredStyle: .alert)
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
    
    // MARK: - View returning functions
    
    func createNoStatsLabelAndAddToView() {
        noStats = UILabel()
        noStats?.text = "No saved statistics"
        noStats?.textAlignment = .center
        noStats?.font = UIFont.systemFont(ofSize: 21, weight: UIFontWeightSemibold)
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
}

// MARK: - Datasource & delegate functions

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
