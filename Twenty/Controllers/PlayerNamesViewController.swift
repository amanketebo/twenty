//
//  PlayerNamesViewController.swift
//  Twenty
//
//  Created by Amanuel Ketebo on 1/19/17.
//  Copyright © 2017 Amanuel Ketebo. All rights reserved.
//

import UIKit

class PlayerNamesViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var playerNamesHolder: UIView! {
        didSet {
            playerNamesHolder.layer.cornerRadius = 10
        }
    }
    @IBOutlet weak var playerNameTextFieldsHolder: UIView! {
        didSet {
            playerNameTextFieldsHolder.layer.borderWidth = 2
            playerNameTextFieldsHolder.layer.borderColor = UIColor.lightGray.cgColor
            playerNameTextFieldsHolder.clipsToBounds = true
            playerNameTextFieldsHolder.layer.cornerRadius = 5
        }
    }
    @IBOutlet weak var playerOneTextField: UITextField!
    @IBOutlet weak var playerTwoTextField: UITextField!
    
    // MARK: - Life cycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        playerOneTextField.delegate = self
        playerTwoTextField.delegate = self
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(PlayerNamesViewController.tappedView(_:))))
    }
    
    // MARK: - Action methods

    @objc func tappedView(_ recognizer: UITapGestureRecognizer) {
        playerOneTextField.resignFirstResponder()
        playerTwoTextField.resignFirstResponder()
    }
    
}

// MARK: - Delegate methods

extension PlayerNamesViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == playerOneTextField {
            playerTwoTextField.becomeFirstResponder()
        }
        else {
            textField.resignFirstResponder()
        }
        
        return true
    }
    
}
