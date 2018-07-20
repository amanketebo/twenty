//
//  AppDelegate.swift
//  Twenty
//
//  Created by Amanuel Ketebo on 1/2/17.
//  Copyright © 2017 Amanuel Ketebo. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        setupAppearance()

        return true
    }

    private func setupAppearance() {
        let navbar = UINavigationBar.appearance()

        navbar.barStyle = .black
        navbar.tintColor = .white
        navbar.barTintColor = .darkBlack
        navbar.isTranslucent = false
        navbar.prefersLargeTitles = true
    }
}
