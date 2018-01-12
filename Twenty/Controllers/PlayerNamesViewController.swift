//
//  PlayerNamesViewController.swift
//  Twenty
//
//  Created by Amanuel Ketebo on 1/19/17.
//  Copyright © 2017 Amanuel Ketebo. All rights reserved.
//

import UIKit

class PlayerNamesViewController: UIViewController {
    @IBOutlet weak var playerNamesHolder: UIView!
    @IBOutlet weak var playerNameTextFieldsHolder: UIView!
    @IBOutlet weak var playerOneTextField: UITextField!
    @IBOutlet weak var playerTwoTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        playerOneTextField.delegate = self
        playerTwoTextField.delegate = self
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(PlayerNamesViewController.tappedView(_:))))
    }

    @objc func tappedView(_ recognizer: UITapGestureRecognizer) {
        playerOneTextField.resignFirstResponder()
        playerTwoTextField.resignFirstResponder()
    }
}

extension PlayerNamesViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        playerOneTextField.resignFirstResponder()
        playerTwoTextField.resignFirstResponder()
        
        return true
    }
}
