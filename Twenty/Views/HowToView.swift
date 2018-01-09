//
//  HowToView.swift
//  Twenty
//
//  Created by Amanuel Ketebo on 7/8/17.
//  Copyright © 2017 Amanuel Ketebo. All rights reserved.
//

import UIKit
import Foundation

class HowToView: UIView
{
    @IBOutlet weak var okGotItLabel: UILabel!
    
    override func awakeFromNib()
    {
        backgroundColor = .clear
        addGestureRecognizers()
    }
    
    @objc func tappedOkGotIt()
    {
        fadeOut()
    }
    
    func addGestureRecognizers()
    {
        okGotItLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tappedOkGotIt)))
    }
    
    func fadeOut()
    {
        UIView.animate(withDuration: 0.5, animations: {
            self.alpha = 0
        }, completion: { [weak self] (_) in
            self?.removeFromSuperview()
        })
    }
}
