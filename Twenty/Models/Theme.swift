//
//  Theme.swift
//  Twenty
//
//  Created by Amanuel Ketebo on 8/9/18.
//  Copyright © 2018 Amanuel Ketebo. All rights reserved.
//

import Foundation
import UIKit

struct Theme {
    static let shared = Theme()

    func styleNavBar(_ navBar: UINavigationBar) {
        navBar.barStyle = .black
        navBar.tintColor = .white
        navBar.barTintColor = .darkBlack
        navBar.isTranslucent = false
        navBar.prefersLargeTitles = true
    }

    func styleStatLabel(_ statLabel: UILabel) {
        statLabel.textAlignment = .center
        statLabel.font = UIFont.systemFont(ofSize: 50, weight: .medium)
        statLabel.textColor = .white
        statLabel.backgroundColor = .darkBlack
    }
}
