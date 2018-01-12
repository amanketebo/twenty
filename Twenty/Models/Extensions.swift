//
//  Extensions.swift
//  Twenty
//
//  Created by Amanuel Ketebo on 1/18/17.
//  Copyright © 2017 Amanuel Ketebo. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    static let darkBlack = UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1.0)
    static let lightBlack = UIColor(red:0.16, green:0.16, blue:0.16, alpha: 1.0)
    static let slightlyLightBlack = UIColor(red: 0.14, green: 0.14, blue: 0.14, alpha: 1.0)
    static let darkBlue = UIColor(red: 0.17, green: 0.44, blue: 0.64, alpha: 1.0)
    static let lightGray = UIColor(red: 0.31, green: 0.31, blue: 0.31, alpha: 1.0)
    static let slightlyGray = UIColor(red: 0.29, green: 0.29, blue: 0.29, alpha: 1.0)
    static let lightRed = UIColor(red:0.53, green:0.31, blue:0.31, alpha:1.0)
    static let fadedBrightRed = UIColor(red: 0.69, green: 0.11, blue: 0.18, alpha: 0.75)
    static let warningRed = UIColor(red: 0.98, green: 0.08, blue: 0.18, alpha: 1.0)
    static let lightGreen = UIColor(red: 0.32, green: 0.53, blue: 0.31, alpha: 1.0)
    static let fadedBrightGreen = UIColor(red: 0.15, green: 0.91, blue: 0.20, alpha: 0.40)
    static let lightPurple = UIColor(red: 0.43, green: 0.31, blue: 0.53, alpha: 1.0)
}

extension Double {
    func roundTo(places: Int) -> Double {
        let divisor = pow(10, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

extension UILabel {
    @IBInspectable
    var whiteBorder: Bool {
        get {
            return false
        }
        
        set {
            if newValue {
                self.layer.borderWidth = 1
                self.layer.borderColor = UIColor.white.cgColor
            }
        }
    }
}

extension UIView {
    @IBInspectable
    var cornerRadius: CGFloat {
        get { return layer.cornerRadius }
        set { layer.cornerRadius = newValue }
    }
    
    @IBInspectable
    var borderWidth: CGFloat {
        get { return layer.borderWidth }
        set { layer.borderWidth = newValue }
    }
    
    @IBInspectable
    var borderColor: UIColor {
        get {
            guard let borderColor = layer.borderColor else { return UIColor.clear }
            return UIColor(cgColor: borderColor)
        }
        set {
            layer.borderColor = newValue.cgColor
        }
    }
    
    func fillSuperView() {
        if let superView = self.superview {
            self.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                self.leftAnchor.constraint(equalTo: superView.leftAnchor),
                self.rightAnchor.constraint(equalTo: superView.rightAnchor),
                self.topAnchor.constraint(equalTo: superView.topAnchor),
                self.bottomAnchor.constraint(equalTo: superView.bottomAnchor)
                ])
        }
    }
    
    func fadeIn(duration: TimeInterval, delay: TimeInterval, completion: ((Bool) -> Void)?) {
        alpha = 0
        UIView.animate(withDuration: duration, delay: delay, options: .curveLinear, animations: { [weak self] in
            self?.alpha = 1
        }, completion: completion)
    }
    
    func fadeOut(duration: TimeInterval, delay: TimeInterval, completion: ((Bool) -> Void)?) {        
        UIView.animate(withDuration: duration, delay: delay, options: .curveLinear, animations: { [weak self] in
            self?.alpha = 0
        }, completion: completion)
    }
}

extension UIStoryboard {
    static let main = UIStoryboard.init(name: "Main", bundle: nil)
    
    // Segues
    static let newGameVCSegue = "New Game"
    static let statisticsVCSegue = "Statistics"
    
    // VCs
    class var playerNamesVC: UIViewController {
       return main.instantiateViewController(withIdentifier: "Player Names")
    }
    class var gameLimitsVC: UIViewController {
        return main.instantiateViewController(withIdentifier: "Game Limits")
    }
    class var gameVC: UIViewController {
        return main.instantiateViewController(withIdentifier: "Game")
    }
}

extension UserDefaults {
    static let savedStatsOrderingKey = "savedStatsOrdering"
    static let allStatsKey = "allStats"
}

extension Bundle {
    static let statsOrderingView = "StatsOrderingView"
    
    func loadNibNamed(_ name: String) -> UIView? {
        guard let nibView = Bundle.main.loadNibNamed(name, owner: nil, options: nil)?.first as? UIView  else { return nil }
        
        return nibView
    }
}

