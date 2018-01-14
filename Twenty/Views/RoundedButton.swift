//
//  RoundedRectangle.swift
//  Twenty
//
//  Created by Amanuel Ketebo on 1/25/17.
//  Copyright © 2017 Amanuel Ketebo. All rights reserved.
//

import UIKit

class RoundedButton: UIButton {
    override func draw(_ rect: CGRect) {
        layer.cornerRadius = 5
        clipsToBounds = true
    }
}
