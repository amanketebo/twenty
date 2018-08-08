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
    // Blacks
    static let darkBlack = UIColor(hex: 0x212121, alpha: 1)
    static let lightBlack = UIColor(hex: 0x292929, alpha: 1)

    // Blues
    static let darkBlue = UIColor(hex: 0x2B70A3, alpha: 1.0)

    // Grays
    static let lightGray = UIColor(hex: 0x4F4F4F, alpha: 1.0)

    // Reds
    static let lightRed = UIColor(hex: 0x874F4F, alpha:1.0)
    static let brightRed = UIColor(hex: 0xB01C2E, alpha: 0.75)
    static let darkBrightRed = UIColor(hex: 0x660F19, alpha:0.75)
    static let warningRed = UIColor(hex: 0xF9142D, alpha: 1.0)

    // Greens
    static let lightGreen = UIColor(hex: 0x51874F, alpha: 1.0)
    static let brightGreen = UIColor(hex: 0x26E833, alpha: 0.40)
    static let darkBrightGreen = UIColor(hex: 0x0C4711, alpha: 0.75)
    
    // Purples
    static let lightPurple = UIColor(hex: 0x6D4F87, alpha: 1.0)

    convenience init(hex: Int, alpha: CGFloat) {
        let red = CGFloat((hex & 0xFF0000) >> 16) / 255
        let green = CGFloat((hex & 0xFF00) >> 8) / 255
        let blue = CGFloat((hex & 0xFF)) / 255

        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }

    var hexString: String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0

        self.getRed(&red, green: &green, blue: &blue, alpha: nil)

        let redUInt = UInt32(red * 255)
        let greenUInt = UInt32(green * 255)
        let blueUInt = UInt32(blue * 255)

        return String(format: "%02X%02X%02X", Int(redUInt & 0xFF), Int(greenUInt & 0xFF), Int(blueUInt & 0xFF))
    }
}

extension UIView {
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
    static let firstTimeUsingAppKey = "firstTimeUsingApp"
}

extension Bundle {
    static let statsOrderingView = "StatsOrderingView"

    func loadNibNamed(_ name: String) -> UIView? {
        guard let nibView = Bundle.main.loadNibNamed(name, owner: nil, options: nil)?.first as? UIView  else { return nil }

        return nibView
    }
}

extension Double {
    func roundTo(places: Int) -> Double {
        let divisor = pow(10, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
