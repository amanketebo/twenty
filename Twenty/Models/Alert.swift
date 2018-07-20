//
//  Alert.swift
//  Twenty
//
//  Created by Amanuel Ketebo on 7/19/18.
//  Copyright © 2018 Amanuel Ketebo. All rights reserved.
//

import Foundation
import UIKit

struct Alert {
    static func showAlert(in vc: UIViewController, title: String?, message: String?, actions: [UIAlertAction]? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        if let actions = actions {
            for action in actions {
                alert.addAction(action)
            }
        } else {
            let okayAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okayAction)
        }

        DispatchQueue.main.async { vc.present(alert, animated: true, completion: nil) }

    }
}
