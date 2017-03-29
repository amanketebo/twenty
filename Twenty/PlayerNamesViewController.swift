//
//  PlayerNamesViewController.swift
//  Twenty
//
//  Created by Amanuel Ketebo on 1/19/17.
//  Copyright © 2017 Amanuel Ketebo. All rights reserved.
//

import UIKit

class PlayerNamesViewController: UIViewController {
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        playerOneTextField.delegate = self
        playerTwoTextField.delegate = self
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(PlayerNamesViewController.tappedView(_:))))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        // print("Dipped out: PlayerNamesViewController")
    }

    func tappedView(_ recognizer: UITapGestureRecognizer) {
        playerOneTextField.resignFirstResponder()
        playerTwoTextField.resignFirstResponder()
    }
    
}

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
