//
//  StatisticsViewController.swift
//  Twenty
//
//  Created by Amanuel Ketebo on 1/14/17.
//  Copyright © 2017 Amanuel Ketebo. All rights reserved.
//

import UIKit

class EmptyStatisticsViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Statistics"
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        print("Dipped out: EmptyStatisticsViewController.")
    }
    
}
